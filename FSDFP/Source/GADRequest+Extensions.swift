//
//  GADRequest+Extensions.swift
//  FSDFP
//
//  Created by Dean Chang on 5/18/19.
//  Copyright © 2019 Freestar. All rights reserved.
//

import Foundation

extension GADRequest {
    private static let requestVariantOClassname = "DFPORequest"
    private static let requestVariantNClassname = "DFPNRequest"
    
    private static let variantMap = [ "FSDFPBannerViewVariantO": requestVariantOClassname,
                                    "FSDFPBannerViewVariantN": requestVariantNClassname]
    
    func validateForBannerVariant(_ metaType: NSObject.Type) -> Bool {
        let dynamicType = String(describing: metaType)
        return GADRequest.variantMap[dynamicType] == String(describing: type(of: self))
    }
}
