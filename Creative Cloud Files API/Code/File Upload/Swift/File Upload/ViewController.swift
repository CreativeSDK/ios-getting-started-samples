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

import Foundation
import CoreFoundation
import MobileCoreServices
import UIKit

class ViewController: UIViewController, UINavigationControllerDelegate
{
    // Note: Please update the ClientId and Secret to the values provided by creativesdk.com
    private let kCreativeSDKClientId = "Change me"
    private let kCreativeSDKClientSecret = "Change me"
    private let kCreativeSDKRedirectURLString = "Change me"
    
    @IBOutlet weak var authButton: UIButton!
    @IBOutlet weak var uploadButton: UIButton!
    @IBOutlet weak var uploadingLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var photoView: UIImageView!
    
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
            authButton.setTitle("Log Out", forState: .Normal)
            uploadButton.hidden = false
        }
        else
        {
            authButton.setTitle("Log In", forState: .Normal)
            uploadButton.hidden = true
        }
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UI Actions
    
    @IBAction func authButtonTouchUpInside()
    {
        // Authenticate the user if necessary or log them out if they are already authenticated.
        if (!AdobeUXAuthManager.sharedManager().authenticated)
        {
            AdobeUXAuthManager.sharedManager().login(self,
                onSuccess:
                {
                    [weak self] (profile: AdobeAuthUserProfile!) -> Void in
                    
                    print("Successfully logged in. Profile: \(profile)")
                    
                    self?.authButton.setTitle("Log Out", forState: .Normal)
                    self?.uploadButton.hidden = false
                },
                onError:
                {
                    (error: NSError!) -> Void in
                    
                    print("An error occurred on login: \(error)")
                }
            )
        }
        else
        {
            AdobeUXAuthManager.sharedManager().logout(
                {
                    [weak self]() -> Void in
                    
                    print("Successfully logged out.")
                    
                    self?.authButton.setTitle("Log In", forState: .Normal)
                    self?.uploadButton.hidden = true
                    self?.photoView.image = nil
                },
                onError:
                {
                    (error: NSError!) -> Void in
                    
                    print("An error occurred on logout: \(error)")
                }
            )
        }
    }
    
    @IBAction func uploadButtonTouchUpInside()
    {
        let imagePickerViewController = UIImagePickerController()
        
        // Use the camera, if it is available; otherwise use the photo library.
        if (UIImagePickerController.isSourceTypeAvailable(.Camera))
        {
            imagePickerViewController.sourceType = .Camera
        }
        else
        {
            imagePickerViewController.sourceType = .PhotoLibrary
        }
        
        imagePickerViewController.delegate = self
        
        // Per Apple's recommendation, present the photo library in a popover on iPad.
        if (UI_USER_INTERFACE_IDIOM() == .Pad && imagePickerViewController.sourceType != .Camera)
        {
            // Set up the image picker view controller to anchor to the bottom of the upload button.
            let sourceRect = CGRectMake(uploadButton.frame.size.width / 2,
                uploadButton.frame.size.height,
                0, 0)
            
            imagePickerViewController.modalPresentationStyle = .Popover
            imagePickerViewController.popoverPresentationController?.permittedArrowDirections = .Any
            imagePickerViewController.popoverPresentationController?.sourceView = uploadButton
            imagePickerViewController.popoverPresentationController?.sourceRect = sourceRect
        }
        
        self.presentViewController(imagePickerViewController, animated: true, completion: nil)
    }
}

