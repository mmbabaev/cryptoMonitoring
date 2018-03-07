//
//  Date+TimeFormatter.swift
//  CryptoMonitoring
//
//  Created by Mihail Babaev on 07.03.2018.
//  Copyright © 2018 . All rights reserved.
//

import Foundation

extension Date {
    var timeString: String {
        return Date.timeFormatter.string(from: self)
    }
    
    private static let timeFormatter = createTimeFormatter()
    
    private static func createTimeFormatter() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter
    }
}
