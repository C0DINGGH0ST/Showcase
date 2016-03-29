//
//  PostCell.swift
//  Showcase
//
//  Created by Tbakhi on 3/22/16.
//  Copyright © 2016 Tbakhi. All rights reserved.
//

import UIKit
import Alamofire
import Firebase

class PostCell: UITableViewCell {
    
    
    @IBOutlet weak var profileImg:UIImageView!
    @IBOutlet weak var mainImg:UIImageView!
    @IBOutlet weak var descriptionText:UITextView!
    @IBOutlet weak var likesLbl: UILabel!
    @IBOutlet weak var likeImg:UIImageView!
    
    var post:Post!
    var request: Request?
    var likeRef:Firebase!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
        let tap = UITapGestureRecognizer(target: self, action: "likeTapped:")
        tap.numberOfTapsRequired = 1
        likeImg.addGestureRecognizer(tap)
        likeImg.userInteractionEnabled = true
        
    }
    
    
    override func drawRect(rect: CGRect) {
        profileImg.layer.cornerRadius = profileImg.frame.size.width / 2  // use drawrect when custom image does not have any constraints to size or width
        profileImg.clipsToBounds = true
        
        mainImg.clipsToBounds = true
    }

    func configureCell(post:Post, img:UIImage?) {
        
        self.post = post
        
        likeRef = DataService.ds.REF_USER_CURRENT.childByAppendingPath("likes").childByAppendingPath(post.postKey)
        
         // create variables and display data onto view
            
            self.descriptionText.text = post.postDescription
            self.likesLbl.text = "\(post.likes)"
        
        
        if post.imageURL != nil {
            
            if img != nil {
                
                self.mainImg.image = img
            } else {
                
                request = Alamofire.request(.GET, post.imageURL!).validate(contentType: ["image/*"]).response(completionHandler: { request , response , data, err in
                    
                    
                    if err == nil {
                        
                        let img = UIImage(data: data!)!
                        
                        self.mainImg.image = img
                        FeedVC.imageCache.setObject(img, forKey: self.post.imageURL!)
                        
                    }
                    
                    
                    
                })
            }
            
        } else {
            
            self.mainImg.hidden = true
        }
        
        
        likeRef.observeSingleEventOfType(.Value, withBlock: { snapshot in // only called once, checking if a like exists and either show or not show the heart

            if let doesNotExist = snapshot.value as? NSNull {
                
                // this means we have not liked this specific post
                
                self.likeImg.image = UIImage(named: "heart-empty")
                
            } else {
                
                self.likeImg.image = UIImage(named: "heart-full")
            }
        
        })
        
        
        
    }
    
    
    func likeTapped(sender: UITapGestureRecognizer) {
        
        likeRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
        
        if let doesNotExist = snapshot.value as? NSNull {
            
           
            
            self.likeImg.image = UIImage(named: "heart-full")
            self.post.adjustLikes(true)
            self.likeRef.setValue(true)
        
           
            
        } else {
            
            
             self.likeImg.image = UIImage(named: "heart-empty")
            self.post.adjustLikes(false)
            self.likeRef.removeValue()
        }
        
    })

    
    
    }





}

