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
    
    func bidManager() throws -> NSObject? {
        guard let bidManagerClass: NSObject.Type = "PBBidManager".convertToClass(Bundle.prebid) else {
            throw FSDFPErrors.PrebidFrameworkMissing("Prebid framework not found.")
        }
        guard let bidManager: NSObject = bidManagerClass.perform(NSSelectorFromString("sharedInstance"))?.takeUnretainedValue() as? NSObject else {
            throw FSDFPErrors.PrebidFrameworkMissing("Prebid framework not found.")
        }
        return bidManager
    }
    
    func adUnitWith(identifier: String?) -> NSObject? {        
        let adUnitByIdentifierSelector = NSSelectorFromString("adUnitByIdentifier:")
        if (try! bidManager()!.responds(to: adUnitByIdentifierSelector)) {
            guard let adUnit: NSObject = (try! bidManager()!.perform(adUnitByIdentifierSelector, with: identifier)?.takeUnretainedValue()) as? NSObject else {
                return nil
            }
            return adUnit
        }
        return nil
    }
    
    func keywordsFor(identifier: String) -> [String: Any]? {
        let adUnit = adUnitWith(identifier: identifier)
        let keywordsForWinningBidForAdUnitSelector = NSSelectorFromString("keywordsForWinningBidForAdUnit:")
        if (try! bidManager()!.responds(to: keywordsForWinningBidForAdUnitSelector)) {
            guard let keywords = try! bidManager()!.perform(keywordsForWinningBidForAdUnitSelector, with: adUnit)?.takeUnretainedValue() as? [String:Any] else {
                return nil
            }
            return keywords
        }
        return nil
    }
    
    func mergeFSAppKVPair(_ keywords: [String: Any]) -> [String: Any] {
        var fsAppKV: [String: Any] = ["fs_app":"true"]
        fsAppKV.merge(dict: keywords)
        return keywords
    }
    
    @objc public func removeHBKeywords(request: GADRequest?) {
        precondition(request != nil)
        guard let gadRequest = request else {
            return
        }
        
        let dfpRequest: DFPNRequest = gadRequest as! DFPNRequest
        
        //check if the publisher has added any custom targeting. If so then merge the bid keywords to the same.
        var existingDict: [String: Any] = dfpRequest.customTargeting as! [String : Any]
        for (key, _)in existingDict {
            if (key.starts(with: "hb_")) {
                existingDict[key] = nil
            }
        }
        dfpRequest.customTargeting = existingDict
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
        
        let dfpRequest: DFPNRequest = gadRequest as! DFPNRequest
        guard let keywords = keywordsFor(identifier: identifier) else {
            return
        }
        
        // check if the publisher has added any custom targeting. If so then merge the bid keywords to the same.
        if (dfpRequest.customTargeting != nil) {
            var existingDict: [String: Any] = dfpRequest.customTargeting as! [String : Any]
            existingDict.merge(dict: keywords)
            dfpRequest.customTargeting = mergeFSAppKVPair(existingDict)
        } else {
            dfpRequest.customTargeting = mergeFSAppKVPair(keywords)
        }
    }
}
