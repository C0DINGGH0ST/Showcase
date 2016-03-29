//
//  FeedVC.swift
//  Showcase
//
//  Created by Tbakhi on 3/22/16.
//  Copyright © 2016 Tbakhi. All rights reserved.
//

import UIKit
import Firebase
import Alamofire

class FeedVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var tableView:UITableView!
    @IBOutlet weak var postTextField: MaterialField!
    @IBOutlet weak var selectImage: UIImageView!
    
    static var imageCache = NSCache()
    
    var posts = [Post]()
    var imageSelected = false
    
    var imgPicker:UIImagePickerController!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 371
        imgPicker = UIImagePickerController()
        imgPicker.delegate = self
        
        
        
        // listen when data is changed or downloaidng
        
        DataService.ds.REF_POSTS.observeEventType(.Value, withBlock: { snapshot in
            
        // .Value is called whenever Data is changed or downloaded
            
            print(snapshot.value)
            
            self.posts = []
            
            if let snapshots = snapshot.children.allObjects as? [FDataSnapshot] {
                
                for snap in snapshots {  // itterating through each value in the object and converting them into dictionaries
                    
                    print("SNAP: \(snap)")
                    
                    if let postDict = snap.value as? Dictionary<String, AnyObject> {
                        
                        
                        let key = snap.key
                        
                        let post = Post(postKey: key, dictionary: postDict)
                        
                        self.posts.append(post)
                    }
                    
                }
                
            }
            
            
            
            self.tableView.reloadData()
            
        })

        
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let post = posts[indexPath.row]
        
        
        if let cell = tableView.dequeueReusableCellWithIdentifier("PostCell") as? PostCell {
            
            cell.request?.cancel()
            
            var img: UIImage? // empty image
            
            if let url = post.imageURL {
                
               img = FeedVC.imageCache.objectForKey(url) as? UIImage // nscache has keys and values, store image url as the "key", if this works then image is not empty
                
                
            }
            
            cell.configureCell(post, img: img)
            return cell
            
        } else {
            
            return PostCell()
        }
    
        
        
    }
    
    
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        let post = posts[indexPath.row]
        
        if post.imageURL == nil {
            
            return 150
            
        } else {
            
            return tableView.estimatedRowHeight
        }
        
    }
    
    
    
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        
        
        imgPicker.dismissViewControllerAnimated(true, completion: nil)
        selectImage.image = image // shows the image you selected, LECTURE 125 
        imageSelected = true
    }
 
    @IBAction func onCameraPressed(sender: UITapGestureRecognizer) {
        
       presentViewController(imgPicker, animated: true, completion: nil)
        
        
        
    }
    
    @IBAction func onPostButtonPressed(sender: AnyObject) {
        
        
        
        if let txt = postTextField.text where txt != "" {
            
            if let img = selectImage.image where imageSelected == true {
                
                
                let urlStr = "https://post.imageshack.us/upload_api.php"
                let url = NSURL(string: urlStr)!
                
                let imgData = UIImageJPEGRepresentation(img, 0.2)!
                let keyData = "KVZGJHQC0c3cad8371b5d1e2562d57c10807e517".dataUsingEncoding(NSUTF8StringEncoding)! // -> standard format for converting strings into data
                
                
               let keyJSON = "json".dataUsingEncoding(NSUTF8StringEncoding)! // converting json into data, based off of the API
                
                
                Alamofire.upload(.POST, url, multipartFormData: { multipartFormData in
                    
                
                    multipartFormData.appendBodyPart(data: imgData, name: "fileupload", fileName:"image", mimeType: "image/jpg")
                    multipartFormData.appendBodyPart(data: keyData, name: "key")
                    multipartFormData.appendBodyPart(data: keyJSON, name: "format")
                    
                    
                    
                }) { encodingResult in // what happens after uploading is done
                    
                    
                    switch encodingResult {  // switch is like an if else statement with different cases
                        
                    case .Success(let upload, _, _):  // success is a type of closure, if it works it will pass in the upload
                        
                        upload.responseJSON(completionHandler: {(response) in
                            
                            if let info = response.result.value as? Dictionary<String, AnyObject> { // go into the value from the data we got back from server and convert it to a dictionary
                                
                                if let links = info["links"] as? Dictionary<String, AnyObject> {
                                    
                                    if let imgLink = links["image_link"] as? String {
                                        
                                        print("LINK: \(imgLink)")
                                        self.postToFirebase(imgLink)
                                        
                                    }
                                    
                                
                                
                                }
                                
                            }
                        
                    })
                        
                    
                    case .Failure(let error): // .sucess and .failure is part of multipartform data in alamofire
                        print(error)
                
                    
                    }
                    
                
                
                    
                }
            
        
                
            } else {
                
                self.postToFirebase(nil)
            }
            
        }
            
            
            
        
        
    }
    
    
    func postToFirebase(imgUrl: String?) {
        
        
        var post: Dictionary<String, AnyObject> = [
        "description": postTextField.text!,
        "likes": 0,
        
            
        
        
        
        ]
        
        if imgUrl != nil {
            
            post["imageUrl"] = imgUrl!
        }
        
        
        let firebasePost = DataService.ds.REF_POSTS.childByAutoId() // -> /posts/unique object identifier = childbyautoid
        
        firebasePost.setValue(post)
        
        
        postTextField.text = ""
        selectImage.image = UIImage(named: "camera") // camera refers to the name of the image
        imageSelected = false
        tableView.reloadData()
        
        
    }
   
} // last curly bracket refers to the class up top