//
//  ReachabilityManager.swift
//  Pokemon
//
//  Created by Артем Пашевич on 20.04.23.
//

import Foundation
import Reachability

protocol ReachabilityProtocol {
    var isNetworkAvailable: Bool { get }
}

class ReachabilityManager: ReachabilityProtocol {
    private let reachability = try! Reachability()
    
    init() {
        startMonitoring()
    }
    
    var isNetworkAvailable: Bool {
        return reachability.connection != .unavailable
    }
    
    private func startMonitoring() {
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(notification:)), name: .reachabilityChanged, object: reachability)
        do {
            try reachability.startNotifier()
        } catch {
            print("Could not start reachability notifier")
        }
    }
    
    @objc private func reachabilityChanged(notification: Notification) {
        guard let reachability = notification.object as? Reachability else {
            return
        }
        if reachability.connection == .unavailable {
            print("Network not reachable")
        } else {
            print("Network reachable")
        }
    }
    
    deinit {
        reachability.stopNotifier()
        NotificationCenter.default.removeObserver(self)
    }
}
