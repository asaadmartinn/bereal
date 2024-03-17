//  PostCell.swift
//  BeRealClone
//  Created by Amir on 2/29/24.

import UIKit
import Alamofire
import AlamofireImage

class PostCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var blurView: UIVisualEffectView!
    
    var imageDataRequest: DataRequest?
    func configure(with post: Post?) {
        postImageView.layer.cornerRadius = 9
        blurView.layer.cornerRadius = 9
        blurView.clipsToBounds = true
        
        if let user = post?.user {
            titleLabel.text = user.username
        }
        
        if let caption = post?.caption {
            captionLabel.text = caption
        }
        
        var infoLabelText: String?
        if let locationName = post?.location {
            infoLabelText = locationName + " · "
        }
        if let takenTime = post?.createdTime {
            let timeFormatter = DateFormatter()
            timeFormatter.timeStyle = .short
            
            infoLabelText? += timeFormatter.string(from: takenTime)
        }
        if infoLabelText != nil {
            infoLabel.text = infoLabelText
        }
        if let imageFile = post?.imageFile,
           let imageUrl = imageFile.url {
            imageDataRequest = AF.request(imageUrl).responseImage { [weak self] response in
                switch response.result {
                case .success(let image):
                    // Set image view image with fetched image
                    self?.postImageView.image = image
                case .failure(let error):
                    print("❌ Error fetching image: \(error.localizedDescription)")
                    break
                }
            }
        }
        
        if let currentUser = User.current, let lastPostedDate = currentUser.lastPostedDate, let postCreatedDate = post?.createdAt, let dateDifference = Calendar.current.dateComponents([.hour], from: postCreatedDate, to: lastPostedDate).hour {
            if abs(dateDifference) < 24 || post?.user == currentUser {
                blurView.isHidden = true
            }
            else {
                blurView.isHidden = false
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        postImageView.image = nil

        imageDataRequest?.cancel()
    }
    
}
