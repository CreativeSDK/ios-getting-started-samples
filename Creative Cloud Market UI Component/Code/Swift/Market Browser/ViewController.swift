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

class ViewController: UIViewController
{
    // TODO: Please update the ClientId and Secret to the values provided by  creativesdk.com
    private let kCreativeSDKClientId = "Change me"
    private let kCreativeSDKClientSecret = "Change me"
    
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var selectionThumbnailImageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Set the client ID and secret values so the SDK can identify the calling app.
        AdobeUXAuthManager.sharedManager().setAuthenticationParametersWithClientID(kCreativeSDKClientId, withClientSecret: kCreativeSDKClientSecret)
    }
    
    override func viewWillAppear(animated: Bool)
    {
        self.logoutButton.hidden = !AdobeUXAuthManager.sharedManager().authenticated
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UI Actions
    @IBAction func displayMarketBrowserButtonTouchUpInside()
    {
        // Create an instance of the Market Browser view controller and display it.
        let mbvc = AdobeUXMarketBrowserViewController(configuration: nil, delegate: self)
        
        self.presentViewController(mbvc, animated: true, completion: nil)
    }
    
    @IBAction func logoutButtonTouchUpInside()
    {
        AdobeUXAuthManager.sharedManager().logout(
            {
                print("Successfully logged out.")
                
                self.logoutButton.hidden = !AdobeUXAuthManager.sharedManager().authenticated
            },
            onError:
            {
                (error: NSError!) in
                
                print("There was an error when logging out: \(error)")
                
                self.logoutButton.hidden = !AdobeUXAuthManager.sharedManager().authenticated
            }
        )
    }
}

extension ViewController : AdobeUXMarketBrowserViewControllerDelegate
{
    func marketBrowserDidSelectAsset(itemSelection: AdobeMarketAsset)
    {
        self.dismissViewControllerAnimated(true, completion: nil)
        
        // Print out some useful information about the selected Market Asset
        print("Selected Market Asset:\n" +
            "\tID: \(itemSelection.assetID)\n\tName: \(itemSelection.name)\n\tLabel: \(itemSelection.label)\n" +
            "\tCategory: \(itemSelection.category.englishName)\n\tCreator: \(itemSelection.creator.displayName)\n" +
            "\tDimensions: \(itemSelection.dimensions)\n\tMIME Type: \(itemSelection.nativeMimeType)")
        
        // Start the activity indicator while we fetch the thumbnail.
        activityIndicator.startAnimating()
        
        // Request a thumbnail for the selected Market Asset. We use the width as the reference 
        // size and the value is the width of our UIImageView. The type of the thumbnail file is 
        // set to PNG which is ideal for displaying. We also set the priority of the network 
        // connection.
        itemSelection.downloadRenditionWithDimension(.Width,
                                                     size: UInt(CGRectGetWidth(selectionThumbnailImageView.frame)),
                                                     type: .PNG,
                                                     priority: .Normal,
                                                     progressBlock:
            {
                (completedFraction: Double) in
                
                print(String(format: "Downloading... (%2.f%%)", completedFraction * 100.0))
            },
                                                     successBlock:
            {
                [weak self] (imageData: NSData!, fromCache: Bool) in
                
                let thumbnail = UIImage(data: imageData)
                
                if thumbnail == nil
                {
                    print("Could not create a useable UIImage instance from returned data.")
                }
                else
                {
                    // We have everything we need, so we display the image.
                    self?.selectionThumbnailImageView.image = thumbnail
                }
                
                self?.activityIndicator.stopAnimating()
            },
                                                     cancellationBlock:
            {
                print("Underlying network connection was canceled.")
                
                self.activityIndicator.stopAnimating()
            },
                                                     errorBlock:
            {
                [weak self] (error: NSError!) in
                
                print("An error occurred while downloading a thumbnail for the selected Market Asset \(error)")
                
                self?.activityIndicator.stopAnimating()
            }
        )
    }
    
    func marketBrowserDidEncounterError(error: NSError)
    {
        self.dismissViewControllerAnimated(true, completion: nil)
        
        print("An error occurred in the Market Browser: \(error)")
    }
}
