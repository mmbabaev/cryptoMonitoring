//
//  AssetPair.swift
//  CryptoMonitoring
//
//  Created by Mihail Babaev on 07.03.2018.
//  Copyright © 2018 . All rights reserved.
//

import Foundation
import UIKit

enum SymbolStatus {
    case increased
    case decreased
}

class BinanceSymbol {
    let symbol: String
    
    init(symbol: String) {
        self.symbol = symbol.lowercased()
    }
    
    private(set) var currentPriceString: String = ""
    private(set) var currentPrice: Decimal = 0
    private(set) var previousPrice: Decimal = 0
    private(set) var priceChange: Decimal = 0
    private(set) var priceChangePercentage: Double = 0
    
    private(set) var payload: TickerPayload?
    
    var status: SymbolStatus {
        if priceChange >= 0 {
            return .increased
        } else {
            return .decreased
        }
    }
    
    func fill(with payload: TickerPayload) {
        self.payload = payload
        
        self.currentPriceString = payload.currentPriceString
        self.currentPrice = Decimal(string: payload.currentPriceString) ?? 0
        
        self.priceChange = Decimal(string: payload.priceChangeString) ?? 0
        self.priceChangePercentage = Double(payload.priceChangePercentageString) ?? 0
    }
}
