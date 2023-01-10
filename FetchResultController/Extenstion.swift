//
//  Extenstion.swift
//  FetchResultController
//
//  Created by Shalopay on 07.01.2023.
//

import Foundation

extension Date {
    func formated() -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ru_RU")
        dateFormatter.dateFormat = "MM-dd-yyyy HH:mm"
        return dateFormatter.string(from: Date())
    }
}
