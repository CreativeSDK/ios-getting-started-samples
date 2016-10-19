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
#import <MobileCoreServices/MobileCoreServices.h>

#import "ViewController.h"

#warning Please update the ClientId and Secret to the values provided by creativesdk.com
static NSString * const kCreativeSDKClientId = @"Change me";
static NSString * const kCreativeSDKClientSecret = @"Change me";
static NSString * const kCreativeSDKRedirectURLString = @"Change me";

@interface ViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *authButton;
@property (weak, nonatomic) IBOutlet UIButton *uploadButton;
@property (weak, nonatomic) IBOutlet UILabel *uploadingLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet UIImageView *photoView;

@end

@implementation ViewController

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
    
    // Update the UI state based on the user's authentication status
    if ([AdobeUXAuthManager sharedManager].isAuthenticated)
    {
        [self.authButton setTitle:@"Log Out" forState:UIControlStateNormal];
        
        self.uploadButton.hidden = NO;
    }
    else
    {
        [self.authButton setTitle:@"Log In" forState:UIControlStateNormal];
        
        self.uploadButton.hidden = YES;
    }
}

#pragma mark - UI Actions

- (IBAction)authButtonTouchUpInside
{
    // Authenticate the user if necessary or log them out if they are already authenticated.
    if (![AdobeUXAuthManager sharedManager].isAuthenticated)
    {
        [[AdobeUXAuthManager sharedManager] login:self onSuccess:^(AdobeAuthUserProfile *profile) {
            
            NSLog(@"Successfully logged in. Profile: %@", profile);
            
            [self.authButton setTitle:@"Log Out" forState:UIControlStateNormal];
            self.uploadButton.hidden = NO;
            
        } onError:^(NSError *error) {
            
            NSLog(@"An error occurred on login: %@", error);
        }];
    }
    else
    {
        [[AdobeUXAuthManager sharedManager] logout:^{
            
            NSLog(@"Successfully logged out.");
            
            [self.authButton setTitle:@"Log In" forState:UIControlStateNormal];
            self.uploadButton.hidden = YES;
            self.photoView.image = nil;
            
        } onError:^(NSError *error) {
            
            NSLog(@"An error occurred on logout: %@", error);
        }];
    }
}

- (IBAction)uploadButtonTouchUpInside
{
    UIImagePickerController *imagePickerViewController = [UIImagePickerController new];
    
    // Use the camera, if it is available; otherwise use the photo library.
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        imagePickerViewController.sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    else
    {
        imagePickerViewController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    
    imagePickerViewController.delegate = self;
    
    // Per Apple's recommendation, present the photo library in a popover on iPad.
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad &&
        imagePickerViewController.sourceType != UIImagePickerControllerSourceTypeCamera)
    {
        // Set up the image picker view controller to anchor to the bottom of the upload button.
        CGRect sourceRect = CGRectMake(self.uploadButton.frame.size.width / 2,
                                       self.uploadButton.frame.size.height,
                                       0, 0);
        
        imagePickerViewController.modalPresentationStyle = UIModalPresentationPopover;
        imagePickerViewController.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionAny;
        imagePickerViewController.popoverPresentationController.sourceView = self.uploadButton;
        imagePickerViewController.popoverPresentationController.sourceRect = sourceRect;
    }
    
    [self presentViewController:imagePickerViewController animated:YES completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    // Dismiss the image picker controller.
    [self dismissViewControllerAnimated:YES completion:nil];

    // Get the type of the selected asset.
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    
    // Make sure the selected asset is an image type. If not, inform the user.
    //
    // Note that this check is only performed here to keep the demo brief and simple. Normally, any
    // file type can be uploaded to the Creative Cloud.
    if (CFStringCompare((CFStringRef)mediaType, kUTTypeImage, 0) != kCFCompareEqualTo)
    {
        NSString *message = @"The file you've selected isn't an image file (is it a video "
            "perhaps?) For the purposes of this demo, please select an image file.";
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Image"
                                                                                 message:message
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                           style:UIAlertActionStyleDefault
                                                         handler:NULL];
        
        [alertController addAction:okAction];
        
        [self presentViewController:alertController animated:YES completion:nil];
        
        return;
    }
    
    // Grab the image object and set the view so we can see it.
    UIImage *selectedImage = info[UIImagePickerControllerOriginalImage];
    self.photoView.image = selectedImage;
    
    // Conver the selected asset into a JPEG file and write it in a temporary file to make it
    // easier to access.
    NSData *selectedImageData = UIImageJPEGRepresentation(selectedImage, 1);
    NSString *temporaryImagePathString = [NSTemporaryDirectory() stringByAppendingPathComponent:@"temporary-selected-image.jpg"];
    
    // Write the image data into a temporary file.
    NSError *error = nil;
    BOOL success = [selectedImageData writeToFile:temporaryImagePathString
                                          options:NSDataWritingAtomic
                                            error:&error];
    
    if (success)
    {
        // Get the root directory. This is where the image will be uploaded. Any other path within
        // a user's Creative Cloud account can be created here.
        AdobeAssetFolder *rootFolder = [AdobeAssetFolder root];
        
        // Construct a URL object to the temporary image file we exported.
        NSURL *temporaryImagePath = [NSURL fileURLWithPath:temporaryImagePathString];
        
        // Reset the UI
        self.uploadingLabel.hidden = NO;
        
        self.progressView.progress = 0;
        self.progressView.hidden = NO;
        
        // Now upload the file. The name of the uploaded file will be "Uploaded Image". It will
        // be uploaded to `rootFolder` which is the root directory within the users's files
        // storage. Since we're uploading a JPEG image, we've specified the type as well. Also
        // we've specified a collision policy which will prevent existing files from being
        // overwritten. The specified policy will append a unique number to the file name (i.e.
        // "Uploaded Image") to the newly uploaded file, if there already exists a file with the
        // same name.
        [AdobeAssetFile create:@"Uploaded Image"
                        folder:rootFolder
                      dataPath:temporaryImagePath
                   contentType:kAdobeMimeTypeJPEG
               collisionPolicy:AdobeAssetFileCollisionPolicyOverwriteWithNewVersion
                 progressBlock:^(double fractionCompleted)
        {
            NSLog(@"Uploaded %f%%", fractionCompleted);
            
            self.progressView.progress = fractionCompleted;
        }
                  successBlock:^(AdobeAssetFile *file)
        {
            NSLog(@"Successfully uploaded.");
            
            self.uploadingLabel.hidden = YES;
            self.progressView.hidden = YES;
            
            NSString *message = [NSString stringWithFormat:@"The selected file was successfully "
                                 "uploaded to Creative Cloud at \n\n'%@'",
                                 [file.href stringByRemovingPercentEncoding]];
            
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"File Uploaded"
                                                                                     message:message
                                                                              preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                               style:UIAlertActionStyleDefault
                                                             handler:NULL];
            
            [alertController addAction:okAction];
            
            [self presentViewController:alertController animated:YES completion:nil];
        }
             cancellationBlock:^
        {
            NSLog(@"Upload operation was cancelled.");
            
            self.uploadingLabel.hidden = YES;
            self.progressView.hidden = YES;
        }
                    errorBlock:^(NSError *error)
        {
            NSLog(@"An error occurred while uploading: %@", error);
            
            self.uploadingLabel.hidden = YES;
            self.progressView.hidden = YES;
        }];
    }
    else
    {
        if (error != nil)
        {
            NSLog(@"An error occurred when creating the temporary image file: %@", error);
        }
        else
        {
            NSLog(@"An unknown error occurred when creating the temporary image file.");
        }
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
