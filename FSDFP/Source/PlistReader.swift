//
//  PlistReader.swift
//  FSDFP
//
//  Created by Dean Chang on 2/23/20.
//  Copyright © 2020 Freestar. All rights reserved.
//

import Foundation
import os

// Represents a `Plist` with an associated generic value type conforming to the
// `Codable` protocol.

class Plist<T: Codable> {
    
    @available(iOS 10, *)
    lazy private(set) var logger = OSLog(Plist.self, category: String.loggerBannerCategory)

    fileprivate let resource: String?
    fileprivate let bundle: Bundle
    
    public init(_ resource: String? = nil, in bundle: Bundle = Bundle.main) {
        self.resource = resource
        self.bundle = bundle
    }

    public func decode() -> T? {
        guard let resource = self.resource else {
            return getFromBundledInfo()
        }
        
        guard let path = self.bundle.path(forResource: resource, ofType: "plist", inDirectory: nil) else {
            if #available(iOS 10, *) {
                logger.error("Resource not found in bundle: %@.", self.bundle)
            }
            return nil
        }
        
        do {
            let url = URL(fileURLWithPath: path)
            let data = try Data(contentsOf: url)
            let decoder = PropertyListDecoder()
            let decoded = try decoder.decode(T.self, from: data)
            return decoded
        } catch {
            #if DEBUG
                print(error)
            #endif
        }
        
        return nil
        
    }
    
    private func getFromBundledInfo() -> T? {
        guard let infoDictionary = self.bundle.infoDictionary else {
            if #available(iOS 10, *) {
                logger.error("InfoDictionary for bundle is nil: %@.", self.bundle)
            }
            return nil
        }
        
        do {
            let data = try JSONSerialization.data(withJSONObject: infoDictionary)
            let decoder = JSONDecoder()
            let decoded = try decoder.decode(T.self, from: data)
            return decoded
        } catch {
            if #available(iOS 10, *) {
                logger.error("Error decoding plist infoDictionary: %@.", error.localizedDescription)
            }
        }
        
        return nil
        
    }
    
}
