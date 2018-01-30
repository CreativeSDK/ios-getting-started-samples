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
    // TODO: Please update the client ID and secret values to match the ones provided by 
    // creativesdk.com
    private let kCreativeSDKClientId = "Change me"
    private let kCreativeSDKClientSecret = "Change me"
    private let kCreativeSDKRedirectURLString = "Change me"
    
    @IBOutlet private weak var psdFileNameLabel: UILabel!
    @IBOutlet private weak var tableView: UITableView!
    
    var psdFile: AdobeAssetPSDFile?
    var selectedLayers: Array<AdobePSDLayerNode>!
    
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
        
        // Reset the table view margins
        tableView.layoutMargins = UIEdgeInsetsZero
    }
    
    @IBAction
    func pickPSDFileButtonTouchUpInside()
    {
        // Only show the Files datasource.
        let dataSourceFilter = AdobeAssetDataSourceFilter(dataSources: [AdobeAssetDataSourceFiles], filterType: .Inclusive)
        
        // Only allow PSD file to be selected.
        let mimeTypeFilter = AdobeAssetMIMETypeFilter(MIMETypes: [kAdobeMimeTypePhotoshop], filterType: .Inclusion)
        
        // Create the configuration object and specify that PSD layer extraction (and multiple 
        // selection of those layers) should be enabled.
        let configuration = AdobeUXAssetBrowserConfiguration()
        configuration.dataSourceFilter = dataSourceFilter
        configuration.mimeTypeFilter = mimeTypeFilter
        configuration.options = AdobeUXAssetBrowserOption.EnablePSDLayerExtraction.rawValue | AdobeUXAssetBrowserOption.EnableMultiplePSDLayerSelection.rawValue
        
        // Create an instance of the Asset Browser view controller
        let assetBrowserViewController = AdobeUXAssetBrowserViewController(configuration: configuration, delegate: self)
        
        // Present the Asset Browser view controller
        self.presentViewController(assetBrowserViewController, animated: true, completion: nil)
    }
}

// MARK: - UITableViewDataSource
extension ViewController: UITableViewDataSource
{
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return selectedLayers?.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! LayerTableViewCell
        
        let layer = selectedLayers[indexPath.row]
        var type = ""
        
        switch layer.type
        {
            case AdobePSDLayerNodeType.RGBPixels:
                type = "RGB"
            
            case AdobePSDLayerNodeType.SolidColor:
                type = "Solid Color"
                
            case AdobePSDLayerNodeType.Group:
                type = "Layer Group"
                
            case AdobePSDLayerNodeType.Adjustment:
                type = "Adjustment"
            
            default:
                type = "Unknown"
        }
        
        cell.layerId = layer.layerId
        cell.layerInformation = "Selected Layer: \(indexPath.row)\n" +
            "Layer name: \(layer.name)\n" +
            "Type: \(type)\n" +
            "Layer ID: \(layer.layerId)\n" +
            "Layer Index: \(layer.layerIndex)\n" +
            "Visible: \(layer.visible)"
        
        psdFile?.downloadRenditionForLayerID(layer.layerId,
            layerCompID: nil,
            renditionType: .PNG,
            dimensions: CGSize(width: 120, height: 0),
            requestPriority: .High,
            progressBlock: nil,
            successBlock:
            {
                (imageData: NSData!, fromCache: Bool) -> Void in
                
                if cell.layerId == layer.layerId
                {
                    let image = UIImage(data: imageData)
                    
                    cell.thumbnailImage = image
                }
            },
            cancellationBlock:
            {
                print("Layer rendition cancelled for layer: \(layer)")
            },
            errorBlock:
            {
                (error: NSError!) -> Void in
                
                print("An error occurred when fetching the rendition for layer: \(layer)")
            }
         )
        
        return cell
    }
}

// MARK: - AdobeUXAssetBrowserViewControllerDelegate
extension ViewController : AdobeUXAssetBrowserViewControllerDelegate
{
    func assetBrowserDidSelectAssets(itemSelections: [AdobeSelectionAsset])
    {
        // Dismiss the Asset Browser view controller.
        self.dismissViewControllerAnimated(true, completion: nil)
        
        // Make sure something was selected.
        let itemSelection = itemSelections.first
        
        // Make sure the selected asset is a PSD selection.
        guard let psdSelection = itemSelection as? AdobeSelectionAssetPSDFile else
        {
            return
        }
        
        // Now grab the actual PSD item that was selected.
        guard let psdFile = psdSelection.selectedItem as? AdobeAssetPSDFile else
        {
            return
        }
        
        self.psdFileNameLabel.text = "PSD File: \(psdFile.name)"
        self.psdFile = psdFile
        
        // Grab all the selected layers
        let layerSelections = psdSelection.layerSelections
        var selectedLayers: Array<AdobePSDLayerNode> = []
        
        for psdLayerSelection in layerSelections
        {
            selectedLayers.append((psdLayerSelection as! AdobeSelectionPSDLayer).layer)
        }
        
        self.selectedLayers = selectedLayers
        
        // Reload the table view data
        self.tableView.reloadData()
        self.tableView.hidden = false
    }
    
    func assetBrowserDidEncounterError(error: NSError)
    {
        // Dismiss the Asset Browser view controller.
        self.dismissViewControllerAnimated(true, completion: nil)
        
        print("An error occurred: \(error)")
    }
    
    func assetBrowserDidClose()
    {
        print("The user closed the Asset Browser without choosing any assets.")
    }
}
