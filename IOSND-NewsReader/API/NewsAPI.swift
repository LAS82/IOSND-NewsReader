//
//  NewsAPI.swift
//  IODND-NewsReader
//
//  Created by Leandro Alves Santos on 18/08/18.
//  Copyright © 2018 Leandro Alves Santos. All rights reserved.
//

import UIKit

class NewsAPI {
    
    //Populates the articles models object
    func populateArticles(completionHandler: @escaping (String) -> Void){
        
        let apiKey = "YOUR_API_KEY_HERE"
        
        Articles.sharedArticles.removeAll()
        
        let urlRequest = URLRequest(url: URL(string: "https://newsapi.org/v2/everything?sources=cnn&apiKey="+apiKey)!)
        
        let sessionConfiguration = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfiguration)
        
        let task = session.dataTask(with: urlRequest) { (data,response,error) in
            
            let errorMessage = self.verifyAPIProcessing(data: data, response: response, error: error)
            if(errorMessage != "") {
                completionHandler(errorMessage)
                return
            }
            
            do {
                let parsedResult = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! [String : AnyObject]
                
                if let articles = parsedResult["articles"] as? [[String : AnyObject]] {
                    
                    for article in articles {
                        
                        let articleModel = Article()
                        
                        //Three necessary data to add the article to the app
                        if let title = article["title"] as? String,
                            let url = article["url"] as? String,
                            let urlToImage = article["urlToImage"] as? String {
                            
                            articleModel.descript = ""
                            if let desc = article["description"] as? String {
                                articleModel.descript = desc
                            }
                        
                            articleModel.title = title
                            articleModel.url = url
                            articleModel.urlToImage = urlToImage
                            
                            Articles.sharedArticles.append(articleModel)
                        }
                        
                    }
                }
            }
            catch {
                completionHandler(error.localizedDescription)
                return
            }
            
            completionHandler("")
            
        }
        
        task.resume()
        
    }
    
    
    //Verifies if the process was executed with success
    private func verifyAPIProcessing(data: Data!, response:URLResponse!, error:Error!) -> String {
        
        guard (error == nil) else {
            
            return (error?.localizedDescription)!
        }
        
        guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
            
            return "The request returned a status other than 2xx"
        }
        
        guard data != nil else {
            
            return "No images was returned"
        }
        
        return ""
    }

}
