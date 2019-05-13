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
    
//    @objc public func removeHBKeywords(request: GADRequest) {
//        let request: String = String(describing: type(of: adObject))
//        if (request == .DFP_Object_Name || request == .DFP_O_Object_Name ||
//            request == .DFP_N_Object_Name || request == .GAD_N_Object_Name ||
//            request == .GAD_Object_Name) {
//            let hasDFPMember = adObject.responds(to: NSSelectorFromString("setCustomTargeting:"))
//            if (hasDFPMember) {
//                //check if the publisher has added any custom targeting. If so then merge the bid keywords to the same.
//                if (adObject.value(forKey: "customTargeting") != nil) {
//                    var existingDict: [String: Any] = adObject.value(forKey: "customTargeting") as! [String: Any]
//                    for (key, _)in existingDict {
//                        if (key.starts(with: "hb_")) {
//                            existingDict[key] = nil
//                        }
//                    }
//                    adObject.setValue( existingDict, forKey: "customTargeting")
//                }
//            }
//        }
//    }
    
    @objc func validateAndAttachKeywords(request: GADRequest?, identifier: String?) {
        guard let gadRequest = request else {
            return
        }
        
        guard let identifier = identifier else {
            return
        }
        
        let dfpRequest: DFPNRequest = gadRequest as! DFPNRequest
        guard let bidManagerClass: NSObject.Type = "PBBidManager".convertToClass(Bundle.prebid) else {
            return
        }
        
        guard let bidManager: NSObject = bidManagerClass.perform(NSSelectorFromString("sharedInstance"))?.takeUnretainedValue() as? NSObject else {
            return
        }
        bidManager.printMethodNames()
        
        let adUnitByIdentifierSelector = NSSelectorFromString("adUnitByIdentifier:")
        if (bidManager.responds(to: adUnitByIdentifierSelector)) {
            guard let adUnit: NSObject = (bidManager.perform(adUnitByIdentifierSelector, with: identifier)?.takeUnretainedValue()) as? NSObject else {
                return
            }
            
            let keywordsForWinningBidForAdUnitSelector = NSSelectorFromString("keywordsForWinningBidForAdUnit:")
            if (bidManager.responds(to: keywordsForWinningBidForAdUnitSelector)) {
                guard let keywords = bidManager.perform(keywordsForWinningBidForAdUnitSelector, with: adUnit)?.takeUnretainedValue() as? [String:Any] else {
                    return
                }
                
                //        check if the publisher has added any custom targeting. If so then merge the bid keywords to the same.
                if (dfpRequest.customTargeting != nil) {
                    var existingDict: [String: Any] = dfpRequest.customTargeting as! [String : Any]
                    existingDict.merge(dict: keywords)
                    dfpRequest.customTargeting = existingDict
                } else {
                    dfpRequest.customTargeting = keywords
                }
            }
        }

    }
}
