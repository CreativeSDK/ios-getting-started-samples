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

import UIKit

class ViewController: UIViewController, AdobeTypekitFontPickerControllerDelegate, UIPopoverPresentationControllerDelegate
{
    
    let creativeSDKClientID: String = "change me"
    let creativeSDKClientSecret: String = "change me"
    private let typekitFontSize: CGFloat = 18

    @IBOutlet weak var mainViewContainer: UIView!
    @IBOutlet weak var fontStatusLabel: UILabel!
    @IBOutlet weak var fontNameLabel: UILabel!
    @IBOutlet weak var fontStyleLabel: UILabel!
    @IBOutlet weak var textView: TextContainerView!
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Set up Auth
        AdobeUXAuthManager.sharedManager().setAuthenticationParametersWithClientID(creativeSDKClientID,
                                                                                   withClientSecret:creativeSDKClientSecret)
        
        // Change the font size for Typekit fonts
        textView.fontSize = typekitFontSize;
        
        //Add observer for the notification dispatched when Typekit font is changed
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(self.typekitChanged(_:)),
                                                         name: AdobeTypekitChangedNotification,
                                                         object: nil)

        // Add observer for the notification dispatched when a user logged in of Creative Cloud
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(self.handleLogin),
                                                         name: AdobeAuthManagerLoggedInNotification,
                                                         object: nil)

        // Add observer for the notification dispatched when a user logged out of Creative Cloud
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(self.handleLogout),
                                                         name: AdobeAuthManagerLoggedOutNotification,
                                                         object: nil)

        initializeUIAndTypekitManager()
    }
    
    deinit
    {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // MARK: - Private Methods
    
    func initializeUIAndTypekitManager()
    {
        if AdobeUXAuthManager.sharedManager().authenticated
        {
            // Change the label of the login button
            loginButton.setTitle("Log Out of Creative Cloud", forState: .Normal)
            
            // Sync Typekit fonts
            AdobeTypekitManager.sharedInstance().syncFonts()
            
            // Set the font name and the font status
            populateUI(nil)
        }
        else
        {
            // Change the label of the login button
            loginButton.setTitle("Log In to Creative Cloud", forState: .Normal)
        }
    }
    
    func populateUI(reasonFontsChanged: String!)
    {
        // Set the font family and style names in UI labels
        fontNameLabel.text = textView.font?.familyName
        fontStyleLabel.text = textView.fontStyleName
        
        // Set the font status
        updateStatusLabel(reasonFontsChanged)
    }
    
    /**
     * Updates the text view's font and informs the user about the reason the text view's font was
     * changed.
     *
     * - parameter reason: Reason for the udpate.
     */
    func resetTextView(reason: String)
    {
        // Update font in the textView
        textView.resetTypeKitFont()
        
        // Update the font name and the font status
        populateUI(reason)
    }
    
    /**
     * The status label indicates whether a Typekit font is in use. If a Typekit font is in use for 
     * the textView, and the user removes the font from the synced fonts list, the font for the 
     * textView falls back to the defualt one. As the default font is a system font in this demo, 
     * the status label displays "Using default font"
     *
     * - parameter reasonFontsChanged: The reason the font for the text view was changed.
     */
    func updateStatusLabel(reasonFontsChanged: String?)
    {
        if textView.typekitFont == nil || textView.font == textView.defaultFont
        {
            fontStatusLabel.text = "Using default font"
            fontStatusLabel.textColor = UIColor.redColor()
            
            if reasonFontsChanged != nil
            {
                let previousString: String = fontStatusLabel.text!

                // See definition of kTypekitFontsChangedReasonExpiring for more information
                if reasonFontsChanged == kTypekitFontsChangedReasonExpiring
                {
                    fontStatusLabel.text = previousString.stringByAppendingString(", font is expired")
                }
                else
                {
                    fontStatusLabel.text = previousString.stringByAppendingString(", font was updated")
                }
            }
        }
        else
        {
            fontStatusLabel.text = "Using Typekit font"
            fontStatusLabel.textColor = UIColor.greenColor()
        }
    }
    
    func handleLogin()
    {
        initializeUIAndTypekitManager()
    }
    
    func handleLogout()
    {
        initializeUIAndTypekitManager()
    }

    // MARK: - Button actions
    
    @IBAction func loginButtonTouchUpInside()
    {
        if AdobeUXAuthManager.sharedManager().authenticated
        {
            AdobeUXAuthManager.sharedManager().logout(
                {
                    (void) in
                    
                    print("Logged out successfully from Creative Cloud")
                },
                onError:
                {
                    (error: NSError!) in
                    
                    print("Error logging out = \(error)")
                }
            )
        }
        else
        {
            AdobeUXAuthManager.sharedManager().login(self,
                onSuccess:
                {
                    (profile: AdobeAuthUserProfile!) in
                    
                    print("Logged in successfully to Creative Cloud")
                },
                onError:
                {
                    (error: NSError!) in
                    
                    print("Error logging out = \(error)")
                }
            )
        }
    }
    
    @IBAction func launchFontPickerButtonTouchUpInside(button: UIButton)
    {
        // Initialize Font Picker
        let fontPickerController = AdobeTypekitFontPickerController()
        fontPickerController.pickerDelegate = self
        fontPickerController.currentFont = AdobeTypekitFont(name: textView.font!.fontName)
        fontPickerController.pickerType = .Families
        fontPickerController.modalPresentationStyle = .Popover
        
        // Present Font Picker as a popover
        let popoverPresentationController = fontPickerController.popoverPresentationController!
        popoverPresentationController.backgroundColor = .whiteColor()
        popoverPresentationController.sourceRect = button.bounds
        popoverPresentationController.sourceView = button
        popoverPresentationController.delegate = self
        popoverPresentationController.permittedArrowDirections = .Any
        
        self.presentViewController(fontPickerController, animated: true, completion: nil)
        
        // Exit edit mode to resume editing after Font Browser is used
        self.textView.endEditing(true)
    }
    
    // MARK: - UIAdaptivePresentationControllerDelegate
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController,
                                                            traitCollection: UITraitCollection) -> UIModalPresentationStyle
    {
        // Use font picker as popup style for both iphone and ipad
        return .None
    }
    
    // MARK: - AdobeTypekitFontPickerControllerDelegate
    
    func fontPicker(controller: AdobeTypekitFontPickerController!,
                    didFinishPickingFont typekitFont: AdobeTypekitFont!)
    {
        // Apply the selected Typekit font to the text view
        self.textView.typekitFont = typekitFont
        
        // Update the labels of the font family and style names
        self.populateUI(nil)
    }
    
    // MARK: - Notification handler
    
    /**
     * Handle Typekit fonts that are removed or added back while syncing.
     *
     * - parameter notification: The notification object that contains more information about the 
     *                           sync process.
     */
    func typekitChanged(notification: NSNotification)
    {
        dispatch_async(dispatch_get_main_queue())
        {
            if self.textView.typekitFont == nil
            {
                // Do nothing when a Typekit font has never been applied
                return
            }
            
            // Get the arrays of added and removed Typekit IDs
            let userInfo: Dictionary<String, AnyObject> = notification.userInfo as! Dictionary<String, AnyObject>
            let added: [String] = (userInfo[kTypekitFontsAddedKey] ?? [String]() as [String]) as! [String]
            let removed: [String] = (userInfo[kTypekitFontsRemovedKey] ?? [String]()) as! [String]
            
            // Get the reason why fonts are changed
            let fontsChangedReasonUI: Dictionary<String, AnyObject!> = notification.userInfo as! Dictionary<String, AnyObject!>
            let fontsChangedReason: String! = fontsChangedReasonUI[kTypekitFontsChangedReasonKey] as! String
            
            var refreshTextView = false
            var downloadNewFonts = false
            
            // Id of the typekit font that is added, if any.
            var typekitFontId: String? = nil
            
            // Determine which text view objects are affected by removing or adding back typekit 
            // fonts. Also determine which text view objects need to download Typekit fonts
            let typekitIdString: String! = self.textView.typekitFont.typekitId
            
            if typekitIdString.characters.count > 0
            {
                // When a Typekit font is added, the font needs to be downloaded, then the text 
                // view needs to be refreshed later
                let addedUsedByTextViewObject: Bool = added.contains(typekitIdString)
                
                if (addedUsedByTextViewObject)
                {
                    downloadNewFonts = true
                    typekitFontId = typekitIdString
                }
                
                // When a Typekit font is removed, the text view needs only to be refreshed
                let removedUsedByTextViewObject: Bool = removed.contains(typekitIdString)
                
                if removedUsedByTextViewObject
                {
                    refreshTextView = true
                }
            }
            
            // Download any Typekit fonts that are added. After a successful download, refresh the 
            // text views affected by adding back Typekit fonts.
            if downloadNewFonts && typekitFontId?.characters.count > 0
            {
                // Request that this font be downloaded and registered
                AdobeTypekitFont.supplyMissingFont(typekitFontId)
                {
                    [weak self] (psFontName: String!, error: NSError!) in
                    
                    dispatch_async(dispatch_get_main_queue(),
                    {
                        if error != nil
                        {
                            print("error downloading Typekit fonts = \(error)")
                        }
                        else
                        {
                            // Refresh affected text view objects
                            if self?.textView.typekitFont.fontName == psFontName
                            {
                                self?.resetTextView(fontsChangedReason)
                            }
                        }
                    })
                }
            }
            
            // Refresh the text view objects affectecd by removing Typekit fonts
            if refreshTextView
            {
                self.resetTextView(fontsChangedReason)
            }
        }
    }
}
