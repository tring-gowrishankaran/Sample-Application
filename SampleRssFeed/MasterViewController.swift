//
//  MasterViewController.swift
//  SampleRssFeed
//
//  Created by Srinivasan on 07/03/16.
//  Copyright © 2016 Tringapps, Inc. All rights reserved.
//

import UIKit
import CoreData

class MasterViewController: UITableViewController, NSFetchedResultsControllerDelegate, FeedListDataProviderProtocol {

    var detailViewController: DetailViewController? = nil
    var managedObjectContext: NSManagedObjectContext? = nil
    
    let url_to_request = "http://phobos.apple.com/WebObjects/MZStoreServices.woa/ws/RSS/toppaidapplications/limit=75/xml"
    
    var parsedDict:[String:String] = Dictionary()
    var parsedDataArray : [Dictionary<String, String>] = []
    
    //To Track item
    var itemFound = false
    var canParse = false
    var canIncludeChar = true
    
    //To append parsed character
    var parsedStr:String?
    
    var nsxmlParser:NSXMLParser!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationItem.leftBarButtonItem = self.editButtonItem()

        let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "insertNewObject:")
        self.navigationItem.rightBarButtonItem = addButton
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
        
        //To fetch the rss feed information from server.
//        obtainData(self, req_url: self.url_to_request)
          obtainData()
    }

    override func viewWillAppear(animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.collapsed
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //To insert data into persistant store.
    func insertNewObject(sender: AnyObject) {
        
        let context = self.fetchedResultsController.managedObjectContext
        let entity = self.fetchedResultsController.fetchRequest.entity!
        
        let newManagedObject = NSEntityDescription.insertNewObjectForEntityForName(entity.name!, inManagedObjectContext: context)
        
        // If appropriate, configure the new managed object.
        // Normally you should use accessor methods, but using KVC here avoids the need to add a custom class to the template.
        
        //Format the date to show only hours & minutes.
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"
        
        newManagedObject.setValue(dateFormatter.dateFromString(sender.valueForKey("updated") as! String), forKey: "pubDate")
        newManagedObject.setValue(sender.valueForKey("title") as! String, forKey: "title")
        newManagedObject.setValue(sender.valueForKey("summary") as! String, forKey: "desc")
        newManagedObject.setValue(sender.valueForKey("link") as! String, forKey: "link")
        newManagedObject.setValue(sender.valueForKey("im:name") as! String, forKey: "author")
        newManagedObject.setValue(sender.valueForKey("id") as! String, forKey: "id")
        newManagedObject.setValue(sender.valueForKey("im:image") as! String, forKey: "imageURL")
        
        // Save the context.
        do {
            try context.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            //print("Unresolved error \(error), \(error.userInfo)")
            abort()
        }
    }
    
    /*
    //To validate if an object with specific id exist. Using this we will be eliminating duplicate entries.
    func containsObjectWithID (value objId: String, forKey keyName:String) -> Bool {

        var containsObj = false
        
        let fetchRequest = NSFetchRequest()
        var error : NSError? = nil

        // Create Entity Description
        let entityDescription = NSEntityDescription.entityForName("NewsFeed", inManagedObjectContext: self.managedObjectContext!)
        
        // Configure Fetch Request
        fetchRequest.entity = entityDescription
        fetchRequest.predicate = NSPredicate(format: "%@ == %@",keyName, objId)
        
        let result = self.managedObjectContext!.countForFetchRequest(fetchRequest, error: &error)
        
        if error != nil {
            print(error)
        }
        else if result > 0 {
            print("Object Available")
            containsObj = true
        }
        
        print(result)
        
        return containsObj
    }
    */
    
    //MARK: - Fetch XML Data
    //This method helps us to fetch the XML data from server.
    func obtainData() {
        
        dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
            
            self.nsxmlParser = NSXMLParser.init(contentsOfURL: NSURL.init(string: self.url_to_request)!)
            self.nsxmlParser.delegate = self
            self.nsxmlParser.parse()
            
        });
    }

