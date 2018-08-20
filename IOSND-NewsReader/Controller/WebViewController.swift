//
//  WebViewController.swift
//  IODND-NewsReader
//
//  Created by Leandro Alves Santos on 18/08/18.
//  Copyright © 2018 Leandro Alves Santos. All rights reserved.
//

import UIKit
import CoreData

class WebViewController: UIViewController, UIWebViewDelegate, NSFetchedResultsControllerDelegate {

    //MARK: - Properties
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    var url: String?
    
    @IBOutlet weak var webView: UIWebView!
    
    let fetch: NSFetchRequest<ArticleData> = ArticleData.fetchRequest()
    
    //MARK: - UIViewController functions
    
    //Configures the ActivityIndicator
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        
        view.addSubview(activityIndicator)
        view.bringSubview(toFront: activityIndicator)
    }
    
    //Loads the site's article and removes from the database
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        activityIndicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        let articleData = getArticleAlreadySaved()
        
        if let articleFromDB = articleData {
            
            DataController.sharedDataController.viewContext.delete(articleFromDB)
        }
        
        let url = Articles.sharedArticles[Articles.selectedArticle!].url
        webView.loadRequest(URLRequest(url: URL(string: url!)!))
    }
    
    //MARK: - UIWebViewDelegate functions
    
    //Stops the activity indicator when the page finish load
    func webViewDidFinishLoad(_ webView: UIWebView) {
        activityIndicator.stopAnimating()
        UIApplication.shared.endIgnoringInteractionEvents()
    }
    
    //Stops the activity indicator and shows the error message
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        activityIndicator.stopAnimating()
        UIApplication.shared.endIgnoringInteractionEvents()
    }
    
    //MARK: - IBAction functions
    
    //Returns to news list
    @IBAction func closeView(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
    }
    
    //Save the current article and returns to news list
    @IBAction func saveNews(_ sender: Any) {
        
        let selectedArticle = Articles.sharedArticles[Articles.selectedArticle!]
        
        if !articleAlreadySaved() {
            let articleData = ArticleData(context: DataController.sharedDataController.viewContext)
            
            articleData.descript = selectedArticle.descript
            articleData.title = selectedArticle.title
            articleData.url = selectedArticle.url
            articleData.urlToImage = selectedArticle.urlToImage
            
            try? DataController.sharedDataController.viewContext.save()
        }
        
        dismiss(animated: true, completion: nil)
        
    }
    
    //MARK: - Private functions
    
    //Executed after alert's OK button is clicked
    func alertOkClicked(_ alert: UIAlertAction?) {
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    //Indicates if the article was already saved on the database
    func articleAlreadySaved() -> Bool {
        
        let articleData = getArticleAlreadySaved()
        
        return articleData != nil
    }
    
    //Returns the current article as an ArticleData (Database model) object
    func getArticleAlreadySaved() -> ArticleData? {
        
        let articles = try? DataController.sharedDataController.viewContext.fetch(fetch)
        let selectedArticle = Articles.sharedArticles[Articles.selectedArticle!]
        
        for article in articles! {
            
            if(article.descript == selectedArticle.descript &&
                article.title == selectedArticle.title &&
                article.url == selectedArticle.url &&
                article.urlToImage == selectedArticle.urlToImage) {
                
                return article
            }
        }
        
        return nil
    }

}
