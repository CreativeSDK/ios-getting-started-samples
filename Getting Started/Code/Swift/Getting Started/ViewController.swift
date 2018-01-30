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
 */

import UIKit

class ViewController: UIViewController
{
    // TODO: Please update the ClientId and Secret to the values provided by creativesdk.com
    private let kCreativeSDKClientId = "Change me"
    private let kCreativeSDKClientSecret = "Change me"
    private let kCreativeSDKRedirectURLString = "Change me"
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Set the client ID and secret values so the CSDK can identify the calling app. The three
        // specified scopes are required at a minimum.
        AdobeUXAuthManager.sharedManager().setAuthenticationParametersWithClientID(kCreativeSDKClientId,
                                                                                   clientSecret: kCreativeSDKClientSecret,
                                                                                   additionalScopeList: [
                                                                                    AdobeAuthManagerUserProfileScope,
                                                                                    AdobeAuthManagerEmailScope,
                                                                                    AdobeAuthManagerAddressScope])
        
        // Also set the redirect URL, which is required by the CSDK authentication mechanism.
        AdobeUXAuthManager.sharedManager().redirectURL = NSURL(string: kCreativeSDKRedirectURLString)
        
        if (AdobeUXAuthManager.sharedManager().authenticated)
        {
            print("The user has already been authenticated.")
            
            nameLabel.text = AdobeUXAuthManager.sharedManager().userProfile.displayName
            emailLabel.text = AdobeUXAuthManager.sharedManager().userProfile.email
            
            loginButton.setTitle("Log Out", forState: .Normal)
        }
    }
    
    @IBAction func loginButtonTouchUpInside()
    {
        if (AdobeUXAuthManager.sharedManager().authenticated)
        {
            AdobeUXAuthManager.sharedManager().logout(
                {
                    [unowned self]() -> Void in
                    
                    print("User was successfully logged out.")
                    
                    self.nameLabel.text = "<Not Logged In>"
                    self.emailLabel.text = "<Not Logged In>"
                    
                    self.loginButton.setTitle("Log In", forState: .Normal)
                },
                onError:
                {
                    (error: NSError!) -> Void in
                    
                    print("There was a problem logging out: \(error)")
                }
            )
        }
        else
        {
            AdobeUXAuthManager.sharedManager().login(self,
                                                     onSuccess:
                {
                    [unowned self] (profile: AdobeAuthUserProfile!) -> Void in
                    
                    print("Successfully logged in. User profile: \(profile)")
                    
                    self.nameLabel.text = profile.displayName
                    self.emailLabel.text = profile.email
                    
                    self.loginButton.setTitle("Log Out", forState: .Normal)
                },
                                                     onError:
                {
                    (error: NSError!) -> Void in
                    
                    print("There was a problem logging in: \(error)")
                }
            )
        }
    }
}
