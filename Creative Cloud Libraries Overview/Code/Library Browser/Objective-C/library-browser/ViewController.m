/*
 * Copyright (c) 2016 Adobe Systems Incorporated. All rights reserved.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
 */

#import <AdobeCreativeSDKCore/AdobeCreativeSDKCore.h>
#import <AdobeCreativeSDKAssetModel/AdobeCreativeSDKAssetModel.h>
#import <AdobeCreativeSDKAssetUX/AdobeCreativeSDKAssetUX.h>

#import "ViewController.h"

#warning Please update the ClientId and Secret to the values provided by creativesdk.com
static NSString * const kCreativeSDKClientId = @"Change me";
static NSString * const kCreativeSDKClientSecret = @"Change me";
static NSString * const kCreativeSDKRedirectURLString = @"Change me";

static NSString * const kLibraryRootFolderPathPreferencesKey = @"kLibraryRootFolderPath";

@interface ViewController () <AdobeLibraryDelegate, AdobeUXAssetBrowserViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *logoutButton;
@property (weak, nonatomic) IBOutlet UIImageView *selectionThumbnailImageView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (copy, nonatomic, nullable) NSString *localLibraryRootFolder;

@end

@implementation ViewController

@synthesize assetDownloadLibraryFilter;
@synthesize autoSyncDownloadedAssets;
@synthesize libraryQueue;
@synthesize syncOnCommit;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // Set the client ID and secret values so the CSDK can identify the calling app. The three
    // specified scopes are required at a minimum.
    [[AdobeUXAuthManager sharedManager] setAuthenticationParametersWithClientID:kCreativeSDKClientId
                                                                   clientSecret:kCreativeSDKClientSecret
                                                            additionalScopeList:@[AdobeAuthManagerUserProfileScope,
                                                                                  AdobeAuthManagerEmailScope,
                                                                                  AdobeAuthManagerAddressScope]];
    
    // Also set the redirect URL, which is required by the CSDK authentication mechanism.
    [AdobeUXAuthManager sharedManager].redirectURL = [NSURL URLWithString:kCreativeSDKRedirectURLString];
    
    // Register for the logout notification so we can perform the necessary Library Manager cleanup
    // tasks.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userDidLogOutNotificationHandler:)
                                                 name:AdobeAuthManagerLoggedOutNotification
                                               object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.logoutButton.hidden = ![AdobeUXAuthManager sharedManager].isAuthenticated;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    // Although we don't need to do this starting in iOS 9[1], it's probably good practice to
    // do it anyway.
    //
    // [1]: https://developer.apple.com/library/content/releasenotes/Foundation/RN-Foundation/#10_11NotificationCenter
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:AdobeAuthManagerLoggedOutNotification
                                                  object:nil];
}

#pragma mark - UI Actions

- (IBAction)showLibraryBrowserTouchUpInside
{
    // Only show the Library datasource in the Asset Browser. This helps keep this test app focused.
    AdobeAssetDataSourceFilter *datasourceFilter =
        [[AdobeAssetDataSourceFilter alloc] initWithDataSources:@[AdobeAssetDataSourceLibrary]
                                                     filterType:AdobeAssetDataSourceFilterInclusive];
    
    // Create an Asset Browser configuration object that can be used to filter the datasources and
    // to specify the supported Library item types.
    AdobeUXAssetBrowserConfiguration *configuration = [AdobeUXAssetBrowserConfiguration new];
    configuration.dataSourceFilter = datasourceFilter;
    
    // Create a new instance of the Asset Browser view controller, set it's configuration and
    // delegate and present it.
    AdobeUXAssetBrowserViewController *assetBrowser =
        [AdobeUXAssetBrowserViewController assetBrowserViewControllerWithConfiguration:configuration
                                                                              delegate:self];
    
    [self presentViewController:assetBrowser animated:YES completion:nil];
}

