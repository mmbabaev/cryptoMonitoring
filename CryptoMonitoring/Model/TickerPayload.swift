//
//  TickerPayload.swift
//  CryptoMonitoring
//
//  Created by Mihail Babaev on 07.03.2018.
//  Copyright © 2018 . All rights reserved.
//

import Foundation

typealias TickerResponse = BinanceStreamResponse<TickerPayload>

struct TickerPayload: Codable {
    let symbol: String
    let currentPriceString: String
    let priceChangeString: String
    let priceChangePercentageString: String
    
    private enum CodingKeys: String, CodingKey {
        case symbol = "s"
        case currentPriceString = "c"
        case priceChangeString = "p"
        case priceChangePercentageString = "P"
    }
}
