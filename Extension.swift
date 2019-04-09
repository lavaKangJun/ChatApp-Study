//
//  Extension.swift
//  FirebaseChat
//
//  Created by 강준영 on 08/04/2019.
//  Copyright © 2019 강준영. All rights reserved.
//

import UIKit

let imageCache = NSCache<NSString, UIImage>()

extension UIImageView {
    func setProfileImage(strurl: String) {
        self.image = nil
        
        if let image = imageCache.object(forKey: strurl as NSString) {
            self.image = image
            return
        }
        
        guard let url = URL(string: strurl) else {
            return
        }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let image = data {
                DispatchQueue.main.async {
                    self.image = UIImage(data:image)
                    imageCache.setObject(UIImage(data: image)!, forKey: url.absoluteString as NSString)
                }
            }
        }.resume()
    }
}