- (IBAction)logoutButtonTouchUpInside
{
    [[AdobeUXAuthManager sharedManager] logout:^
    {
        NSLog(@"Successfully logged out");
    }
                                       onError:^(NSError *error)
    {
        NSLog(@"There was a problem logging out: %@", error);
    }];
}

#pragma mark - AdobeUXAssetBrowserViewControllerDelegate

- (void)assetBrowserDidSelectAssets:(AdobeSelectionAssetArray *)itemSelections
{
    // Dismiss the Asset Browser view controller.
    [self dismissViewControllerAnimated:YES completion:nil];
    
    // Configure the AdobeLibraryManager and start it before we do anything. We're required to do
    // this to make sure the latest revision of the Libraries and the contained assets are present.
    AdobeLibraryDelegateStartupOptions *libraryManagerStartupOptions = [AdobeLibraryDelegateStartupOptions new];
    libraryManagerStartupOptions.autoDownloadPolicy = AdobeLibraryDownloadPolicyTypeManifestOnly;
    libraryManagerStartupOptions.autoDownloadContentTypes = @[kAdobeMimeTypePNG, kAdobeMimeTypeJPEG];
    libraryManagerStartupOptions.elementTypesFilter = @[AdobeDesignLibraryImageElementType];
    
    self.localLibraryRootFolder = [[NSUserDefaults standardUserDefaults] stringForKey:kLibraryRootFolderPathPreferencesKey];
    
    if (self.localLibraryRootFolder.length == 0)
    {
        // Create a temporary path for the locally synced files to be stored.
        NSString *rootLibraryFolder = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
        rootLibraryFolder = [rootLibraryFolder stringByAppendingPathComponent:@"libraries"];
        rootLibraryFolder = [rootLibraryFolder stringByAppendingPathComponent:[NSUUID UUID].UUIDString];
        
        // Remember the path so we can clean it up on logout.
        self.localLibraryRootFolder = rootLibraryFolder;
        
        // Store the user-specific Library root folder path in the preferences so it could be
        // retrieved on subsequent calls to the Asset Browser.
        [[NSUserDefaults standardUserDefaults] setObject:rootLibraryFolder
                                                  forKey:kLibraryRootFolderPathPreferencesKey];
    }
    
    NSError *error = nil;
    AdobeLibraryManager *libraryManager = [AdobeLibraryManager sharedInstance];
    libraryManager.syncAllowedByNetworkStatusMask = AdobeNetworkReachableViaWiFi | AdobeNetworkReachableViaWWAN;
    [libraryManager startWithFolder:self.localLibraryRootFolder andError:&error];
    [libraryManager registerDelegate:self options:libraryManagerStartupOptions];
    
    // Grab the first selected item. This item is the a selection object that has information about
    // the selected item(s). We can use this object to pinpoint the selected Library item and
    // perform interesting tasks, like downloading a thumbnail.
    AdobeSelection *selection = itemSelections.firstObject;
    
    // Make sure we're dealing with a Library selection object.
    if (IsAdobeSelectionLibraryAsset(selection))
    {
        // We know that we've selected a Library item so casting is safe.
        AdobeSelectionLibraryAsset *librarySelection = (AdobeSelectionLibraryAsset *)selection;
        
        // Grab the Library ID.
        NSString *selectedLibraryId = librarySelection.selectedLibraryID;
        
        // Grab the Library object.
        AdobeLibraryComposite *library = [[AdobeLibraryManager sharedInstance] libraryWithId:selectedLibraryId];
        
        // Get the first selected item ID.
        NSString *selectedImageId = librarySelection.selectedElementIDs.firstObject;
        
        // Now get the selected item, in this case an image, from the Library. Note that, for this
        // demo, we only handle images, however all other supported Library item types can be
        // retrieved and processed.
        AdobeLibraryElement *libraryElement = [library elementWithId:selectedImageId];
        
        NSLog(@"Selected Library Element:\n"
              "\tID:%@\n"
              "\tName:%@\n"
              "\tCreated:%@\n"
              "\tModified:%@\n"
              "\tType:%@\n"
              "\tTags:%@",
              libraryElement.elementId,
              libraryElement.name,
              [NSDate dateWithTimeIntervalSince1970:libraryElement.created],
              [NSDate dateWithTimeIntervalSince1970:libraryElement.modified],
              libraryElement.type,
              libraryElement.tags);
        
        // Clear out any existing thumbnails from already-selected images.
        self.selectionThumbnailImageView.image = nil;
        
        // Start the activity indicator to get the user feedback.
        [self.activityIndicator startAnimating];
        
        [library getRenditionPath:selectedImageId
                         withSize:0
                       isFullSize:YES
                     handlerQueue:[NSOperationQueue mainQueue]
                     onCompletion:^(NSString *path)
        {
            // Try to create a UIImage object from the rendition and display it.
            UIImage *thumbnailImage = [UIImage imageWithContentsOfFile:path];
            
            if (thumbnailImage == nil)
            {
                NSLog(@"The returned rendition path cannot be converted into an image.");
            }
            else
            {
                // Everything is good, display the image and stop the activity indicator.
                self.selectionThumbnailImageView.image = thumbnailImage;
            }
            
            [self.activityIndicator stopAnimating];
        }
                          onError:^(NSError *error)
        {
            NSLog(@"An error occurred when attempting to retrieve the path to the rendition "
                  "representation: %@", error);
            
            if ([error.domain isEqualToString:AdobeLibraryErrorDomain])
            {
                if (error.code == AdobeLibraryErrorRepresentationHasNoFile ||
                    error.code == AdobeLibraryErrorNoRenditionCandidate)
                {
                    [self displayUnsupportedSelectionAlert];
                }
            }
            
            [self.activityIndicator stopAnimating];
        }];
    }
    else
    {
        NSLog(@"The selected item isn't a Library selection.");
    }
}

