//
//  DeinitObserver.swift
//  FSDFP
//
//  Created by Dean Chang on 4/15/19.
//  Copyright © 2019 Freestar. All rights reserved.
//

import Foundation

@objc protocol ObservableDeinitialization: AnyObject {
    func onDeinit(_ execute: @escaping () -> ())
}

@objc class DeinitializationObserver: NSObject {
    
    let execute: () -> ()
    
    init(execute: @escaping () -> ()) {
        self.execute = execute
    }
    
    deinit {
        execute()
    }
}
