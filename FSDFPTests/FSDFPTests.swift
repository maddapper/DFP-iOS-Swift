//
//  FSDFPTests.swift
//  FSDFPTests
//
//  Created by Dean Chang on 4/11/19.
//  Copyright © 2019 Freestar. All rights reserved.
//

import XCTest
@testable import FSDFP

class FSDFPTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        let anyobjectype : AnyObject.Type = NSClassFromString("FSDFP.FSDFPBannerViewVariantO")!
        print("\(anyobjectype)")
        let nsobjectype : NSObject.Type = anyobjectype as! NSObject.Type
        print("\(nsobjectype)")
        let banner: AnyObject = nsobjectype.init()
        print("\(banner)")
//        let interstitial: FSDFPInterstitial = FSDFPInterstitial(eventHandler: nil, adUnitId: "/15184186/Freestar_Test_320x50")
//        print(interstitial.adUnitID)
    }
    
    func testExample1() {
        let anyobjectype : AnyObject.Type = NSClassFromString("DFPRequest")!
        print("\(anyobjectype)")
        let nsobjectype : NSObject.Type = anyobjectype as! NSObject.Type
        print("\(nsobjectype)")
        let banner: AnyObject = nsobjectype.init()
        print("\(banner)")
        //        let interstitial: FSDFPInterstitial = FSDFPInterstitial(eventHandler: nil, adUnitId: "/15184186/Freestar_Test_320x50")
        //        print(interstitial.adUnitID)
    }
}
