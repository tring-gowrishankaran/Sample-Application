//
//  FeedListDataProviderProtocol.swift
//  SampleRssFeed
//
//  Created by Srinivasan on 14/03/16.
//  Copyright © 2016 Tringapps, Inc. All rights reserved.
//

import UIKit

protocol FeedListDataProviderProtocol: NSObjectProtocol, NSXMLParserDelegate {
    
    var parsedDict:[String:String] {get set}
    
    //To track XML elements
    var itemFound:Bool {get set}
    var canParse:Bool {get set}
    var canIncludeChar:Bool {get set}
    
    //To append parsed character
    var parsedStr:String? {get set}
    
    //To store the obtained data dictionary in array.
    var parsedDataArray : [Dictionary<String, String>] {get set}

    var nsxmlParser:NSXMLParser! {get set}

}