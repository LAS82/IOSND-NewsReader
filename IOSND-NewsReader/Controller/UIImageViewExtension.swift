//
//  UIImageViewExtension.swift
//  IODND-NewsReader
//
//  Created by Leandro Alves Santos on 19/08/18.
//  Copyright © 2018 Leandro Alves Santos. All rights reserved.
//

import UIKit

//UIImageView's extension
extension UIImageView {
    
    //download an Image using the image's url
    func downloadImage(from url: String){
        
        let urlRequest = URLRequest(url: URL(string: url)!)
        
        let task = URLSession.shared.dataTask(with: urlRequest) { (data,response,error) in
            
            if error != nil {
                return
            }
            
            DispatchQueue.main.async {
                self.image = UIImage(data: data!)
            }
        }
        task.resume()
    }
}
