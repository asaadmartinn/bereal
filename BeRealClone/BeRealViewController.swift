//  ViewController.swift
//  BeRealClone
//  Created by Amir on 2/29/24.

import UIKit
import PhotosUI
import ParseSwift

class BeRealViewController: UIViewController, UITableViewDataSource {
    var posts: [Post]? {
        didSet {
            PostsTableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let rowCount = posts?.count else {
            return 0
        }
        return rowCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = PostsTableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as? PostCell else {
            return UITableViewCell()
        }
        cell.configure(with: posts?[indexPath.row])
        return cell
    }
    
    @IBOutlet weak var PostsTableView: UITableView!
    
    @IBAction func didTapProfileBarButtonItem(_ sender: Any) {
        User.logout { [weak self] result in
            switch result {
            case .success(let user):
                
                print("✅ Successfully logged out user \(user)")
                
                NotificationCenter.default.post(name: Notification.Name("logout"), object: nil)
                
            case .failure(let error):
                self?.showLogOutErrorAlert(description: error.localizedDescription)
            }
        }
    }
    
    private func queryPosts() {
        let yesterdayDate = Calendar.current.date(byAdding: .day, value: (-1), to: Date())!
        let whereConstraint: QueryConstraint = "createdAt" >= yesterdayDate;
        
        let query = Post.query()
            .include("user")
            .order([.descending("createdAt")])
            .where(whereConstraint)
            .limit(10)

        query.find { [weak self] result in
            switch result {
            case .success(let posts):
                self?.posts = posts
                self?.PostsTableView.refreshControl?.endRefreshing()
            case .failure(let error):
                self?.showFeedErrorAlert(description: error.localizedDescription)
                self?.PostsTableView.refreshControl?.endRefreshing()
            }
        }
    }
    
    private func showLogOutErrorAlert(description: String?) {
        let alertController = UIAlertController(title: "Unable to Log Out", message: description ?? "Unknown error", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(action)
        present(alertController, animated: true)
    }
    
    private func showFeedErrorAlert(description: String?) {
        let alertController = UIAlertController(title: "Unable to Load Feed", message: description ?? "Unknown error", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(action)
        present(alertController, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        PostsTableView.dataSource = self
        PostsTableView.allowsSelection = false
        PostsTableView.rowHeight = UITableView.automaticDimension
        PostsTableView.refreshControl = UIRefreshControl()
        PostsTableView.refreshControl?.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
        PostsTableView.refreshControl?.tintColor = .lightGray
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        queryPosts()
        PostsTableView.reloadData()
    }
    
    @objc func refresh(_ sender: Any) {
        queryPosts()
        PostsTableView.reloadData()
    }
}
