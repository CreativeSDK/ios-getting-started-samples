//
//Copyright (c) 2015 Adobe Systems Incorporated. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a
// copy of this software and associated documentation files (the "Software"),
// to deal in the Software without restriction, including without limitation
// the rights to use, copy, modify, merge, publish, distribute, sublicense,
// and/or sell copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
// DEALINGS IN THE SOFTWARE.
//
//
//  RKCViewController.m
//  TestFiles
//

#import "RKCViewController.h"
#import "RKCView.h"
#import <AdobeCreativeSDKCore/AdobeCreativeSDKCore.h>  // AdobeUXAuthManager.h
#import <AdobeCreativeSDKCommonUX/AdobeCreativeSDKCommonUX.h> // AdobeCreativeSDKCommonUX.h
#import <AdobeCreativeSDKAssetModel/AdobeCreativeSDKAssetModel.h>  // AdobeAssetFile.h AdobeAssetFolder.h AdobeAssetMimeTypes.h AdobeSelectionAsset.h & AdobeSendToDesktopApplication.h
#import <AdobeCreativeSDKAssetUX/AdobeCreativeSDKAssetUX.h> //AdobeUXAssetBrowser.h>
#import <AdobeCreativeSDKBehance/AdobePublishShareMenu.h>
#import <AdobeCreativeSDKDevice/AdobeCreativeSDKDevice.h>

@interface RKCViewController ()

@end

@implementation RKCViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)loadView
{
    CGRect frame = [UIScreen mainScreen].bounds;
    
    RKCView *tv = [[RKCView alloc] initWithFrame:frame];
    
    self.view = tv;
    
    // Please update the ClientId and Secret to the values provided by creativesdk.com or from Adobe
    static NSString* const CreativeSDKClientId = @"changeme";
    static NSString* const CreativeSDKClientSecret = @"changeme";
    
    [[AdobeUXAuthManager sharedManager] setAuthenticationParametersWithClientID:CreativeSDKClientId clientSecret:CreativeSDKClientSecret enableSignUp:true];

    //The authManager caches our login, so check on startup
    BOOL loggedIn = [AdobeUXAuthManager sharedManager].authenticated;
    if(loggedIn) {
        NSLog(@"We have a cached logged in");
        [((RKCView *)self.view).loginButton setTitle:@"Logout" forState:UIControlStateNormal];
        [((RKCView *)self.view).showFileUploadButton setHidden:NO];
        
    }
    
}

- (void)doLogin {
    
    //Are we logged in?
    BOOL loggedIn = [AdobeUXAuthManager sharedManager].authenticated;
    
    if(!loggedIn) {
        
        [[AdobeUXAuthManager sharedManager] login:self
                onSuccess: ^(AdobeAuthUserProfile * userProfile) {
                    NSLog(@"success for login");
					[((RKCView *)self.view).loginButton setTitle:@"Logout" forState:UIControlStateNormal];
					[((RKCView *)self.view).showFileUploadButton setHidden:NO];
               }
         
				onError: ^(NSError * error) {
                    NSLog(@"Error in Login: %@", error);
				}];
        
    } else {
        
        [[AdobeUXAuthManager sharedManager] logout:^void {
            NSLog(@"success for logout");
            [((RKCView *)self.view).loginButton setTitle:@"Login" forState:UIControlStateNormal];
            [((RKCView *)self.view).showFileUploadButton setHidden:YES];
        } onError:^(NSError *error) {
            NSLog(@"Error on Logout: %@", error);
        }];
    }
}

- (void)uploadPhoto {
    
    UIImagePickerController *selImage = [[UIImagePickerController alloc] init];
    
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        selImage.sourceType = UIImagePickerControllerSourceTypeCamera;
    } else {
        selImage.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }

    selImage.delegate = self;
    
    [self presentViewController:selImage animated:YES completion:nil];
    
}

- (void)willPresentInView:(UIView *)view buttonRect:(CGRect)rect {
    
}

- (void)shareMenuDismissed {
    
}

- (NSArray *)shareItemsForDestination:(NSString *)shareDestination {
    NSLog(@"shareItemsForDestination");

    NSDictionary *info = @{
                           kAdobePublishShareMenuItemKeyImage:[((RKCView *)self.view) selectedImgView].image,
                           kAdobePublishShareMenuItemKeyName:@"foo.png"
                           };
    
    NSArray *result = @[info];
    
    return result;
}

- (void)shareStarted:(NSString *)destination {
    NSLog(@"shareStarted");
}

- (void)shareCompleted:(BOOL)completed items:(NSArray *)sharedItems returnedData:(NSDictionary *)returnedData destination:(NSString *)destination error:(NSError *)error {
    NSLog(@"running shareCompleted");
    NSLog(@"%@", error);
}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSLog(@"%@", info);
    NSURL *path = info[UIImagePickerControllerReferenceURL];

    NSString *stringURL = [path absoluteString];
    NSLog(@"stringurl %@", stringURL);
    
    UIImage *img = info[UIImagePickerControllerOriginalImage];
    [((RKCView *)self.view) selectedImgView].image = img;
  
    // convert to jpeg
    NSData *imgData = UIImageJPEGRepresentation( img, 0.8f );
    
    __block NSString *dataPath = [NSTemporaryDirectory() stringByAppendingPathComponent: @"foo.jpg"];
    NSURL* dataURL = [NSURL fileURLWithPath: dataPath];
    
    NSError* err;
    BOOL success = [imgData writeToFile:dataPath options:NSDataWritingAtomic error: &err];


    if(success) {
        
        AdobeAssetFolder *root = [AdobeAssetFolder getRootOrderedByField:AdobeAssetFolderOrderByName orderDirection:AdobeAssetFolderOrderDescending];
        
        
        [AdobeAssetFile create:@"foo.jpg"
                      inFolder:root
                  withDataPath:dataURL
                      withType:kAdobeMimeTypeJPEG
           withCollisionPolicy:AdobeAssetFileCollisionPolicyAppendUniqueNumber
                    onProgress:^(double fractionCompleted) {
                        NSLog(@"Percent complete %f", fractionCompleted);
                    }
         
                  onCompletion:^(AdobeAssetFile *file) {
                      NSLog(@"I DID IT!");
                      
                      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"File Uploaded"
                                                                      message:@"Your file was uploaded!"
                                                                     delegate:nil
                                                            cancelButtonTitle:@"OK"
                                                            otherButtonTitles:nil];
                      [alert show];
                      
                  }
                onCancellation:nil
                       onError:^(NSError *error) {
                           NSLog(@"error uploading %@", error);
                       }];
        
    }
    
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

@end