// MARK: - UIImagePickerViewControllerDelegate
extension ViewController: UIImagePickerControllerDelegate
{
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject])
    {
        // Dismiss the image picker controller.
        self.dismissViewControllerAnimated(true, completion: nil)
        
        // Get the type of the selected asset.
        let mediaType = info[UIImagePickerControllerMediaType]
        
        // Make sure the selected asset is an image type. If not, inform the user.
        //
        // Note that this check is only performed here to keep the demo brief and simple. Normally, 
        // any file type can be uploaded to the Creative Cloud.
        if (CFStringCompare(mediaType as! CFStringRef, kUTTypeImage, CFStringCompareFlags.CompareCaseInsensitive) != CFComparisonResult.CompareEqualTo)
        {
            let message = "The file you've selected isn't an image file (is it a video perhaps?)" +
                "For the purposes of this demo, please select an image file."
            
            let alertController = UIAlertController(title: "Image", message: message, preferredStyle: .Alert)
            let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            
            alertController.addAction(okAction)
            
            self.presentViewController(alertController, animated: true, completion: nil)
            
            return
        }
        
        // Grab the image object
        let selectedImageObject = info[UIImagePickerControllerOriginalImage]
        
        // Make sure we can convert the selected image object to an UIImage
        guard let selectedImage = selectedImageObject as? UIImage else
        {
            let message = "The file you've selected cannot be used. For the purposes of this " +
                "demo, please select an image file."
            
            let alertController = UIAlertController(title: "Image", message: message, preferredStyle: .Alert)
            let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            
            alertController.addAction(okAction)
            
            self.presentViewController(alertController, animated: true, completion: nil)
            
            return
        }
        
        // Set the view so we can see it.
        photoView.image = selectedImage
        
        // Convert the selected asset into a JPEG file and write it in a temporary file to make it 
        // easier to access.
        let selectedImageData = UIImageJPEGRepresentation(selectedImage, 1)
        let temporaryImagePathString = NSTemporaryDirectory().stringByAppendingPathComponent("temporary-selected-image.jpg")
        
        // Write the image data into a temporary file.
        do
        {
            try selectedImageData?.writeToFile(temporaryImagePathString, options: .AtomicWrite)
            
            // Get the root directory. This is where the image will be uploaded. Any other path 
            // within a user's CreativeCloud account can be created here.
            let rootFolder = AdobeAssetFolder.root()
            
            // Construct a URL object to the temporary image file we exported.
            let temporaryImagePath = NSURL(fileURLWithPath: temporaryImagePathString)
            
            // Reset the UI
            uploadingLabel.hidden = false
            
            progressView.progress = 0
            progressView.hidden = false
            
            AdobeAssetFile.create("Uploaded Image",
                folder: rootFolder,
                dataPath: temporaryImagePath,
                contentType: kAdobeMimeTypeJPEG,
                collisionPolicy: .AppendUniqueNumber,
                progressBlock:
                {
                    [weak self] (fractionCompleted: Double) -> Void in
                    
                    print("Uploaded \(fractionCompleted)%")
                    
                    self?.progressView.progress = Float(fractionCompleted)
                },
                successBlock:
                {
                    [weak self] (file: AdobeAssetFile!) -> Void in
                    
                    print("Successfully uploaded.")
                    
                    self?.uploadingLabel.hidden = true
                    self?.progressView.hidden = true
                    
                    let message = "The selected file was successfully uploaded to Creative Cloud at \n\n '\(file.href.stringByRemovingPercentEncoding!)'"
                    
                    let alertController = UIAlertController(title: "File Uploaded", message: message, preferredStyle: .Alert)
                    let okAlert = UIAlertAction(title: "OK", style: .Default, handler: nil)
                    
                    alertController.addAction(okAlert)
                    
                    self?.presentViewController(alertController, animated: true, completion: nil)
                },
                cancellationBlock:
                {
                    [weak self] () -> Void in
                    
                    print("Upload operation was cancelled.")
                    
                    self?.uploadingLabel.hidden = true
                    self?.progressView.hidden = true
                },
                errorBlock:
                {
                    [weak self] (error: NSError!) -> Void in
                    
                    print("An error occurred while uploading: \(error)")
                    
                    self?.uploadingLabel.hidden = true
                    self?.progressView.hidden = true
                }
            )
        }
        catch let error as NSError
        {
            print("An error occurred when creating the temporary image file: \(error)")
        }
    }
}

// MARK: - Utility extension on String
extension String
{
    func stringByAppendingPathComponent(pathComponent: String) -> String
    {
        return (self as NSString).stringByAppendingPathComponent(pathComponent)
    }
}
