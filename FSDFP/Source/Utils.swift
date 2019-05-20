/*   Copyright 2018-2019 Prebid.org, Inc.
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

import Foundation

public class Utils: NSObject {
    
    /**
     * The class is created as a singleton object & used
     */
    public static let shared = Utils()
    
    /**
     * The initializer that needs to be created only once
     */
    private override init() {
        super.init()
        
    }

//    func bidManager() throws -> NSObject? {
//        guard let bidManagerClass: NSObject.Type = "PBBidManager".convertToClass(Bundle.prebid) else {
//            throw FSDFPErrors.PrebidFrameworkMissing("Prebid framework not found.")
//        }
//
//        guard let bidManager: NSObject = bidManagerClass.perform(NSSelectorFromString("sharedInstance"))?.takeUnretainedValue() as? NSObject else {
//            throw FSDFPErrors.PrebidFrameworkMissing("Prebid framework not found.")
//        }
//        return bidManager
//    }
//
//    func adUnitWith(identifier: String?) -> NSObject? {
//        let adUnitByIdentifierSelector = NSSelectorFromString("adUnitByIdentifier:")
//        if (try! bidManager()!.responds(to: adUnitByIdentifierSelector)) {
//            guard let adUnit: NSObject = (try! bidManager()!.perform(adUnitByIdentifierSelector, with: identifier)?.takeUnretainedValue()) as? NSObject else {
//                return nil
//            }
//            return adUnit
//        }
//        return nil
//    }
    
    func keywordsFor(identifier: String) -> [AnyHashable: Any]? {
        return PrebidRuntimeUtils.keywords(withIdentifier: identifier)
    }
    
    func mergeFSAppKVPair(_ keywords: [AnyHashable: Any]) -> [AnyHashable: Any] {
        var fsAppKV: [AnyHashable: Any] = ["fs_app":"true"]
        fsAppKV.merge(dict: keywords)
        return fsAppKV
    }
    
    @objc public func removeHBKeywords(request: GADRequest?) {
        precondition(request != nil)
        guard let gadRequest = request else {
            return
        }
        
        guard var existingDict: [String: Any] = gadRequest.customTargeting as? [String : Any] else {
            return
        }
        
        //check if the publisher has added any custom targeting. If so then merge the bid keywords to the same.
        for (key, _)in existingDict {
            if (key.starts(with: "hb_")) {
                existingDict[key] = nil
            } else if (key == "fs_app") {
                existingDict[key] = nil
            }
        }
        gadRequest.customTargeting = existingDict
    }

    @objc func validateAndAttachKeywords(request: GADRequest?, identifier: String?) {
        precondition(request != nil)
        precondition(identifier != nil)
        guard let gadRequest = request else {
            return
        }
        guard let identifier = identifier else {
            return
        }
        
        // ensure dfpRequest is not nil
        gadRequest.customTargeting = gadRequest.customTargeting ?? [AnyHashable: Any]()
        guard let existingDict = gadRequest.customTargeting else {
            return
        }
        var mergedDict = mergeFSAppKVPair(existingDict)
        gadRequest.customTargeting = mergedDict
        guard let keywords = keywordsFor(identifier: identifier) else {
            // no bid keywords so bail early
            return
        }
        guard let bidValue: String = keywords["hb_pb"] as? String else {
            // no hb_pb bid entry so bail early
            return
        }
        
        if bidValue != "0.00" {
            // merge the bid keywords
            mergedDict.merge(dict: keywords)
            gadRequest.customTargeting = mergedDict
        }
    }
}
