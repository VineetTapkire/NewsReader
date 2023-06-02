//
//  CommonMethods.swift
//  NewsReader
//

import Foundation
//MARK:- App APIS

let BASE_URL = "https://newsapi.org/\(version)"
let version = "v2"
let GET_TopHeadlines = "/top-headlines"

//MARK: Singletons

let Shared_CustomJsonEncoder = CustomJsonEncoder.shared.getSharedEncoder()
class CustomJsonEncoder {
    private var jsonEncoder: JSONEncoder
    private init(){ jsonEncoder = JSONEncoder() }
    static let shared = CustomJsonEncoder()
    
    func getSharedEncoder() -> JSONEncoder {
        return jsonEncoder
    }
}

let Shared_CustomJsonDecoder = CustomJsonDecoder.shared.getSharedDecoder()
class CustomJsonDecoder {
    private var jsonDecoder: JSONDecoder
    private init(){ jsonDecoder = JSONDecoder() }
    static let shared = CustomJsonDecoder()
    
    func getSharedDecoder() -> JSONDecoder {
        return jsonDecoder
    }
}


func convertQueriedFormURLfromParams(param: [String:Any]) -> String{
    var components = URLComponents()
    components.queryItems = param.map {
        URLQueryItem(name: $0, value: "\($1)")
    }
    guard let queryParams = components.url else { return "" }
    
    return "\(queryParams)"
}


func GET_NEWS(country:String,category:String, page: Int) -> String {
    var keysDict = [String : Any]()
    var decodedKey = ""
    if let decodedData = Data(base64Encoded: API_KEY) {
        decodedKey = String(data: decodedData, encoding: .utf8)!
    }
    keysDict =  [ "country" : country,
                  "category" : category,
                  "apiKey" : decodedKey,
                  "pageSize" : pageSize,
                  "page" : page]
    return "\(GET_TopHeadlines)\(convertQueriedFormURLfromParams(param: keysDict))"
}

func START_LOADING_VIEW()  {
    if Utils.isInternetAvailable() {
        DispatchQueue.main.async {
            let loadingView = LoadingView()
            loadingView.tag = LOADING_VIEW_TAG
            APP_KEY_WINDOW?.addSubview(loadingView)
            loadingView.startAnimation()
        }
    }
    else
    {
        STOP_LOADING_VIEW()
    }
}

func STOP_LOADING_VIEW()  {
    DispatchQueue.main.async {
        let loadingView = APP_KEY_WINDOW?.viewWithTag(LOADING_VIEW_TAG) as? LoadingView
        loadingView?.stopAnimation()
    }
}

//MARK: ShowLoader
func SHOW_LOADER()
{
    if Utils.isInternetAvailable() {
        START_LOADING_VIEW()
    }
    else
    {
        STOP_LOADING_VIEW()
    }
}

func SHOW_TOAST(_ msg: String?) {
    if let message = msg {
        DispatchQueue.main.async {
            APP_KEY_WINDOW?.makeToast(message)
        }
    }
}

func PRINT_LOG(_ msg: Any?) {
    if let message = msg {
        print("Something happened \(message)")
    }
}

//MARK: Extention for Notification.Name

extension Notification.Name {
    public static let INTERNET_CONNECTION = Notification.Name(rawValue: "InternetConnection")
}

//MARK: Date Formatter

func formattedDate(dateStr:String) -> Date {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ssZZZ"
    let date = dateFormatter.date(from: dateStr)
    return date ?? NSDate.now
    
}


func readLocalJSONFile(forName name: String) -> Data? {
    do {
        if let filePath = Bundle.main.path(forResource: name, ofType: "json") {
            let fileUrl = URL(fileURLWithPath: filePath)
            let data = try Data(contentsOf: fileUrl)
            return data
        }
    } catch {
        print("error: \(error)")
    }
    return nil
}
