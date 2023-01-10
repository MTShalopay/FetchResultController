//
//  DownloadController.swift
//  FetchResultController
//
//  Created by Shalopay on 06.01.2023.
//

/*
 https://api.chucknorris.io/jokes/random?category={category}
 */

import Foundation
class DownloadManager {
    static let shared = DownloadManager()
    private init() {
    }
    func downloadJoke(categoryName: String?, completionHandler: ((_ result: JokeCodable?)-> Void)?) {
        var urlRequest = URL(string: RequestJokes.random.description)!
        if let categoryName = categoryName {
            urlRequest = URL(string: RequestJokes.categoryName.description + "\(categoryName)")!
        }
        let session = URLSession(configuration: .default)
        let dataTask = session.dataTask(with: urlRequest) { (data, response, error) in
            if let error = error {
                print("ERROR: \(error)")
                completionHandler?(nil)
                return
            }
            let statusCode = (response as? HTTPURLResponse)?.statusCode
            if statusCode != 200 {
                print("ERROR StatusCode: \(String(describing: statusCode)) \n")
                completionHandler?(nil)
                return
            }
            
            guard let data = data else { return print("Данные по ссылке \(urlRequest) не получены") }
            do {
                let result = try JSONDecoder().decode(JokeCodable.self, from: data)
                completionHandler?(result)
            } catch {
                print("Error for catch: \(error.localizedDescription)")
                completionHandler?(nil)
            }
        }
        dataTask.resume()
    }
}