//    func obtainData(delegateObj : NSXMLParserDelegate, req_url:String) {
//
//        dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
//
//            self.nsxmlParser = NSXMLParser.init(contentsOfURL: NSURL.init(string: req_url)!)
//            self.nsxmlParser.delegate = delegateObj
//            
//            dispatch_async( dispatch_get_main_queue(), {
//                self.nsxmlParser.parse()
//            });
//            
//        });
//    }

    //MARK: - NSXMLParse Delegates
    //Delegate Method that gets called when the NSXMLParser encounters a new element.
    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        
        //To identify if the "entry" entity is found. If yes, itemFound boolean is set as true. This helps us to create a dictionary related to specific topic.
        if elementName == "entry" {
            itemFound = true
//            print("Has found item key")
        }
        else if (itemFound) {
            //This loop gets executed, if an sub-element of item element is found.
            
            switch elementName {
                //If we encounter summary,published/updated date,title,link, app-id & name we set canParse flag as true. (It is based on this flag, we decide if the specific element needs to be added to dictionary.)
                
                case "summary","updated","title","im:name","im:image":
                    canParse = true
                    canIncludeChar = true
                
                case "id":
                    parsedStr = attributeDict["im:id"]!
                    canParse = true
                    canIncludeChar = false
                
                case "link":
                    parsedStr = attributeDict["href"]!
                    canParse = true
                    canIncludeChar = false
                
                default:
                    canParse = false
                    canIncludeChar = false
            }
//            print("ElementName:\(elementName)")
        }
    }
    
    //Delegate Method that gets called when NSXMLParse finds characters.
    func parser(parser: NSXMLParser, foundCharacters string: String) {
        
        if canParse && canIncludeChar {
            var obtainedString = string.stringByReplacingOccurrencesOfString("\t", withString: "")
            obtainedString = obtainedString.stringByReplacingOccurrencesOfString("\n", withString: "")
            
            if parsedStr == nil && !obtainedString.isEmpty {
                parsedStr = obtainedString
            }
            else if !obtainedString.isEmpty {
                parsedStr = parsedStr! + obtainedString
            }
        }
    }
    
    //Delegate Method that gets calle, when CDATA input is found.
    func parser(parser: NSXMLParser, foundCDATA CDATABlock: NSData) {
        if canParse {
            parsedStr = String(data: CDATABlock, encoding: NSUTF8StringEncoding)
        }
    }

    func parserDidEndDocument(parser: NSXMLParser) {
        print("Parse Completed")
    }
    
    //Delegate method that gets called, when an end element tag is identified.
    func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        
        //if item's sub-element is found and the same element can be parsed, we add it to dictionary.
        if (itemFound) {
            if canParse {
                parsedDict[elementName] = parsedStr!
            }
        }
        parsedStr = nil
        
        if elementName == "entry" {
            
            itemFound = false
            parsedDataArray.append(parsedDict)
            
            //To insert the data in persistant store and also to empty the temp dict created.
            insertNewObject(parsedDict)
            parsedDict.removeAll()
        }
    }
    
    // MARK: - Segues
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                
            let object = self.fetchedResultsController.objectAtIndexPath(indexPath)
                let controller = (segue.destinationViewController as! UINavigationController).topViewController as! DetailViewController
                
                controller.detailItem = object
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }

    // MARK: - Table View

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        print("Section Count: \(self.fetchedResultsController.sections?.count)")
        return self.fetchedResultsController.sections?.count ?? 0
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section]
//        print("No of Rows:\(sectionInfo.numberOfObjects)")
        return sectionInfo.numberOfObjects
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell: FeedTableViewCell! = tableView.dequeueReusableCellWithIdentifier("FeedTableViewCell") as! FeedTableViewCell
        
        if cell == nil {

            tableView.registerClass(FeedTableViewCell.self, forCellReuseIdentifier: "FeedTableViewCell")
            cell = tableView.dequeueReusableCellWithIdentifier("FeedTableViewCell") as? FeedTableViewCell
        }

//        if let visibleCellList = tableView.visibleCells as? [FeedTableViewCell] {
//            if(visibleCellList.contains(cell)) {
                self.configureCell(cell, atIndexPath: indexPath)
