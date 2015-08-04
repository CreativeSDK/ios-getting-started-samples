# Share Menu UI Component

While the Creative SDK provides access to multiple features related to Creative Cloud products, sometimes a user needs to work on a file on his own machine. The Creative SDK provides a simple way for your mobile users to directly open assets on their desktop machines from the application itself. In this guide, we look at how this is done and how you can connect your mobile application to the full power of Creative Cloud on the desktop.

There are two ways to send data to a desktop application:

+ Directly from your code, based on a user action, like a click on your own Share button.
+ Using a Share menu UI control that ships with the SDK. The example in this guide uses this.

You can specify which application to open with the shared data. Three applications support this feature: Photoshop, Illustrator, and InDesign.

## Contents

- [Prerequisites](#prerequisites)
- [Integration](#integration)
- [Class Reference](#reference)

<a name="prerequisites"></a>
## Prerequisites

+ This guide assumes that you've already read the <a href="/articles/gettingstarted/index.html">Getting Started</a> guide.
+ For a complete list of framework dependencies, see the <a href="/articles/dependencies/index.html">Framework Dependencies</a> guide.

<a name="integration"></a>
## Integration

*You can find the complete code for this guide in <a href="https://github.com/CreativeSDK/ios-getting-started-samples" target="_blank">GitHub</a>.*

The primary class for this feature is `AdobeShareMenu`, which has one main method, `showIn:fromRect:permittedArrowDirections`. This method lets you show the menu and provide basic layout settings but not customize the menu. When used, it presents a standard set of options:

<img src="https://aviarystatic.s3.amazonaws.com/creativesdk/ios/sharemenu/shotofmenu.png"/>

Two of the options are simple and do not open additional screens: **Send to Photoshop** and **Send to Illustrator** simply send the file to the user's machine and open the appropriate application.

The other three options are explained below.

### Get Feedback

This option lets the user upload a file to ask for feedback about it. Clicking this reveals a UI to add notes and tags, and mark the file for adult content:

<img src="https://aviarystatic.s3.amazonaws.com/creativesdk/ios/sharemenu/request_info1.png" />

Once the user enters information and submits the form, the file is posted to their Behance network:

<img src="https://aviarystatic.s3.amazonaws.com/creativesdk/ios/sharemenu/request_info2.png" />

Here is the file on the Behance site:

<img src="https://aviarystatic.s3.amazonaws.com/creativesdk/ios/sharemenu/request_info3.png" />

### Copy Image to Creative Cloud

This option copies an image to the Creative Cloud. No feedback is provided in the application, but you can provided your own feedback by listening for the event that occurs when the share is complete. (More on the events momentarily.) The image appears in the user's Creative Cloud **Recent** folder:

<img src="https://aviarystatic.s3.amazonaws.com/creativesdk/ios/sharemenu/copy_test.png" />

### Share

This option opens up a new menu:

<img src="https://aviarystatic.s3.amazonaws.com/creativesdk/ios/sharemenu/share.png" />

This is like other share items on mobile devices. It lets the user pick other options for the data.

Now we will describe a simple application to demonstrate the Share option.

For our example, we add an image picker that lets the user take a new picture or select one from the gallery. (By default, it uses the camera if it exists.) Once selected, the image is added to the layout, and the Share menu UI is bound to it.

Below is the code run by the image picker after the user selects an image. It handles adding a tap listener and calling the method that runs the Share menu class:

    + (void)imagePickerController:(UIImagePickerController *)picker
      didFinishPickingMediaWithInfo:(NSDictionary *)info {

       UIImage *img = info[UIImagePickerControllerOriginalImage];
       [((RKCView *)self.view) selectedImgView].image = img;

       //make imageview tappable
       UITapGestureRecognizer *tapRecog = [[UITapGestureRecognizer alloc] initWithTarget:self
         action:@selector(doShareMenu:)];
       [[((RKCView *)self.view) selectedImgView] addGestureRecognizer:tapRecog];

       [self dismissViewControllerAnimated:YES completion:nil];

    }

Next is `doShareMenu`:

    + (void)doShareMenu:(UIGestureRecognizer *)gr {
       AdobeShareMenu *share = [AdobeShareMenu sharedInstance];
       share.delegate = self;

       CGRect imageBounds = [((RKCView *)self.view) selectedImgView].bounds;

       [share
        showIn:self.view
        fromRect:imageBounds
        permittedArrowDirections:UIPopoverArrowDirectionAny];

    }

First we get the shared instance of the `AdobeShareMenu` class. We assign the current view controller as the delegate, get our image bounds, and run the showIn method. This lets the user select an image and click it to open the menu:

<img src="https://aviarystatic.s3.amazonaws.com/creativesdk/ios/sharemenu/app1.png" />

The delegate returned from the `AdobeShareMenu` class is an instance of AdobeShareMenuDelegate. The methods represent aspects of the share lifecycle. Developers can modify the bits before they are sent to the desktop or Behance, or they can update the application with status messages. At least five methods are required:

+ `willPresentInView` 
+ `shareMenuDismissed` 
+ `shareItemsForDestination` 
+ `shareStarted` 
+ `shareCompletedItems` 

You can stub out four of these (leave them blank), but `shareItemsForDestination` must be implemented completely. Here is how our sample application uses that method:

    + (NSArray *)shareItemsForDestination:(NSString *)shareDestination {
       NSDictionary *shareItem = @{kAdobeShareMenuItemKeyName:@"foo.jpg",
         kAdobeShareMenuItemKeyImage:[((RKCView *)self.view) selectedImgView].image};
       NSArray *items = [[NSArray alloc] initWithObjects:shareItem, nil];
       return items;
    }

For the share functionality to work, you must explicitly tell the API which items are being shared. To do this, create an array of `NSDictionary` items that contain information about the file. For the required values for this `NSDictionary`, see the `AdobeShareMenuDelegate` documentation. There are two cases, sending a `UIImage` (as we did in this example) or sending `NSData`.

<a name="reference"></a>
## Class Reference

+ [AdobeShareMenu](/Classes/AdobeShareMenu.html)
