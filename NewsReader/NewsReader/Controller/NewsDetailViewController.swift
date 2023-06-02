//
//  NewsDetailViewController.swift
//  NewsReader

import UIKit

class NewsDetailViewController: UIViewController {
    
    @IBOutlet weak var newsImageView: UIImageView!
    @IBOutlet weak var souceLabel: UILabel!
    @IBOutlet weak var daysLabel: UILabel!
    @IBOutlet weak var headerTextLabel: UILabel!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var bgViewHeightConstraint: NSLayoutConstraint!
    var dataVal:Article?
    var didTapOnURL: (URL) -> Void = { url in
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: { success in
                if success {
                    print("Opened URL \(url) successfully")
                }
                else {
                    print("Failed to open URL \(url)")
                }
            })
        }
        else {
            print("Can't open the URL: \(url)")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupInit()
    }
    
    func setupInit() {
        headerTextLabel.text = dataVal?.title
        daysLabel.text = getPastTime(for: formattedDate(dateStr: dataVal?.publishedAt ?? ""))
        souceLabel.text = dataVal?.source.name
        descLabel.text = LINK_TEXT
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.tapFunction))
        
        // Gesture recognizer Label
        descLabel.isUserInteractionEnabled = true
        descLabel.addGestureRecognizer(tap)
        if let imageUrl = dataVal?.urlToImage {
            newsImageView.sd_setImage(with: URL(string: imageUrl), placeholderImage: UIImage(named: "NewsPlaceholder"))
        }
        headerView.dropShadow()
        
    }
    
    @objc func tapFunction(_ sender: Any) {
        if let newsUrl = URL(string: (dataVal?.url) ?? ""){
            didTapOnURL(newsUrl)
        }
    }
}