//            }
//        }
        
        return cell
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let context = self.fetchedResultsController.managedObjectContext
            context.deleteObject(self.fetchedResultsController.objectAtIndexPath(indexPath) as! NSManagedObject)
                
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                //print("Unresolved error \(error), \(error.userInfo)")
                abort()
            }
        }
    }

    func configureCell(cell: FeedTableViewCell, atIndexPath indexPath: NSIndexPath) {
        
        let object = self.fetchedResultsController.objectAtIndexPath(indexPath)
        
        let objId = object.valueForKey("id")!.description
        
        cell.cellID = objId
        
        if isImageAvailable(ForName:objId) {
            if let imageView = cell.topicImage {
                imageView.image = UIImage(contentsOfFile: getCachePath(forFileName:objId))
            }
        }
        else {
            cell.topicImage.image = nil
            if !self.tableView.dragging && !self.tableView.decelerating {
                self.downloadedFrom(link: object.valueForKey("imageURL")!.description, forCell: cell)
            }
        }
        
        if let titleLbl = cell.topicTitle{
            titleLbl.text = object.valueForKey("title")!.description
        }
        
        if let descLbl = cell.topicDesc{
            descLbl.text = object.valueForKey("desc")!.description
        }
    }

    // MARK: - Fetched results controller

    var fetchedResultsController: NSFetchedResultsController {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        let fetchRequest = NSFetchRequest()
        // Edit the entity name as appropriate.
        let entity = NSEntityDescription.entityForName("NewsFeed", inManagedObjectContext: self.managedObjectContext!)
        fetchRequest.entity = entity
        
        // Set the batch size to a suitable number.
        fetchRequest.fetchBatchSize = 20
        
        // Edit the sort key as appropriate.
        let sortDescriptor = NSSortDescriptor(key: "pubDate", ascending: false)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: nil, cacheName: "Master")
        aFetchedResultsController.delegate = self
        _fetchedResultsController = aFetchedResultsController
        
        do {
            try _fetchedResultsController!.performFetch()
        } catch {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
             //print("Unresolved error \(error), \(error.userInfo)")
             abort()
        }
        
        return _fetchedResultsController!
    }

    var _fetchedResultsController: NSFetchedResultsController? = nil

    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        self.tableView.beginUpdates()
    }

    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        
        switch type {
            case .Insert:
                self.tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
            case .Delete:
                self.tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
            default:
                return
        }
    }

    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        switch type {
            case .Insert:
                tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
            case .Delete:
                tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            case .Update:
                self.configureCell(tableView.cellForRowAtIndexPath(indexPath!) as! FeedTableViewCell, atIndexPath: indexPath!)
            case .Move:
                tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
                tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        }
    }

    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.tableView.endUpdates()
    }

    /*
     // Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed.
     
     func controllerDidChangeContent(controller: NSFetchedResultsController) {
         // In the simplest, most efficient, case, reload the table view.
         self.tableView.reloadData()
     }
     */
    
    // MARK: - Scrollview Delegates

    //Override the scrollview delegates to load images of visible rows.
    override func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        self.loadImagesForVisibleRows()
    }
    
    //Override the scrollview delegates to load images of visible rows.
    override func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            self.loadImagesForVisibleRows()
        }
    }
    
    //MARK: - Load & Save Images
    func loadImagesForVisibleRows() {
     
        if let visibleTableviewCells = self.tableView.indexPathsForVisibleRows {
            
            for visibleCellIndex in visibleTableviewCells {
                    
                let object = self.fetchedResultsController.objectAtIndexPath(visibleCellIndex)

                let visibleCell = self.tableView.cellForRowAtIndexPath(visibleCellIndex) as! FeedTableViewCell
                if visibleCell.topicImage.image == nil {
                    self.downloadedFrom(link:object.valueForKey("imageURL")!.description, forCell: visibleCell)
                }
            }
        }
    }
    
    //To download the image from the URL and save it in cache directory.
    func downloadedFrom(link link:String, forCell cell:FeedTableViewCell) {
        guard
            let url = NSURL(string: link)
            else {return}
        
        NSURLSession.sharedSession().dataTaskWithURL(url, completionHandler: { (data, response, error) -> Void in
            guard
                let httpURLResponse = response as? NSHTTPURLResponse where httpURLResponse.statusCode == 200,
                let mimeType = response?.MIMEType where mimeType.hasPrefix("image"),
                let data = data where error == nil,
                let image = UIImage(data: data)
                else { return }
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                if self.saveImage(image, name: cell.cellID) {
                    cell.topicImage.image = UIImage(contentsOfFile: self.getCachePath(forFileName:cell.cellID))
                }
            }
        }).resume()
    }
    
    func saveImage (image: UIImage, name:String ) -> Bool{
        
        let pngImageData = UIImagePNGRepresentation(image)
        let filePath = MasterViewController().getCachePath(forFileName:name)
        let result = pngImageData!.writeToFile(filePath, atomically: true)
        
        return result
    }

    //To Check if the image is available in cache path.
    func isImageAvailable (ForName name:String) -> Bool {
        
        let manager = NSFileManager.defaultManager()
        let filePath = getCachePath(forFileName:name)
        
        if (manager.fileExistsAtPath(filePath)) {
            return true
        }
        return false
    }
    
    //To get the cache folder path for specific file extension.
    //If the folder is not available, we create it.
    
    func getCachePath (forFileName fileName:String) -> String {
        
        let cacheFolder = NSBundle.mainBundle().bundleIdentifier! + "/ImageResource"
        let myPath = NSURL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true)[0])
        let cachePath = myPath.URLByAppendingPathComponent(cacheFolder)
        
        do {
            var error: NSError?
            if !cachePath.checkResourceIsReachableAndReturnError(&error) {
                try NSFileManager.defaultManager().createDirectoryAtPath(cachePath.path!, withIntermediateDirectories: true, attributes: nil)
                print(cachePath.path! + "/")
            }
        } catch let error as NSError {
            NSLog("Unable to create directory \(error.debugDescription)")
        }
        
        return cachePath.path! + "/" + fileName + ".png"
    }

}

