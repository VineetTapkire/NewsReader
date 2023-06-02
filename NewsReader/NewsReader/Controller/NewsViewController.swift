//
//  ViewController.swift
//  NewsReader

import UIKit
import PullToRefreshKit

class NewsViewController: UIViewController,UIPopoverPresentationControllerDelegate {
    
    private var newsViewModel = NewsFeedViewModel()
    private var newsArray = [Article](){
        didSet
        {
            if newsArray.count > 0 {
                // Bounce back to the main thread to update the UI
                DispatchQueue.main.async {
                    self.newsListTableView.reloadData()
                }
            }
        }
    }
    
    private var page = 0
    @IBOutlet weak var newsListTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "News Reader"
        setupTableView()
        getAllNews(country: "in", category: "",page: page)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addObserverForInternetConnectivity()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeObserverForInternetConnectivity()
    }
    
    fileprivate func setupTableView() {
        newsListTableView.register(UINib(nibName: NewsFeedTableViewCell.reuseIdentifier(), bundle: nil), forCellReuseIdentifier: NewsFeedTableViewCell.reuseIdentifier())
        newsListTableView.dataSource = self
        newsListTableView.delegate = self
        newsListTableView.rowHeight = 100
        newsListTableView.estimatedRowHeight = 100
        newsViewModel.news.bind { [weak self] (news) in
            DispatchQueue.main.async {
                if self?.page == 0
                {
                    self?.newsArray.removeAll()
                    self?.newsListTableView.switchRefreshHeader(to: .normal(.success, 0.5))
                }
                
                if news.count != 0
                {
                    self?.newsListTableView.hideNoDataLabel()
                    self?.newsArray.append(contentsOf: news)
                }else if self?.newsArray.count == 0 && news.count == 0 {
                    self?.newsListTableView.showNoDataLabel(withText: "No data to show")
                }
                self?.newsListTableView.switchRefreshFooter(to: .normal)
            }
        }
        
        newsListTableView?.configRefreshHeader(container: self, action: { [weak self] in
            self?.page = 0
            self?.getAllNews(country: "in", category: "",page: self?.page ?? 0)
        })
        
        newsListTableView.configRefreshFooter(container: self) { [weak self] in
            self?.page += 1
            self?.getAllNews(country: "in", category: "",page: self?.page ?? 0)
        }
    }
    
    // MARK: - InternetConnection_Observer
    override func gotInternetConnectivity() {
        super.gotInternetConnectivity()
        page = 0
        getAllNews(country: "in", category: "",page: page)
    }
    
    private func getAllNews(country:String,category:String, page: Int)
    {
        newsViewModel.getAllArticles(noAggregationCountCallback: { [weak self] in
            DispatchQueue.main.async {
                self?.newsListTableView.switchRefreshHeader(to: .normal(.success, 0.5))
                self?.newsListTableView.showNoDataLabel(withText: "No data to show")
            }
        },country: country,category: category ,startIndex: page, currentListCount: newsArray.count) { [weak self] in
            //noMoreDataCallback
            DispatchQueue.main.async {
                self?.newsListTableView.switchRefreshFooter(to: .noMoreData)
            }
        }
    }
}

//MARK: UITableViewDataSource, UITableViewDelegate

extension NewsViewController: UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NewsFeedTableViewCell.reuseIdentifier(), for: indexPath) as! NewsFeedTableViewCell
        cell.setUpCell(article: newsArray[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "NewsDetailViewController") as? NewsDetailViewController
        vc?.dataVal = newsArray[indexPath.row]
        
        self.navigationController?.pushViewController(vc!, animated: true)
    }
}

//MARK: App Color Theme Settings
extension NewsViewController {
    
    //Navigation Bar Color picker Delegate
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    func setNavigationBarColor (_ color: UIColor) {
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = color
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.standardAppearance = appearance
    }
}

