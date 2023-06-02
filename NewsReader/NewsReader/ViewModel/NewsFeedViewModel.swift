//
//  NewsFeedViewModel.swift
//  NewsReader
//

import Foundation

class NewsFeedViewModel{
    private var aggregationCount = 0
    var news: Box<[Article]> = Box([])
    
    func getAllArticles(noAggregationCountCallback: @escaping () -> (),country:String,category:String, startIndex: Int , currentListCount: Int, noMoreDataCallback: @escaping () -> ()) {
        if startIndex == 0 {
            getNewsFromServer(country: country, category: category,page: startIndex, noAggregationCountCallback: noAggregationCountCallback)
        } else {
            if aggregationCount == 0 {
                noAggregationCountCallback()
            }
            else if currentListCount <= aggregationCount
            {
                getNewsFromServer(country: country, category: category,page: startIndex, noAggregationCountCallback: noAggregationCountCallback)
            }
            else{
                noMoreDataCallback()
            }
        }
    }
    
    private func getNewsFromServer(country:String,category:String, page: Int, noAggregationCountCallback: @escaping () -> ()) {
        START_LOADING_VIEW()
        ServiceManager.shared.methodType(requestType: GET_REQUEST, url: GET_NEWS(country: country, category: category,page: page), completion: { [weak self] (response, responseData, statusCode) in
            STOP_LOADING_VIEW()
            if let newsListData = responseData, statusCode == 200{
                let newsListResponse = try? Shared_CustomJsonDecoder.decode(NewsResponse.self, from: newsListData)
                if let totalCount = newsListResponse?.totalResults, totalCount == 0 {
                    noAggregationCountCallback()
                }
                else
                {
                    self?.sendArticlesToViewController(newsResponse: newsListResponse)
                }
            }
        }) { [weak self] (failure, statusCode) in
            STOP_LOADING_VIEW()
            print("Error happened \(failure.debugDescription)")
            self?.sendArticlesToViewController(newsResponse: nil)
        }
    }
    
    private func sendArticlesToViewController(newsResponse: NewsResponse?) {
        guard let newsResponsex = newsResponse else { news.value = [];
            return }
        aggregationCount = newsResponsex.totalResults ?? 0
        news.value = newsResponsex.articles ?? []
    }
}
