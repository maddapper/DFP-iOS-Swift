//
//  DFPBanner+Extensions.swift
//  FSDFP
//
//  Created by Dean Chang on 4/11/19.
//  Copyright © 2019 Freestar. All rights reserved.
//

import Foundation
import GoogleMobileAds
import FSCommon

public typealias FSAdEventHandler = @convention(block) (_ methodName: String, _ params: [ String : Any]) -> Void

@objc extension DFPBannerView : GADBannerViewDelegate {
        
    // MARK: static property hash tables
    private static let kDefaultRefreshRate: TimeInterval = 20.01
    private static var _deinitObserver = [String:DeinitializationObserver]()
    private static var _fsManaged = [String:Bool]()
    private static var _fsRefreshRate = [String:TimeInterval]()
    private static var _fsIdentifier = [String:String]()
    private static var _fsTimer = [String:FSWeakGCDTimer]()
    private static var _fsEventHandler = [String:FSAdEventHandler]()
    private static var _fsRequest = [String:GADRequest]()
    private static var _paused = [String:Bool]()
    
    // MARK: stored properties
    fileprivate var _deinitObserver:DeinitializationObserver {
        get {
            let tmpAddress = String(format: "%p", unsafeBitCast(self, to: Int.self))
            return DFPBannerView._deinitObserver[tmpAddress]!
        }
        
        set(newValue) {
            let tmpAddress = String(format: "%p", unsafeBitCast(self, to: Int.self))
            DFPBannerView._deinitObserver[tmpAddress] = newValue
        }
    }
    
    var _fsManaged:Bool {
        get {
            let tmpAddress = String(format: "%p", unsafeBitCast(self, to: Int.self))
            return DFPBannerView._fsManaged[tmpAddress]!
        }
        
        set(newValue) {
            let tmpAddress = String(format: "%p", unsafeBitCast(self, to: Int.self))
            DFPBannerView._fsManaged[tmpAddress] = newValue
        }
    }
    
    var fsRefreshRate:TimeInterval {
        get {
            let tmpAddress = String(format: "%p", unsafeBitCast(self, to: Int.self))
            if let refreshRate: TimeInterval = DFPBannerView._fsRefreshRate[tmpAddress] {
                return refreshRate
            } else {
                // unset so return default
                return DFPBannerView.kDefaultRefreshRate
            }
        }
        
        set(newValue) {
            let tmpAddress = String(format: "%p", unsafeBitCast(self, to: Int.self))
            DFPBannerView._fsRefreshRate[tmpAddress] = newValue
        }
    }
    
    var fsIdentifier:String {
        get {
            let tmpAddress = String(format: "%p", unsafeBitCast(self, to: Int.self))
            return DFPBannerView._fsIdentifier[tmpAddress]!
        }
        
        set(newValue) {
            let tmpAddress = String(format: "%p", unsafeBitCast(self, to: Int.self))
            DFPBannerView._fsIdentifier[tmpAddress] = newValue
        }
    }
    
    var _fsTimer:FSWeakGCDTimer {
        get {
            let tmpAddress = String(format: "%p", unsafeBitCast(self, to: Int.self))
            return DFPBannerView._fsTimer[tmpAddress]!
        }
        
        set(newValue) {
            let tmpAddress = String(format: "%p", unsafeBitCast(self, to: Int.self))
            DFPBannerView._fsTimer[tmpAddress] = newValue
        }
    }
    
    var _fsEventHandler:FSAdEventHandler? {
        get {
            let tmpAddress = String(format: "%p", unsafeBitCast(self, to: Int.self))
            return DFPBannerView._fsEventHandler[tmpAddress]!
        }
        
        set(newValue) {
            let tmpAddress = String(format: "%p", unsafeBitCast(self, to: Int.self))
            DFPBannerView._fsEventHandler[tmpAddress] = newValue
        }
    }
    
    var _fsRequest:GADRequest? {
        get {
            let tmpAddress = String(format: "%p", unsafeBitCast(self, to: Int.self))
            return DFPBannerView._fsRequest[tmpAddress]!
        }
        
        set(newValue) {
            let tmpAddress = String(format: "%p", unsafeBitCast(self, to: Int.self))
            DFPBannerView._fsRequest[tmpAddress] = newValue
        }
    }
    
    var _paused:Bool {
        get {
            let tmpAddress = String(format: "%p", unsafeBitCast(self, to: Int.self))
            return DFPBannerView._paused[tmpAddress]!
        }
        
        set(newValue) {
            let tmpAddress = String(format: "%p", unsafeBitCast(self, to: Int.self))
            DFPBannerView._paused[tmpAddress] = newValue
        }
    }
    
    public func fsAdSize() -> CGSize {
        return adSize.size
    }
    
