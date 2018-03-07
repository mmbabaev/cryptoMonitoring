//
//  BinanceDataManager.swift
//  CryptoMonitoring
//
//  Created by Mihail Babaev on 07.03.2018.
//  Copyright © 2018 . All rights reserved.
//

import Foundation

class BinanceDataManager {
    static let shared = BinanceDataManager()
    
    private let storageKey = "BinanceDataManagerUserDefaults"
    private let defaults = UserDefaults.standard
    private let decoder = PropertyListDecoder()
    private let encoder = PropertyListEncoder()
    
    private init() {}
    
    var lastUpdateTime: Date? {
        set {
            defaults.set(newValue, forKey: lastUpdateTimeKey)
        }
        get {
            return defaults.object(forKey: lastUpdateTimeKey) as? Date
        }
    }
    
    func save(binanceSymbols: [BinanceSymbol]) {
        for symbol in binanceSymbols {
            self.save(binanceSymbol: symbol)
        }
    }
    
    func save(binanceSymbol: BinanceSymbol) {
        if let payload = binanceSymbol.payload,
            let payloadData = try? encoder.encode(payload) {
            
            let key = storageKey(for: binanceSymbol)
            defaults.set(payloadData, forKey: key)
        }
    }
    
    func load(binanceSymbol: BinanceSymbol) {
        let key = storageKey(for: binanceSymbol)
        if let payloadData = defaults.object(forKey: key) as? Data,
            let payload = try? decoder.decode(TickerPayload.self, from: payloadData) {
            
            binanceSymbol.fill(with: payload)
        }
    }
    
    private let lastUpdateTimeKey = "\(storageKey)_lastUpdateTime"
    
    private func storageKey(for binanceSymbol: BinanceSymbol) -> String {
        return "\(storageKey)_\(binanceSymbol.symbol)"
    }
}
