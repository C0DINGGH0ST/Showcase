//
//  Post.swift
//  Showcase
//
//  Created by Tbakhi on 3/27/16.
//  Copyright © 2016 Tbakhi. All rights reserved.
//

import Foundation
import Firebase

class Post {
    
    
    private var _postDescription:String!
    private var _imageURL:String?
    private var _likes:Int!
    private var _username:String!
    private var _postKey:String!
    private var _postREF: Firebase!
    
    
    
    var postDescription:String {
        
        return _postDescription
    }
    
    var imageURL:String? {
        
        return _imageURL
    }
    
    var likes:Int {
        
        return _likes
        
    }
    
    
    var username:String {
        
    return _username
        
        
    }
    
    var postKey:String {
        
        return _postKey
    }
    
    init(description: String, imageUrl:String?, username:String) {
        
        self._postDescription = description
        self._imageURL = imageURL
        self._username = username
        
    }
    
    init(postKey:String, dictionary: Dictionary<String, AnyObject>) {
        
        // grab data from firebase, pass in dictionary and then parse the data
        
        self._postKey = postKey
        
        
        if let likes = dictionary["likes"] as? Int {
            
            self._likes = likes
            
        }
        
        if let imgUrl = dictionary["imageUrl"] as? String {
            
            self._imageURL = imgUrl
        }
        
        if let desc = dictionary["description"] as? String {
            
            self._postDescription = desc
        }
        
        self._postREF = DataService.ds.REF_POSTS.childByAppendingPath(self._postKey)
    }
    
    func adjustLikes(addLike: Bool) {
        
        if addLike {
            
            _likes = _likes + 1
        } else {
            
            _likes = _likes - 1
        }
        
        _postREF.childByAppendingPath("likes").setValue(_likes)
        
    }
}
