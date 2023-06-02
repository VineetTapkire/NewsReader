//
//  WebService.swift
//  NewsReader

import Foundation
import UIKit


typealias completionBlock = ((_ response : Any?,_ responseData : Data?, _ statusCode: Int)->Void)
typealias failureBlock = ((_ response : Any?,  _ statusCode: Int)->Void)
public let ServiceManagerSharedInstance = ServiceManager.shared

open class ServiceManager: NSObject {
    
    private override init() {}
    static let shared = ServiceManager()
    
    var isInternetAvailable: Bool {
        if currentReachabilityStatus == .notReachable {
            SHOW_TOAST(NO_INTERNET_CONNECTION)
            return false;
        } else {
            return true
        }
    }
    
    //MARK:- Methods
    
    func methodType(requestType: String,  url: String, params: NSDictionary? = nil, paramsData: Data? = nil,  completion: completionBlock?, failure: failureBlock?)
    {
        let urlWithBaseUrl = "\(BASE_URL)\(url)"
        let completeURL = urlWithBaseUrl.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        var urlRequest = URLRequest.init(url: URL.init(string: completeURL!)!)
        
        if params != nil{
            let postData = try? JSONSerialization.data(withJSONObject: params as Any, options: .init(rawValue: 0))
            urlRequest.httpBody = postData
        }else if paramsData != nil
        {
            urlRequest.httpBody = paramsData
        }
        
        urlRequest.httpMethod = requestType
        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.timeoutInterval = 60
        
        self.sessionWithRequest(urlRequest: urlRequest, completion: completion, failure: failure)
    }
    
    //MARK:- SessionRequest
    func sessionWithRequest(urlRequest: URLRequest, completion: completionBlock?, failure: failureBlock?)
    {
        if ServiceManager.shared.isInternetAvailable == true {
            let sessionConfiguration =  URLSessionConfiguration.default
            let session = URLSession.init(configuration: sessionConfiguration)
            
            let dataTask = session.dataTask(with: urlRequest) { (data, response, error) in
                
                let httpResponse = response as? HTTPURLResponse
                
                let code = httpResponse?.statusCode
                
                if error == nil && data != nil {
                    let json = try? JSONSerialization.jsonObject(with: data!, options: .init(rawValue: 0))
                    if  json != nil {
                        
                        if completion != nil {
                            if json is [AnyHashable:Any]
                            {
                                let jsonResponse = json as! [AnyHashable:Any]
                                let responseCode = !(json is NSNumber) ? (jsonResponse["success"] as? Int):0
                                if (responseCode != nil)
                                {
                                    if responseCode == 9000
                                    {
                                        STOP_LOADING_VIEW()
                                        if failure != nil {
                                            failure! (json, code!)
                                        }
                                    }
                                    else if responseCode != SUCCESS_CODE && String(describing: jsonResponse["error"]).count > 0
                                    {
                                        STOP_LOADING_VIEW()
                                        SHOW_TOAST(jsonResponse["error"] as? String)
                                        if failure != nil {
                                            failure! (json, code!)
                                        }
                                    }
                                    else
                                    {
                                        completion! (json,data, code!)
                                    }
                                }
                                else
                                {
                                    completion! (json,data, code!)
                                }
                            }
                            else if json is Int64
                            {
                                completion! (json,data, code!)
                            }
                            else
                            {
                                completion! (json,data, code!)
                            }
                            
                        }
                    } else {
                        STOP_LOADING_VIEW()
                        if failure != nil {
                            failure! (json, code!)
                        }
                    }
                } else {
                    if failure != nil && code != nil {
                        failure! (error, code!)
                    } else if failure != nil {
                        SHOW_TOAST(error?.localizedDescription)
                        failure! (error, 0)
                    }
                }
            }
            dataTask.resume()
            session.finishTasksAndInvalidate()
        }
        else
        {
            STOP_LOADING_VIEW()
        }
    }
}
