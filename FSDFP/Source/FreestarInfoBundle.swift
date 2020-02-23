//
//  FreestarInfoBundle.swift
//  FSDFP
//
//  Created by Dean Chang on 2/23/20.
//  Copyright © 2020 Freestar. All rights reserved.
//

import Foundation

struct FreestarInfo: Codable {
    let failsafeModeEnabled: Bool
}

struct FreestarInfoBundle: Codable {
    let freestar: FreestarInfo
}



