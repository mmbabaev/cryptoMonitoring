//
//  BinanceStreamResponse.swift
//  CryptoMonitoring
//
//  Created by Mihail Babaev on 07.03.2018.
//  Copyright © 2018. All rights reserved.
//

import Foundation

struct BinanceStreamResponse<Payload: Decodable>: Decodable {
    let stream: String
    let data: Payload
}
