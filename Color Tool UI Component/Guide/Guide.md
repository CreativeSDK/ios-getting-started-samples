# Color Tool UI Component

The Creative SDK provides a color editing UI popover available on iOS. The color editing UI provides users with a number of color selection methods, including color harmony design, advanced color selection tools, and selection from your Creative Cloud Libraries. 

## Contents

- [Prerequisites](#prerequisites)
- [Adding the Color Tool UI Component into your Project](#project_configuration)
- [Authentication](#authentication)
- [Launching the Color Component](#launching_color)
- [Configuring the Color Component](#configuring_color)
- [Delegate Callbacks and Color changes](#delegates_callbacks)
- [App Themes](#app_themes)
- [Color History Management](#color_history)
- [Sample Project](#sample_project)
- [Class Reference](#class_reference)

<a name="prerequisites"></a>

## Prerequisites

This guide will assume that you have installed all software and completed all of the steps in the following guides:

*   [Getting Started](https://creativesdk.adobe.com/docs/ios/#/articles/gettingstarted/index.html)
*   [Framework Dependencies](https://creativesdk.adobe.com/docs/ios/#/articles/dependencies/index.html) guide.

_**Note:**_

*   _This component requires that the user is **logged in with their Adobe ID**._
*   _Your Client ID must be [approved for **Production Mode** by Adobe](https://creativesdk.zendesk.com/hc/en-us/articles/204601215-How-to-complete-the-Production-Client-ID-Request) before you release your app._

<a name="project_configuration"></a>
### Adding the Color Tool UI Component into your Project

Below you'll find the few steps needed in order to get CreativeSDKColorComponent up and running in your project.  

1. Open your Xcode Project.
2. Import the following frameworks from AdobeCreativeSDKFrameworks.zip into your workspace:
    + AdobeCreativeSDKCore.framework
    + AdobeCreativeSDKAssetModel.framework
    + AdobeCreativeSDKColorComponent.framework
3. Import the following resource bundles into your workspace:
    + AdobeCreativeSDKAssetCore.framework/Resources/AdobeCreativeSDKFoundationResources.bundle
    + AdobeCreativeSDKAssetModel.framework/Resources/AdobeCreativeSDKFoundationResources.bundle
    + AdobeCreativeSDKColorComponent.framework/Resources/AdobeCreativeSDKColorComponenentResources.bundle
4. Go into Build Phases->Link Binary With Libraries and add the frameworks from step 2.
5. Go into Build Phases->Copy Bundle Resources and add the resource bundles from step 3.
6. Go into Build Settings->Other Linker Flags and add the -ObjC flag
7. Build

<a name="authentication"></a>
### Authentication 

Authentication is performed using the CreativeSDKFoundation's AdobeUXAuthManager class. This is required for the color picker's themes and libraries tabs to work correctly.

Please read and follow the <a href="/articles/gettingstarted/index.html">Getting Started</a> guide to implement Authentication with Creative Cloud.

<a name="launching_color"></a>
### Launching the Color Component

After authentication has been configured, you create an instance of the `AdobeColorViewController`, configure it, and either present it modally (iPhone) or in a popover (iPad) with code similar to the following:
        
    self.colorViewController = [[AdobeColorViewController alloc] init];
        
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        self.colorPopoverController = [[UIPopoverController alloc] initWithContentViewController:self.colorViewController];
        
        self.colorPopoverController.delegate = self;

        [self.colorPopoverController presentPopoverFromRect:<button rect>
                                                     inView:<button view>
                                   permittedArrowDirections:UIPopoverArrowDirectionAny
                                                   animated:YES];
    }
    else
    {
        [self presentViewController:self.colorViewController animated:YES completion:nil];
    }

<a name="configuring_color"></a>
### Configuring the Color Component

The color picker currently supports three types of color selection types each associated with a tabbed view. These types are:
    +  The Color Picker View which lets the user design their colors using RGB, CMYK, and color harmony modes 
    +  The Color Themes View which lets the user choose from available community color themes.
    +  The Color Libraries View which lets the user choose colors and color themes from their Creative Cloud Libraries. 

Which views the color view will show to the user can be configured as well as which of those views will display by default. 

    self.colorViewController.initialColorPickerView = AdobeColorPickerColorSelectionWheel;
    self.colorViewController.colorPickerViewOptions = AdobeColorPickerViewPicker | AdobeColorPickerViewLibraries | AdobeColorPickerViewThemes;

In addition to configuring which views to show, you can configure which types of pickers are available in the picker view as well as whether the color picker supports color harmony selection, just single color selection, or both. 

The following code illustrates how to select which pickers are shown. The choices are currently wheel, RGB, and CMYK pickers.

    // configure all three pickers
    self.colorViewController.colorPickerTypes = AdobeColorPickerWheelView | AdobeColorPickerCMYKView | AdobeColorPickerRGBView;
    // show the wheel as the initial view
    self.colorViewController.initialPickerType = AdobeColorPickerWheel;

    // configure just RGB and CMYK
    self.colorViewController.colorPickerTypes = AdobeColorPickerCMYKView | AdobeColorPickerRGBView;
    // show the CMYK picker as the initial view
    self.colorViewController.initialPickerType = AdobeColorPickerCMYK;

The following code snippet shows you how to configure single harmony support and single color support as well as which color harmony to display on first launch:

    // configure both types
    self.colorViewController.harmonyRuleOptions = AdobeColorHarmonyRules | AdobeColorSingleColorRule;
    self.colorViewController.initialHarmonyRule = AdobeColorTriad;

    // configure just single color types
    self.colorViewController.harmonyRuleOptions = AdobeColorSingleColorRule;
    self.colorViewController.initialHarmonyRule = AdobeColorSingleColor;


Finally, the initial color that the picker will show is also configurable:

    self.colorViewController.initialColor = [UIColor redColor];

<a name="delegates_callbacks"></a>
### Delegate Callbacks and Color changes

The color view controller calls its delegate for a few key events using the AdobeColorPickerControllerDelegate protocol.

There are callbacks for when the history is cleared by the user (see Color history management below), when the user updates the color in the UI, and when the modal view is dismissed on the iPhone.

To receive, color updates in the UI, there are two methods you can implement in the AdobeColorPickerControllerDelegate. The first is colorPickerColorChanged which is updated live, every run loop iteration, with the color, and the second is colorPickerColorSet which is updated on user events. For performance reasons, it's best to keep slower settings in the colorPickerColorSet delegate method.

To get live color updates:

    - (void)colorPickerControllerColorChanged:(UIColor *)color
    {
        self.liveColor = color;
    }

For committed color changes, use the currentColor property:

    - (void)colorPickerControllerColorSet:(UIColor *)color
    {
        self.committedColor = color;
    }

Committed changes occur when the user selects the checkmark on iPhone or on user events in the popover/iPad version.

The currently selected color is also available on the color controller object itself:

    self.committedColor = self.colorViewController.currentColor;

<a name="app_themes"></a>
### App Themes

You can specify any number of app specific color themes for the color picker to display in the themes tab. These will show along with the community themes, and are configurable by using the appThemes property on the AdobeColorViewController object.

These themes are AdobeColorTheme objects, and are configurable with an array of UIColor objects like the following:

        AdobeColorTheme *appColorTheme1 = [[AdobeColorTheme alloc]initWithUIColors:@[
                                                        [UIColor redColor],
                                                        [UIColor whiteColor],
                                                        [UIColor blueColor],
                                                        [UIColor yellowColor],
                                                        [UIColor blackColor]
                                    ]];

These can be added to an array and set to the appThemes property. 

    self.colorViewController.appThemes = @[appColorTheme1];

<a name="color_history"></a>
### Color History Management

The color history is entirely managed by the integrating app. The history is updated using the setColorHistory and appendToColorHistory methods.

    // set the color history to a new array
    self.colorHistory = [NSMutableArray array];
    self.colorViewController.colorHistory = self.colorHistory;

    // add items to the color history
    NSArray *newColors = @[color1, color2];
    [self.colorViewController appendToColorHistory:newColors];

    // get the color history array
    NSArray *currentColorHistory = self.colorViewController.colorHistory;

In the UI of the color component, the user is allowed to clear the color history. To handle this use case, you must implement the following method on the object that implements the AdobeColorPickerControllerDelegate protocol:

    - (void)colorPickerColorHistoryCleared
    {
        self.colorHistory = [NSMutableArray array];
        self.colorViewController.colorHistory = self.colorHistory;
    }

In its simplest form, the color history array should be an NSMutableArray implementing a reverse queue, and, although there's no limit, it's best to limit the history to a multiple of 7.

<a name="sample_project"></a>
## Sample Project

You can find a sample project that demonstrates a Color Tool UI integration in the Sample Project zip available on the <a href="https://creativesdk.adobe.com/downloads.html">Downloads</a> page.

<a name="class_reference"></a>
## Class References

See the [AdobeColorViewController](/Classes/AdobeColorViewController.html) class for details on integrating the Color Tool UI within your application.