- (void)assetBrowserDidEncounterError:(NSError *)error
{
    // Dismiss the Asset Browser
    [self dismissViewControllerAnimated:YES completion:nil];
    
    // Handle the error. Here we only print out a log of the error.
    NSLog(@"An error occurred: %@", error);
}

#pragma mark - AdobeLibraryDelegate

- (void)syncFinished
{
    // The Library manager completed a sync operation so unregister the current class so the
    // manager can shut down.
    [[AdobeLibraryManager sharedInstance] deregisterDelegate:self];
}

#pragma mark - Notification Handlers

- (void)userDidLogOutNotificationHandler:(NSNotification *)notification
{
    if ([[AdobeLibraryManager sharedInstance] isStarted])
    {
        [[AdobeLibraryManager sharedInstance] deregisterDelegate:self];
        
        if (self.localLibraryRootFolder.length > 0)
        {
            NSError *error = nil;
            
            [AdobeLibraryManager removeLocalLibraryFilesInRootFolder:self.localLibraryRootFolder withError:&error];
            
            if (error != nil)
            {
                NSLog(@"Could not remove local library file ('%@') due to: %@", self.localLibraryRootFolder, error);
            }
        }
    }
    
    self.logoutButton.hidden = ![AdobeUXAuthManager sharedManager].isAuthenticated;
    
    // Reset the Library root folder path variable
    self.localLibraryRootFolder = nil;
    
    // Also remove the Library root folder path from the preferences since we're logging out
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kLibraryRootFolderPathPreferencesKey];
}

#pragma mark - Private/Utility Methods

- (void)displayUnsupportedSelectionAlert
{
    NSString *message = @"For the purposes of this demo, please select an image/graphic Library item type.";
    
    NSLog(@"%@", message);
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Demo"
                                                                             message:message
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                       style:UIAlertActionStyleDefault
                                                     handler:nil];
    [alertController addAction:okAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

@end
