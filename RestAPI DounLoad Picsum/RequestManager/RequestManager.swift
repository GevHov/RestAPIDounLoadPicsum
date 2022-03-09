//
//  RequestManager.swift
//  RestAPI DounLoad Picsum
//
//  Created by Gevorg Hovhannisyan on 06.10.21.
//

import Foundation

class RequestManager {
    
    static var currentPage = 1
    static var isLoading = false
    static func getImages(for pageNumber: Int, complation: @escaping([ImageURL]?, Error?) -> Void) {
        
        if isLoading {
            
            return
        }
        isLoading = true
        let urlString = "https://picsum.photos/v2/list?page=\(pageNumber)&limit=20"
        let task = URLSession.shared.dataTask(with: URL .init(string: urlString)!) {data, response, error in DispatchQueue.main.async {
            
            self.isLoading = false
        }
            if error != nil {
                
                complation(nil,error)
                return
            }
            do {
                let parseImages = try JSONDecoder().decode([ImageURL].self, from: data!)
                complation (parseImages,nil)
            }catch (let error) {
                complation(nil, error)
            }
        }
        task.resume()
    }
}
