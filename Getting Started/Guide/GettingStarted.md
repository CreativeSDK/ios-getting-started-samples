# Getting Started with the iOS Creative SDK

The Creative SDK lets you build applications that integrate with the Creative Cloud and leverage the power of our Creative Cloud offerings to benefit your users. From simply letting them import from and save to their Creative Cloud storage, to using innovative Photoshop APIs via your application, the Creative SDK will help you expand the features of your application by using the Adobe platform.

This guide discusses how to set up the iOS Creative SDK, then steps through a simple tutorial about [Integrating the Authentication Component](#integrating_auth), a necessary part of all Creative SDK workflows.

## Contents

- [Prerequisites](#prerequisites)
- [Registering Your Application](#register_application)
- [Configuring XCode](#configure_xcode)
- [Integrating the Authentication Component](#integrating_auth)
- [What’s Next?](#whats_next)
- [Explore iOS Creative SDK Documentation](#explore)

<a name="prerequisites"></a>
## Prerequisites

+ Before you can work with the Creative SDK, you must register your application and get Client ID and Client Secret values. For details, see [Registering Your Application](#register_application). 
+ To get the iOS SDK, go to the [Downloads page](https://creativesdk.adobe.com/downloads.html) , download the ZIP files, and extract them to a location you will remember. The ZIP files contain all the frameworks in the Creative SDK. To learn more about each framework, see the [Framework Dependencies](../18_Framework_Dependencies/18_Framework_Dependencies.htm#XREF_98693_Framework)   guide. The classes used in this guide are in the `AdobeCreativeSDKCore.framework` library.

The following software is required:

+ [OS X](https://www.apple.com/osx/)
+ [XCode](https://developer.apple.com/xcode/) 6.2 or higher — See  [Configuring XCode](#configure_xcode).
+ iOS 7 or higher

<a name="register_application"></a>
## Registering Your Application

To register your application, follow these steps:

1. Sign in. (If needed, register for an account)
2. Go to the My Apps  page, [https://creativesdk.adobe.com/myapps.html](https://creativesdk.adobe.com/myapps.html).
3. Click + NEW APPLICATION.
4. Fill out form, then click ADD APPLICATION.

**Important: As part of registering your application, you are given a Client ID and Secret. Write these down and save them. You will need them in the future, and this is the only time you can see them.**

<a name="configure_xcode"></a>
## Configuring XCode

To use the Creative SDK, make the following Xcode configuration changes:

1. Add linker flags:

    + Select Build Settings  > Linking  > Other Linker Flags.  
    (If you do not see this setting, see if Basic  is selected in XCode and click All instead.)
    + Double-click the empty area to the right. An empty window pops up, for you to add or delete values.
    + Click the +  (plus sign) button, and add a new value, -ObjC :

    <img src="https://aviarystatic.s3.amazonaws.com/creativesdk/addinglinker.jpg" />

    After the new value is added, the Other Linker Flags  area of the screen looks like this:

    <img src="https://aviarystatic.s3.amazonaws.com/creativesdk/addedlinker.jpg" />

2. Copy bundle resources:

    + Switch to **Build Phases**.
    + Expand **Copy Bundle Resources**.
    + Click the **+** button.
    + Click **Add Other...** 

    + From the location where you extracted the main Creative SDK ZIP file, open `AdobeCreativeSDKCore.framework`, `Resources` , then select `AdobeCreativeSDKCoreResourcesSDK.bundle`:

    <img src="https://aviarystatic.s3.amazonaws.com/creativesdk/addbundle1.jpg "/>

    + Click Open, and the **Choose options for adding these files** window will appear:

    <img src="https://aviarystatic.s3.amazonaws.com/creativesdk/addbundle2.jpg "/>

    + Under **Folders**, select **Create groups for any added folders**.
    + Under **Destination**, be sure you do not select **Copy items into destination group’s folder**.
    + Click **Finish**.

3. Link binary with libraries:

    + Back on Build Phases , select Link Binary with Libraries  and click the + button.
    + Click Add Other...  
    + Go to where you unzipped the framework, and select the AdobeCreativeSDKCore.framework folder:

    <img src="https://aviarystatic.s3.amazonaws.com/creativesdk/linkbinary1.jpg "/>
    + Click Open . After the addition, you will see this:

    <img src="https://aviarystatic.s3.amazonaws.com/creativesdk/linkbinary2.jpg "/>

4. Add binaries:

    + Back on Build Phases , select Link Binary with Libraries  and click the + button.
    + You do not use the Add Other...  button, but instead simply type in the filter area to select the binary you need. Add these binaries: libc++.dylib , libz.dylib,  MobileCoreServices.framework  and SystemConfiguration.framework .

    The screenshot below shows what you should have when you are done:

    <img src="https://aviarystatic.s3.amazonaws.com/creativesdk/linkbinary3.jpg"/>

    Your setup is done. Now you can open any of your project files (for example, your main AppDelegate.m ) and import the framework:

    `#import <AdobeCreativeSDKCore/AdobeCreativeSDKCore.h>`

    If Xcode does not auto-complete the framework name, check the setup steps above to ensure you did everything necessary.

5. Add preprocessor macro (for build 0.1.2118 ONLY):
    + Back on Build Settings , scroll down to Apple LLVM x.x Preprocessing. Click on the Preprocessor Macros property and add the following.

    USE_CSDK_COMPONENTS


<a name="integrating_auth"></a>
## Integrating the Authentication Component

*You can find the complete code for this guide in <a href="https://github.com/CreativeSDK/ios-getting-started-samples" target="_blank">GitHub</a>.*

Authentication is part of every Creative SDK workflow: every action performed requires a logged-in user.

First, we create a new view controller, RKCTestViewController . We create a corresponding UIView ; following the previous naming pattern, we name it RKCTestView . Open up RKCTestView.m  and begin by adding code to drop in a UIButton :

    //  
    //  RKCTestView.m  
    //  TestCCSDK  
    //  

    #import "RKCTestView.h"  
    #import "RKCTestViewController.h"  

    @implementation RKCTestView  

    + (id)initWithFrame:(CGRect)frame  
    {  
     self = [super initWithFrame:frame];  
     if (self) {  

     _loginButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];  
     [_loginButton setTitle:@"Login" forState:UIControlStateNormal];  
     _loginButton.frame = CGRectMake(0, 0, frame.size.width, 100);  
     [_loginButton addTarget:(RKCTestViewController *)self.superview   
    action:@selector(doLogin) forControlEvents:UIControlEventTouchUpInside];  
     [self addSubview:_loginButton];  

     }  
     return self;  
    }  

    /*  
    // Only override drawRect: if you perform custom drawing.  
    // An empty implementation adversely affects performance during animation.  
    + (void)drawRect:(CGRect)rect  
    {  
     // Drawing code  
    }  
    */  

    @end

    Most of this is standard, but notice the button’s target. It causes an event, doLogin , which we will define within our controller. In RKCTestView.h , expose a property for the UIButton :

    //  
    //  RKCTestView.h  
    //  TestCCSDK  
    //  
    //  Created by Raymond Camden on 4/3/14.  
    //  Copyright (c) 2014 Raymond Camden. All rights reserved.  
    //  

    #import <UIKit/UIKit.h>  

    @interface RKCTestView : UIView  

    @property UIButton *loginButton;  

    @end

    Now let's look at our ViewController:

    //
    //  RKCTestViewController.m
    //  TestCCSDK
    //

    #import "RKCTestViewController.h"
    #import "RKCTestView.h"
    #import <AdobeCreativeSDKCore/AdobeCreativeSDKCore.h>

    @implementation RKCTestViewController

    - (void)loadView
    {

    CGRect frame = [UIScreen mainScreen].bounds;

    RKCTestView *tv = [[RKCTestView alloc] initWithFrame:frame];

    self.view = tv;

    // Please update the ClientId and Secret to the values provided by creativesdk.com or from Adobe
    static NSString* const CreativeSDKClientId = @"changeme";
    static NSString* const CreativeSDKClientSecret = @"changemetoo";

    [[AdobeUXAuthManager sharedManager] setAuthenticationParametersWithClientID:CreativeSDKClientId clientSecret:CreativeSDKClientSecret enableSignUp:true];

    //The authManager caches our login, so check on startup
    BOOL loggedIn = [AdobeUXAuthManager sharedManager].authenticated;
    if(loggedIn) {
    NSLog(@"We have a cached logged in");
    [((RKCTestView *)self.view).loginButton setTitle:@"Logout" forState:UIControlStateNormal];
    AdobeAuthUserProfile *up = [AdobeUXAuthManager sharedManager].userProfile;
    NSLog(@"User Profile: %@", up);
    }

    }


    - (void)doLogin {

    //Are we logged in?
    BOOL loggedIn = [AdobeUXAuthManager sharedManager].authenticated;

    if(!loggedIn) {

    [[AdobeUXAuthManager sharedManager] login:self
    onSuccess: ^(AdobeAuthUserProfile * userProfile) {
    NSLog(@"success for login");
    [((RKCTestView *)self.view).loginButton setTitle:@"Logout" forState:UIControlStateNormal];
    }
    onError: ^(NSError * error) {
    NSLog(@"Error in Login: %@", error);
    }];
    } else {

    [[AdobeUXAuthManager sharedManager] logout:^void {
    NSLog(@"success for logout");
    [((RKCTestView *)self.view).loginButton setTitle:@"Login" forState:UIControlStateNormal];
    } onError:^(NSError *error) {
    NSLog(@"Error on Logout: %@", error);
    }];
    }
    }

    @end


Look at `loadView`. We begin by adding an instance of the view, so we can display the button. Next, we define the Client ID and Client Secret, which you got when you registered the application. The first thing we do with the SDK is to set these values to a `sharedManager`  that our application will use whenever performing SDK actions. For now, ignore the rest of the `loadView`  function; we return to it at the end of this tutorial.

The doLogin method is executed when the user clicks the button on the view. The `sharedManager`  keeps track of current login status, so we can get that value; then, depending on whether the user is logged in, `sharedManager`  performs the appropriate action. The login action has two code blocks, for success and error. The logout action is identical in both cases. Also in both cases, we modify the text of the button to be informative. There are no text fields or anything else UI related; the framework handles the entire login process.

Here is what the application looks like when it loads:

<img src="https://aviarystatic.s3.amazonaws.com/creativesdk/device1.jpg" />

When the user clicks the Login button, the SDK takes over:

<img src="https://aviarystatic.s3.amazonaws.com/creativesdk/device2.jpg" />

The user can login or create a Creative Cloud account, via the SDK.

In addition, the SDK caches the login for approximately 14 days, which means on future visits during that period, users do not have to login again. If you return to the loadView  code, note that we check for this and handle updating the button. We also log the userProfile for the logged-in user.

<img src="https://aviarystatic.s3.amazonaws.com/creativesdk/device3.jpg" />

<a name="whats_next"></a>
## What’s Next?

### Submit Your Application for Review

Adobe must review all applications that use the Creative SDK before they are released. See the guidelines in  [Using the Creative Cloud Badge and Brand](https://creativesdk.adobe.com/docs/ios/#/brandguidelines/index.html)   and the [terms of use](http://wwwimages.adobe.com/content/dam/Adobe/en/legal/servicetou/Creative_SDK-en_US.pdf) . Instructions for submitting your app for review are [here](https://creativesdk.zendesk.com/hc/en-us/articles/204601215-How-to-complete-the-Production-Client-ID-Request).

### Troubleshooting and Support

Articles about common issues are at [help.creativesdk.com](http://help.creativesdk.com), along with a place to submit tickets for bugs, feature requests, and general feedback.

<a name="explore"></a>
## Explore iOS Creative SDK Documentation

Now check out the rest of the Creative SDK documentation:

### Creative Cloud Content Management  

+ [Asset Browser UI](/articles/assetbrowser/index.html)  
+ [Creative Cloud Files API](/articles/files/index.html)  
+ [Lightroom Photos API](/articles/photos/index.html)  
+ [About Creative Cloud Libraries](/articles/libraries/index.html)

### Creative Cloud Content  

+ [Creative Cloud Market UI](/articles/market/index.html)

### Creative Tools  

+ [Image Editor UI](/articles/imageeditor/index.html)  
+ [Color UI](/articles/color/index.html)  

### Creative Cloud Workflows  

+ [Share Menu UI](/articles/sharemenu/index.html)  
+ [Send To Desktop](/articles/sendtodesktop/index.html)  
+ [Behance Publish UI](/articles/behance/index.html)  

### Adobe Labs  

+ [Magic Selection View](/articles/magicselection/index.html)  

### Frameworks  

+ [Framework Dependencies](/articles/dependancies/index.html) 