    // MARK: convenience constructor
    convenience init(eventHandler: @escaping FSAdEventHandler) {
        self.init()
        self._fsEventHandler = eventHandler
        self._fsManaged = true
        self.isAutoloadEnabled = false
        self.delegate = self
        
        onDeinit {
            // timer cleanup
            self._fsTimer.invalidate()
        }
    }
    
    convenience init(eventHandler: @escaping FSAdEventHandler, size adSize: GADAdSize) throws {
        self.init(eventHandler: eventHandler)
        if validate(adSize) {
            self.adSize = adSize
            self.validAdSizes = [NSValueFromGADAdSize(adSize)]
        } else {
            throw DFPErrors.BannerInstantiationException("Invalid ad Size: \(NSStringFromGADAdSize(adSize))")
        }
    }
    
    // MARK: overriden methods
    override open func load(_ request: GADRequest?) {
        super.load(request)
        _fsRequest = request
    }
    
    // MARK: overriden properties
    override open var adSize: GADAdSize {
        // ensure valid ad size
        set {
            if validate(adSize) {
                super.adSize = adSize
            } else {
                assertionFailure("Cannot instantiate ad object due to invalid ad size: \(NSStringFromGADAdSize(adSize))")
            }
        }
        get {
            return super.adSize
        }
    }
    
    // MARK: deinit
    func onDeinit(_ execute: @escaping () -> ()) {
        _deinitObserver = DeinitializationObserver(execute: execute)
    }
    
    // MARK: static dispatch queue
    static var fsQueue: DispatchQueue = {
        var queue = DispatchQueue(label: "io.freestar.mobile.queue.dfpbanner")
        return queue
    }()
    
    // MARK: size validation
    func validate(_ adSize: GADAdSize) -> Bool {
        var validSize = false
        validSize = IsGADAdSizeValid(adSize)
        if validSize {
            // weed out invalid default ad sizes
            let invalidAdSizeMin: GADAdSize = GADAdSizeFromCGSize(CGSize.zero)
            let invalidAdSizeMax: GADAdSize = GADAdSizeFromCGSize(CGSize(width: 1000, height: 1000))
            let invalidAdSizeVMax: GADAdSize = GADAdSizeFromCGSize(CGSize(width: 0, height: 1000))
            let invalidAdSizeHMax: GADAdSize = GADAdSizeFromCGSize(CGSize(width: 1000, height: 0))
            let invalidAdSizeVMin: GADAdSize = GADAdSizeFromCGSize(CGSize(width: 0, height: 1))
            let invalidAdSizeHMin: GADAdSize = GADAdSizeFromCGSize(CGSize(width: 1, height: 0))
            if GADAdSizeEqualToSize(adSize, invalidAdSizeMin) || GADAdSizeEqualToSize(adSize, invalidAdSizeMax) || GADAdSizeEqualToSize(adSize, invalidAdSizeVMax) || GADAdSizeEqualToSize(adSize, invalidAdSizeHMax) || GADAdSizeEqualToSize(adSize, invalidAdSizeVMin) || GADAdSizeEqualToSize(adSize, invalidAdSizeHMin) {
                validSize = false
            }
        }
        return validSize
    }
    
    // MARK: pause / refresh
    public func pauseRefresh() {
        _paused = true
    }
    
    public func resumeRefresh() {
        _paused = false
        _fsTimer.fire()
    }
    
    //TODO: fsReload
    
    // MARK: GADBannerViewDelegate
    public func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        guard let _ = _fsEventHandler else { return }
        _fsEventHandler!(#function, [String.eventBannerViewKey : bannerView])
    }
    
    public func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        guard let _ = _fsEventHandler else { return }
        _fsEventHandler!(#function, [String.eventBannerViewKey : bannerView, String.eventErrorKey : error])
    }
    
    public func adViewWillPresentScreen(_ bannerView: GADBannerView) {
        guard let _ = _fsEventHandler else { return }
        _fsEventHandler!(#function, [String.eventBannerViewKey : bannerView])
    }
    
    public func adViewWillDismissScreen(_ bannerView: GADBannerView) {
        guard let _ = _fsEventHandler else { return }
        _fsEventHandler!(#function, [String.eventBannerViewKey : bannerView])
    }
    
    public func adViewDidDismissScreen(_ bannerView: GADBannerView) {
        guard let _ = _fsEventHandler else { return }
        _fsEventHandler!(#function, [String.eventBannerViewKey : bannerView])
    }
    
    public func adViewWillLeaveApplication(_ bannerView: GADBannerView) {
        guard let _ = _fsEventHandler else { return }
        _fsEventHandler!(#function, [String.eventBannerViewKey : bannerView])
    }
}
