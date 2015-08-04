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
#import <AdobeCreativeSDKCore/AdobeUXAuthManager.h>
#import <AdobeCreativeSDKCommonUX/AdobeCreativeSDKCommonUX.h>
#import <AdobeCreativeSDKAssetModel/AdobeAssetFile.h>
#import <AdobeCreativeSDKAssetModel/AdobeSelectionAsset.h>
#import <AdobeCreativeSDKAssetModel/AdobeSendToDesktopApplication.h>
#import <AdobeCreativeSDKAssetUX/AdobeUXAssetBrowser.h>
#import <AdobeCreativeSDKDevice/AdobeCreativeSDKDevice.h>
#import <AdobeCreativeSDKDevice/AdobeDevicePenMenuViewController.h>
#import <AdobeCreativeSDKBehance/AdobePublishShareMenu.h>
#import <AdobeCreativeSDKBehance/AdobePublishURLDelegate.h>

@interface RKCViewController () <AdobePublishShareMenuDelegate>

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
        [((RKCView *)self.view).loginButton setTitle:@"Logout" forState:UIControlStateNormal];
        [((RKCView *)self.view).showFileSendButton setHidden:NO];
        
    }
    
}

- (void)doLogin {
    
    //Are we logged in?
    BOOL loggedIn = [AdobeUXAuthManager sharedManager].authenticated;
    
    if(!loggedIn) {
        NSLog(@"ok try to login");
        
        [[AdobeUXAuthManager sharedManager] login:self
                onSuccess: ^(AdobeAuthUserProfile * userProfile) {
                    NSLog(@"success for login");
					[((RKCView *)self.view).loginButton setTitle:@"Logout" forState:UIControlStateNormal];
					[((RKCView *)self.view).showFileSendButton setHidden:NO];
               }
         
				onError: ^(NSError * error) {
                    NSLog(@"Error in Login: %@", error);
				}];
        
    } else {
        
        [[AdobeUXAuthManager sharedManager] logout:^void {
            NSLog(@"success for logout");
            [((RKCView *)self.view).loginButton setTitle:@"Login" forState:UIControlStateNormal];
            [((RKCView *)self.view).showFileSendButton setHidden:YES];
        } onError:^(NSError *error) {
            NSLog(@"Error on Logout: %@", error);
        }];
    }
}

- (void)pickPhoto {
    
    UIImagePickerController *selImage = [[UIImagePickerController alloc] init];
    
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        selImage.sourceType = UIImagePickerControllerSourceTypeCamera;
    } else {
        selImage.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }

    selImage.delegate = self;
    
    [self presentViewController:selImage animated:YES completion:nil];
    
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {

    UIImage *img = info[UIImagePickerControllerOriginalImage];
    [((RKCView *)self.view) selectedImgView].image = img;
    
    //make imageview tappable
    UITapGestureRecognizer *tapRecog = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doShareMenu:)];
    [[((RKCView *)self.view) selectedImgView] addGestureRecognizer:tapRecog];

    
    [AdobeSendToDesktopApplication sendImage:img                                                    toApplication:AdobePhotoshopCreativeCloud
                                    withName:@"SendToDesktopImageFromCSDK"
                                   onSuccess:^{
                                       NSLog(@"opened in Photoshop");
                                   }  onProgress: nil
                              onCancellation: nil
                                     onError:^(NSError *error) {
                                         NSLog(@"error: %@", error);
                                     }];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)doShareMenu:(UIGestureRecognizer *)gr {
    AdobePublishShareMenu *share = [AdobePublishShareMenu sharedInstance];
    share.delegate = self;

    CGRect imageBounds = [((RKCView *)self.view) selectedImgView].bounds;
                  
    [share
     showIn:self.view
     fromRect:imageBounds
     permittedArrowDirections:UIPopoverArrowDirectionAny];
    
}

- (NSArray *)shareItemsForDestination:(NSString *)shareDestination {
    NSDictionary *shareItem = @{kAdobePublishShareMenuItemKeyName:@"foo.jpg",
                                kAdobePublishShareMenuItemKeyImage:[((RKCView *)self.view) selectedImgView].image};
    
    NSArray *items = [[NSArray alloc] initWithObjects:shareItem, nil];
    return items;
}

-(void)willPresentInView:(UIView *)view buttonRect:(CGRect)rect {
    
}

-(void)shareMenuDismissed {
    
}


-(void)shareStarted:(NSString *)destination {
    
}

-(void)shareCompleted:(BOOL)completed items:(NSArray *)sharedItems returnedData:(NSDictionary *)returnedData destination:(NSString *)destination error:(NSError *)error {
    NSLog(@"shareCompleted");
    NSLog(@"Error %@",error);
}

@end
