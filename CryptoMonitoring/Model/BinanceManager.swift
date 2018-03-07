//
//  BinanceWebSocketClient.swift
//  CryptoMonitoring
//
//  Created by Mihail Babaev on 06.03.2018.
//  Copyright © 2018 . All rights reserved.
//

import Foundation
import Starscream
import Reachability


protocol BinanceManagerDelegate: class {
    
    func binanceManagerWebSocketDidConnect(_ binanceManager: BinanceManager)
    
    func binanceManager(_ binanceManager: BinanceManager,
                        webSocketDidDisconnectWith error: ApiError)
    
    func binanceManager(_ binanceManager: BinanceManager,
                        didUpdate symbol: BinanceSymbol,
                                at index: Int)
}


class BinanceManager {
    static let shared = BinanceManager()
    
    
    
    private(set) var isConnected: Bool = false
    
    private var symbolsStrings: [String] = [] {
        didSet {
            self.fillSymbolPairs()
        }
    }
    private(set) var symbolsDict: [String : BinanceSymbol] = [:]
    
    private(set) var lastUpdateTime: Date?
    
    private let baseUrl = "wss://stream.binance.com:9443/"
    
    private weak var delegate: BinanceManagerDelegate?
    private var webSocket: WebSocket?
    
    private var reachability = Reachability()!
    private let dataManager = BinanceDataManager.shared
    
    private init() {
        lastUpdateTime = dataManager.lastUpdateTime
        self.setupReachability()
    }
    
    func connectTickersStream(for symbols: [String], delegate: BinanceManagerDelegate) {
        self.symbolsStrings = symbols
        webSocket?.disconnect()
        
        self.delegate = delegate
        
        let fullUrl = self.fullUrl(for: symbols)
        webSocket = WebSocket(url: fullUrl)
        webSocket?.delegate = self
        webSocket?.connect()
    }
    
    func disconnect() {
        webSocket?.disconnect()
        self.save()
    }
    
    func save() {
        let symbols = Array(symbolsDict.values)
        dataManager.save(binanceSymbols: symbols)
        dataManager.lastUpdateTime = self.lastUpdateTime
    }
    
    deinit {
        save()
    }
    
    private func setupReachability() {
        reachability.whenReachable = { _ in
            self.webSocket?.connect()
        }
        reachability.whenUnreachable = { _ in
            self.isConnected = false
            self.disconnect()
            self.delegate?.binanceManager(self, webSocketDidDisconnectWith: ApiError.noConnection)
        }
        
        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
    }
    
    private func fullUrl(for symbols: [String]) -> URL {
        var result = baseUrl + "stream?streams="
        for symbol in symbols {
            result.append(self.aggStreamName(for: symbol.lowercased()))
        }
        return URL(string: result)!
    }

    private func aggStreamName(for symbol: String) -> String {
        return "\(symbol)@ticker/"
    }
    
    private func fillSymbolPairs() {
        self.symbolsDict = [:]
        for symbol in symbolsStrings {
            let binanceSymbol = BinanceSymbol(symbol: symbol)
            dataManager.load(binanceSymbol: binanceSymbol)
            symbolsDict[symbol] = binanceSymbol
        }
    }
    
    fileprivate func parseAndHandleTickerData(_ data: Data) throws {
        let decoder = JSONDecoder()
        let response = try decoder.decode(TickerResponse.self, from: data)
        try self.handleTickerPayload(response.data)
    }
    
    fileprivate func handleTickerPayload(_ payload: TickerPayload) throws {
        let symbol = payload.symbol
        
        guard let binanceSymbol = symbolsDict[symbol],
            let index = symbolsStrings.index(of: symbol) else {
                throw ApiError.unknown
        }
        
        let previousPrice = binanceSymbol.currentPrice
        binanceSymbol.fill(with: payload)
        if previousPrice != binanceSymbol.currentPrice {
            self.lastUpdateTime = Date()
            delegate?.binanceManager(self, didUpdate: binanceSymbol, at: index)
        }
    }
}

extension BinanceManager: WebSocketDelegate {
    
    func websocketDidConnect(socket: WebSocketClient) {
        isConnected = true
        delegate?.binanceManagerWebSocketDidConnect(self)
    }
    
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        isConnected = false
        save()
        
        let apiError: ApiError
        if let error = error {
            apiError = ApiError.text(message: error.localizedDescription)
        } else {
            apiError = ApiError.unknown
        }
        delegate?.binanceManager(self, webSocketDidDisconnectWith: apiError)
    }
    
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        guard let data = text.data(using: .utf8) else {
            return
        }
        
        do {
            try self.parseAndHandleTickerData(data)
        } catch(let error) {
            print(error.localizedDescription)
        }
    }
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        //do nothing
    }
}
