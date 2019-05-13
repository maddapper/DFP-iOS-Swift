//
//  Runtime.swift
//  FSDFP
//
//  Created by Dean Chang on 5/13/19.
//  Copyright © 2019 Freestar. All rights reserved.
//

import Foundation

extension String {
    
    func convertToClass<NSObject>(_ bundle: Bundle?) -> NSObject.Type? {
        return StringClassConverter<NSObject>.convert(string: self, bundle: bundle)
    }
}

class StringClassConverter<NSObject> {
    
    static func convert(string className: String, bundle: Bundle?) -> NSObject.Type? {

        if let objcClass: NSObject.Type = NSClassFromString("\(className)") as? NSObject.Type {
            return objcClass
        }
        
        guard let bundle = bundle else {
            return nil
        }
        guard let nameSpace = bundle.infoDictionary!["CFBundleExecutable"] else {
            return nil
        }
        guard let swiftClass: NSObject.Type = NSClassFromString("\(nameSpace).\(className)") as? NSObject.Type else {
            return nil
        }

        return swiftClass
    }
    
}
