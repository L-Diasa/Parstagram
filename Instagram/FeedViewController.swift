//
//  FeedViewController.swift
//  Instagram
//
//  Created by lika on 3/15/22.
//  Copyright © 2022 lika. All rights reserved.
//

import UIKit
import Parse
import AlamofireImage

class FeedViewController: UIViewController, UITableViewDelegate,
    UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    var posts = [PFObject]()
    private var postsNum = 20
    var refreshControl: UIRefreshControl!
    var firstLoaded: Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        // For refreshing the feed
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(onRefresh), for: .valueChanged)
        tableView.insertSubview(refreshControl, at: 0)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadPosts()
    }
    
    func loadPosts() {
        // Get the posts
        let query = PFQuery(className: "Posts")
        // Retrieve the most recent ones
        query.order(byDescending: "createdAt")
        // Include the author data with each post
        query.includeKey("author")
        // Only retrieve the given number of posts
        query.limit = postsNum
        
        // Assure the network request is done
        query.findObjectsInBackground {
            (posts, error) in
            if posts != nil {
                self.posts = posts!
                self.tableView.reloadData()
            }
        }
    }

    // number of rows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    // Configure the cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as! PostCell
        let post = posts[indexPath.row]
        
        // Setting post cell properties
        let user = post["author"] as! PFUser
        cell.usernameLabel.text = user.username
        
        cell.captionLabel.text = (post["caption"] as! String)
        
        let imageFile = post["image"] as! PFFileObject
        let urlString = imageFile.url!
        let url = URL(string: urlString)!
        cell.photoView.af.setImage(withURL: url)
        
        return cell
    }
    
    // Load more tweets
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if  indexPath.row + 1 == postsNum {
            postsNum += 20
            loadPosts()
        }
    }
    
    // Creating a fake comment
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let post = posts[indexPath.row]
        
        // Create class comment and add some fields
        let comment = PFObject(className: "Comments")
        comment["text"] = "this is a random comment"
        comment["post"] = post
        comment["author"] = PFUser.current()!
        
        // Add comment to the selected post
        post.add(comment, forKey: "comments")
        
        // Save comment
        post.saveInBackground { (success, error) in
            if(success) {
                print("Comment saved")
            } else {
                print("Error saving comment")
            }
        }
    }
 
    @objc func onRefresh() {
        // Refresh lasts for 2 seconds
        run(after: 2) {
            self.postsNum = 20
            self.loadPosts()
            self.refreshControl.endRefreshing()
        }
    }
    
    func run(after wait: TimeInterval, closure: @escaping () -> Void) {
        let queue = DispatchQueue.main
        queue.asyncAfter(deadline: DispatchTime.now() + wait, execute: closure)
    }
    
    // Handle log out
    @IBAction func onLogoutButton(_ sender: Any) {
        PFUser.logOut()
        let main = UIStoryboard(name: "Main", bundle: nil)
        let loginViewController = main.instantiateViewController(identifier: "LoginViewController")
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene, let delegate = windowScene.delegate as? SceneDelegate else { return }
        
        delegate.window?.rootViewController = loginViewController
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
