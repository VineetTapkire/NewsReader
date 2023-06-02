//
//  NewsFeedTableViewCell.swift
//  NewsReader


import UIKit
import SDWebImage

class NewsFeedTableViewCell: UITableViewCell {
    
    @IBOutlet weak var newsImageView: UIImageView!
    
    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var headingLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var sourceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    class func reuseIdentifier() -> String
    {
        return String(describing: self)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        newsImageView.image = nil
        headingLabel.text = nil
        timeLabel.text = nil
        sourceLabel.text = nil
        
    }
    
    func setUpCell(article: Article)
    {
        headingLabel.text = article.title
        timeLabel.text = getPastTime(for: formattedDate(dateStr: article.publishedAt ?? ""))
        sourceLabel.text = article.source.name
        
        if let imageUrl = article.urlToImage {
            newsImageView.sd_setImage(with: URL(string: imageUrl), placeholderImage: UIImage(named: "NewsPlaceholder"))
        }
        
        outerView.dropShadow()
        newsImageView.setCornerForImage()
    }
    
    
}

