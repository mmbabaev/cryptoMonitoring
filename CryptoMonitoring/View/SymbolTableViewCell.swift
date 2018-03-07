//
//  SymbolTableViewCell.swift
//  CryptoMonitoring
//
//  Created by Mihail Babaev on 07.03.2018.
//  Copyright © 2018 . All rights reserved.
//

import UIKit

class SymbolTableViewCell: UITableViewCell {
    static let identifier = "SymbolTableViewCell"

    @IBOutlet weak var symbolLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var priceChangeLabel: UILabel!
    @IBOutlet weak var priceChangePercentageLabel: UILabel!
    
    var binanceSymbol: BinanceSymbol? {
        didSet {
            reload()
        }
    }
    
    func reload() {
        guard let binanceSymbol = self.binanceSymbol else {
            return
        }
        
        self.symbolLabel.text = binanceSymbol.symbol.uppercased()
        
        self.priceLabel.text = binanceSymbol.currentPriceString
        
        priceChangeLabel.text = String(describing: binanceSymbol.priceChange)
        let changeCharacter = binanceSymbol.status == .decreased ? "▼" : "▲"
        let percentageString = String(format: "%.3f", binanceSymbol.priceChangePercentage)
        priceChangePercentageLabel.text = "\(changeCharacter) \(percentageString)"
        
        let color: UIColor = binanceSymbol.status == .increased ? .green : .red
        priceChangePercentageLabel.textColor = color
        priceChangeLabel.textColor = color
    }
}
