//
//  Constants.swift
//  NewsReader

import Foundation
import UIKit

public class NameValueObject: NSObject
{
    public var name, value, objectType, valueUrlString: String?
    
    public init(_ name: String? = nil,_ value: String? = nil, _ objectType: String? = nil, _ valueUrlString: String? = nil) {
        self.name = name
        self.value = value
        self.objectType = objectType
        self.valueUrlString = valueUrlString
    }
    
}

//MARK: Others
let APP_KEY_WINDOW = UIWindow.key

let APP_DELEGATE = AppDelegate.shared

let GET_REQUEST = "GET"
let POST_REQUEST = "POST"
let PUT_REQUEST = "PUT"
let DELETE_REQUEST = "DELETE"

let API_KEY = "ZTdkNGI0ZTU5Nzc3NDM4YmI0YTFmNTcxNDNlOTIwMWE="
let pageSize = 20

let SUCCESS_CODE = 200


let LOADING_VIEW_TAG = 123456789
let LOADING_IMAGE_TAG = 987654321

let BACKEND_ERROR = 9000
let NO_DATA_LABEL_TAG = 8999



let BOUNDS  = UIScreen.main.bounds

//MARK: DEVICE SIZE
let SCREEN_WIDTH         = UIScreen.main.bounds.size.width
let SCREEN_HEIGHT        = UIScreen.main.bounds.size.height
let SCREEN_MAX_LENGTH    = max(SCREEN_WIDTH, SCREEN_HEIGHT)
let SCREEN_MIN_LENGTH    = min(SCREEN_WIDTH, SCREEN_HEIGHT)


//MARK:- Common Toast Messages
let UNKNOWN_ERROR_MSG : String = "Oops! Something went wrong, Please try again."
let NO_INTERNET_CONNECTION : String = "Please check your Internet connection"
