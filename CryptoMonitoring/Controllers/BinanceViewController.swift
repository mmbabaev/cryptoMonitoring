//
//  ViewController.swift
//  CryptoMonitoring
//
//  Created by Mihail Babaev on 04.03.2018.
//  Copyright © 2018 . All rights reserved.
//

import UIKit

class BinanceViewController: UIViewController {
    
    @IBOutlet var headerView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var statusImageView: UIImageView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var lastUpdateTimeLabel: UILabel!
    
    private var errorHeaderView: UIView?
    
    let symbols = ["BNBBTC", "LTCBTC", "ETHBTC"]
    
    let manager = BinanceManager.shared

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Binance"
        
        setupTableView()
        setupNavigationBar()
        
        manager.connectTickersStream(for: symbols, delegate: self)
        updateLastUpdateTime()
    }
    
    private func reloadStatus() {
        if manager.isConnected {
            statusLabel.text = "Status: connected"
            statusImageView.image = UIImage(named: "online")
        } else {
            statusLabel.text = "Status: disconnected"
            statusImageView.image = UIImage(named: "offline")
        }
    }
    
    private func setupNavigationBar() {
        guard let navigationBar = self.navigationController?.navigationBar else {
            return
        }
        navigationBar.barTintColor = .black
        navigationBar.setTextColor(.white)
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = false
    }
    
    fileprivate func updateLastUpdateTime() {
        lastUpdateTimeLabel.text = manager.lastUpdateTime?.timeString
    }
}

extension BinanceViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SymbolTableViewCell.identifier, for: indexPath) as! SymbolTableViewCell
        
        let symbol = symbols[indexPath.row]
        cell.binanceSymbol = manager.symbolsDict[symbol]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return symbols.count
    }
}

extension BinanceViewController: BinanceManagerDelegate {
    func binanceManagerWebSocketDidConnect(_ binanceManager: BinanceManager) {
        self.reloadStatus()
    }
    
    func binanceManager(_ binanceManager: BinanceManager, webSocketDidDisconnectWith error: ApiError) {
        self.reloadStatus()
    }
    
    func binanceManager(_ binanceManager: BinanceManager, didUpdate symbol: BinanceSymbol, at index: Int) {
        let indexPath = IndexPath(item: index, section: 0)
        tableView.reloadRows(at: [indexPath], with: .fade)
        updateLastUpdateTime()
    }
}

