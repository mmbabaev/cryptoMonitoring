//
//  ApiError.swift
//  CryptoMonitoring
//
//  Created by Mihail Babaev on 05.03.2018.
//  Copyright © 2018 . All rights reserved.
//

import Foundation

enum ApiError: Error {
    case noConnection
    case unknown
    case text(message: String)
    
    var textDescription: String {
        switch self {
        case .noConnection:
            return "No internet connection."
        case .unknown:
            return "Unknown error. Try again later."
        case .text(let message):
            return message
        }
    }
}
