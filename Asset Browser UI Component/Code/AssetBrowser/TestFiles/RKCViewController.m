/*
 * Copyright (c) 2015 Adobe Systems Incorporated. All rights reserved.
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
 *
 */

//
//  RKCViewController.m
//  TestFiles
//

#import "RKCViewController.h"
#import "RKCView.h"

#import <AdobeCreativeSDKCore/AdobeCreativeSDKCore.h>  // AdobeUXAuthManager.h
#import <AdobeCreativeSDKCommonUX/AdobeCreativeSDKCommonUX.h>
#import <AdobeCreativeSDKAssetModel/AdobeCreativeSDKAssetModel.h>  // AdobeAssetFile.h & AdobeSelectionAsset.h
#import <AdobeCreativeSDKAssetUX/AdobeCreativeSDKAssetUX.h>  // AdobeUXAssetBrowser.h

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
        AdobeAuthUserProfile *up = [AdobeUXAuthManager sharedManager].userProfile;
        NSLog(@"User Profile: %@", up);
        [((RKCView *)self.view).showFileChooseButton setHidden:NO];
        
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
					[((RKCView *)self.view).showFileChooseButton setHidden:NO];
               }
         
				onError: ^(NSError * error) {
                    NSLog(@"Error in Login: %@", error);
				}];
        
    } else {
        
        [[AdobeUXAuthManager sharedManager] logout:^void {
            NSLog(@"success for logout");
            [((RKCView *)self.view).loginButton setTitle:@"Login" forState:UIControlStateNormal];
            [((RKCView *)self.view).showFileChooseButton setHidden:YES];
        } onError:^(NSError *error) {
            NSLog(@"Error on Logout: %@", error);
        }];
    }
}

- (void)showFileChooser {

    [[AdobeUXAssetBrowser sharedBrowser] popupFileBrowser:^(AdobeSelectionAssetArray *itemSelections) {
        NSLog(@"Selected a file");
        for(id item in itemSelections) {
            
            AdobeAsset *it = ((AdobeSelectionAsset *)item).selectedItem;
            
            NSLog(@"File name %@", it.name);
            //display info about it
            NSString *fileDesc =  [[NSString alloc]
                    initWithFormat:@"File Details\nFile Name: %@\nFile Created: %@\nFile Modified: %@\nFile Size: %lld", it.name, it.creationDate, it.modificationDate, ((AdobeAssetFile *)it).fileSize];

            [((RKCView *)self.view).statusLabel setText:fileDesc];
            
            //If an image, let's draw it locally
            NSString *fileType = ((AdobeAssetFile *)it).type;
            if([fileType isEqualToString:@"image/jpeg" ] || [fileType isEqualToString:@"image/png" ]) {
                NSLog(@"Going to download the image");
                [((AdobeAssetFile *)it) getData:NSOperationQueuePriorityHigh
                                    onProgress:^(double fractionCompleted) {
                                     }
                                    onCompletion:^(NSData *data, BOOL fromcache) {
                                        NSLog(@"Done downloaded");
                                        UIImage *preview = [UIImage imageWithData:data];
                                        UIImageView *uiImage = [[UIImageView alloc] initWithImage:preview];
                                        uiImage.frame = CGRectMake(0, 275, 150, 150);
                                        [self.view addSubview:uiImage];
                                    }
                                    onCancellation:^(void){
                                 
                                    }
                                    onError:^(NSError *error) {
                                     
                                    }
                ];
                
            }
            
        }
    } onError:^(NSError *error)
     {
         //do nothing
         NSLog(@"Error");
     }];

}



@end
