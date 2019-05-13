//
//  Constants.swift
//  FSDFP
//
//  Created by Dean Chang on 4/23/19.
//  Copyright © 2019 Freestar. All rights reserved.
//

import Foundation

extension String {
    static let eventBannerViewKey = "bannerView"
    static let eventErrorKey = "error"
}

extension TimeInterval {
    static let bannerRefreshIntervalMax = 60.0 * 60.0
    static let bannerRefreshIntervalMin = 15.0
    static let bannerRefreshIntervalDefault = 25.01
}
