# Creative Cloud Files API

The Creative SDK provides headless APIs for creating Creative Cloud(CC) Libraries and adding elements to existing libraries. This guide demonstrates how to use these APIs to upload new elements to the CC Libraries.

## Contents

- [Prerequisites](#prerequisites)
- [Upload Files to CC Libraries](#upload)
- [Class Reference](#reference)

<a name="prerequisites"></a>

## Prerequisites

This guide will assume that you have installed all software and completed all of the steps in the following guides:

*   [Getting Started](https://creativesdk.adobe.com/docs/ios/#/articles/gettingstarted/index.html)
*   [Framework Dependencies](https://creativesdk.adobe.com/docs/ios/#/articles/dependencies/index.html) guide.

_**Note:**_

*   _This component requires that the user is **logged in with their Adobe ID**._
*   _Your Client ID must be [approved for **Production Mode** by Adobe](https://creativesdk.zendesk.com/hc/en-us/articles/204601215-How-to-complete-the-Production-Client-ID-Request) before you release your app._

<a name="upload"></a>
## Upload Files to CC Libraries 
The AdobeLibraryManager class is responsible for managing libraries. It's a singleton class that needs to be initialized and started with startup options. It allows to create and delete libraries. The AdobeDesignLibraryUtils class defines supported element types and provides helper methods for creating each element type.

## Setting up Adobe Library Manager
* Observe for login notification
    ```[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(authDidLogin:)
                                                 name:AdobeAuthManagerLoggedInNotification
                                               object:nil];```

* Start AdobeLibraryManager after receiving login notification
    - (void)authDidLogin:(NSNotification *)notification
    {
        // Below is the setup for configure & start AdobeLibraryManager.
        // For more info regarding libraries please refer: https://creativesdk.adobe.com/docs/ios/#/articles/libraries/index.html.
        AdobeLibraryDelegateStartupOptions *startupOptions = [AdobeLibraryDelegateStartupOptions new];

        startupOptions.autoDownloadPolicy = AdobeLibraryDownloadPolicyTypeManifestOnly;
        startupOptions.autoDownloadContentTypes = @[kAdobeMimeTypeJPEG,
                                                    kAdobeMimeTypePNG];
        startupOptions.elementTypesFilter = @[AdobeDesignLibraryColorElementType,
                                              AdobeDesignLibraryColorThemeElementType,
                                              AdobeDesignLibraryCharacterStyleElementType,
                                              AdobeDesignLibraryBrushElementType,
                                              AdobeDesignLibraryImageElementType,
                                              AdobeDesignLibraryLayerStyleElementType];
        syncOnCommit = YES;
        libraryQueue = [NSOperationQueue mainQueue];
        autoSyncDownloadedAssets = NO;

        AdobeLibraryManager *libMgr = [AdobeLibraryManager sharedInstance];
        libMgr.syncAllowedByNetworkStatusMask = AdobeNetworkReachableViaWiFi | AdobeNetworkReachableViaWWAN;

        NSString *rootLibDir = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
        rootLibDir = [rootLibDir stringByAppendingPathComponent:[NSBundle mainBundle].bundleIdentifier];
        rootLibDir = [rootLibDir stringByAppendingPathComponent:@"libraries"];

        NSError *libErr = nil;

        // Start the AdobeLibraryManager.
        [libMgr startWithFolder:rootLibDir andError:&libErr];

        // Register as delegate to get callbacks.
        [libMgr registerDelegate:self options:startupOptions];
    }

## List libraries
    NSArray <AdobeLibraryComposite *> *composites = [[AdobeLibraryManager sharedInstance] libraries];

## Create a new library
    AdobeLibraryComposite *result = [[AdobeLibraryManager sharedInstance] newLibraryWithName:<libraryName> andError:nil];

    // Perform sync so that the added assets are uploaded & a delegate callback is received on sync complete.
    [AdobeLibraryManager sharedInstance] sync];

## Add element to a library
    // Add assets to selected library and perform sync.
    [AdobeDesignLibraryUtils addImage:<assetURL>
                                 name:<assetName>
                              library:<composite>
                                error:nil];

    // Perform sync so that the added assets are uploaded & a delegate callback is received on sync complete.
    [AdobeLibraryManager sharedInstance] sync];

## Clean up and shutdown
* Implement AdobeLibraryDelegate to get callback after the sync finishes.
    - (void)syncFinished
    {
        // AdobeLibraryManager completed sync, hence deregister as delegate so that AdobeLibraryManager shutsdown.
        [[AdobeLibraryManager sharedInstance] deregisterDelegate:self];
    }

## Remove local copies on logout
* Observe for logout notification
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(authDidLogout:)
                                                 name:AdobeAuthManagerLoggedOutNotification
                                               object:nil];

* When user logout, clean up the local files
    - (void)authDidLogout:(NSNotification *)notification
    {
        [AdobeLibraryManager removeLocalLibraryFilesInRootFolder:<rootFolder> withError:nil];

        // Clean up the root folder.
        NSFileManager *fm = [NSFileManager defaultManager];
        [fm removeItemAtPath:[<rootFolder> stringByDeletingLastPathComponent] stringByDeletingLastPathComponent] error:nil];
    }

<a name="reference"></a>
## Class Reference

+ [AdobeLibraryManager](https://creativesdk.adobe.com/docs/ios/#/Classes/AdobeLibraryManager.html)
+ [AdobeLibraryDelegateStartupOptions](https://creativesdk.adobe.com/docs/ios/#/Classes/AdobeLibraryDelegateStartupOptions.html)
+ [AdobeDesignLibraryUtils](https://creativesdk.adobe.com/docs/ios/#/Classes/AdobeDesignLibraryUtils.html)
