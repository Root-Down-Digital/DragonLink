//
//  StatusViewModel.swift
//  WarDragon
//
//  Created by Luke on 11/18/24.
//

import Foundation
import CoreLocation
import SwiftUI

class StatusViewModel: ObservableObject {
    @Published var statusMessages: [StatusMessage] = []
    
    struct StatusMessage: Identifiable {
        let id = UUID()
        var serialNumber: String
        var timestamp: Double
        var gpsData: GPSData
        var systemStats: SystemStats
        
        struct GPSData {
            var latitude: Double
            var longitude: Double
            var altitude: Double
            var speed: Double
            
            var coordinate: CLLocationCoordinate2D {
                CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            }
        }
        
        struct SystemStats {
            var cpuUsage: Double
            var memory: MemoryStats
            var disk: DiskStats
            var temperature: Double
            var uptime: Double
            
            struct MemoryStats {
                var total: Int64
                var available: Int64
                var percent: Double
                var used: Int64
                var free: Int64
                var active: Int64
                var inactive: Int64
                var buffers: Int64
                var cached: Int64
                var shared: Int64
                var slab: Int64
            }
            
            struct DiskStats {
                var total: Int64
                var used: Int64
                var free: Int64
                var percent: Double
            }
        }
    }
    
    func handleStatusMessage(_ message: String) {
        if let data = message.data(using: .utf8) {
            let parser = CoTMessageParser()
            let xmlParser = XMLParser(data: data)
            xmlParser.delegate = parser
            
            if xmlParser.parse(), let statusMessage = parser.statusMessage {
                DispatchQueue.main.async {
                    if let index = self.statusMessages.firstIndex(where: { $0.serialNumber == statusMessage.serialNumber }) {
                        self.statusMessages[index] = statusMessage
                    } else {
                        self.statusMessages.append(statusMessage)
                    }
                }
            }
        }
    }
}
