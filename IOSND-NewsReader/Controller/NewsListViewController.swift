//
//  ViewController.swift
//  IODND-NewsReader
//
//  Created by Leandro Alves Santos on 18/08/18.
//  Copyright © 2018 Leandro Alves Santos. All rights reserved.
//

import UIKit
import CoreData

class NewsListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    //MARK: - Properties
    @IBOutlet var newsTableView: UITableView!
    @IBOutlet var savedOrNewButton: UIBarButtonItem!
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    var dataController: DataController!
    
    let fetch: NSFetchRequest<ArticleData> = ArticleData.fetchRequest()
    
    //MARK: - UIViewController functions
    
    //Configures the ActivityIndicator
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        view.bringSubview(toFront: activityIndicator)
        view.addSubview(activityIndicator)
    }
    
    //Loads the news from database or using the API
    override func viewWillAppear(_ animated: Bool) {
        
        activityIndicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        Articles.sharedArticles.removeAll()
        
        if savedOrNewButton.title == "Show new" {
            
            getNewsFromDatabase()
        }
        else {
            
            getNewsFromAPI()
        }
    }
    
    //MARK: - IBAction functions
    
    //Loads the news from database or using the API
    @IBAction func showSavedOrNew(_ sender: Any) {
        
        activityIndicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        Articles.sharedArticles.removeAll()
        
        if savedOrNewButton.title == "Show saved" {
          
            getNewsFromDatabase()
            savedOrNewButton.title = "Show new"
        }
        else {
            
            getNewsFromAPI()
            savedOrNewButton.title = "Show saved"
        }
        
        
    }
    
    //MARK: - Private functions
    
    //Loads the news from NewsAPI
    func getNewsFromAPI() {
        let complete: (String) -> Void = { errorMessage in
            if errorMessage == "" {
                
                DispatchQueue.main.async {
                    
                    self.processNews()
                    self.activityIndicator.stopAnimating()
                    UIApplication.shared.endIgnoringInteractionEvents()
                }
            }
            else {
                
                self.showSimpleAlert(caption: "News", text: errorMessage, okHandler: nil)
                
                self.activityIndicator.stopAnimating()
                UIApplication.shared.endIgnoringInteractionEvents()
            }
        }
        
        let newsAPI = NewsAPI()
        newsAPI.populateArticles(completionHandler: complete)
    }
    
    //Loads the news from Database
    func getNewsFromDatabase() {
        
        let articles = try? DataController.sharedDataController.viewContext.fetch(fetch)
        
        for articleFromDB in articles! {
            
            let article = Article()
            
            article.descript = articleFromDB.descript
            article.title = articleFromDB.title
            article.url = articleFromDB.url
            article.urlToImage = articleFromDB.urlToImage
            
            Articles.sharedArticles.append(article)
        }
        
        self.processNews()
        self.activityIndicator.stopAnimating()
        UIApplication.shared.endIgnoringInteractionEvents()
    }
    
    //Process' loaded news from NewsAPI
    func processNews() {
        DispatchQueue.main.async {
            self.newsTableView.reloadData()
        }
    }
    
    //MARK: - Tableview functions

    //Returns a configured cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let newsCell = tableView.dequeueReusableCell(withIdentifier: "NewsCell", for: indexPath) as! NewsCell
        
        newsCell.title.text = Articles.sharedArticles[indexPath.item].title
        newsCell.newsDescription.text = Articles.sharedArticles[indexPath.item].descript
        newsCell.newsImage.downloadImage(from: Articles.sharedArticles[indexPath.item].urlToImage!)
        
        return newsCell
    }
    
    //Sets the number of rows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Articles.sharedArticles.count
    }
    
    //Navigates to WebViewController to show the article
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        Articles.selectedArticle = indexPath.item
        
        performSegue(withIdentifier: "WebViewController", sender: self)
        
    }
}
