//
//  FreestarInfo.swift
//  FSDFP
//
//  Created by Dean Chang on 2/21/20.
//  Copyright © 2020 Freestar. All rights reserved.
//

import Foundation

struct FreestarInfo: Codable {
    let failSafeModeEnabled: Bool
    
    private func parsePlist() {
        // Define a Plist
        let plist = Plist<Info>()

        // Decode it
        let info = plist.decode()

        // Then access it's properties
        info?.baseUrl    // http://debug.InfoKit.local
        info?.staticUrl  // http://debug.static.InfoKit.local
    }
}
