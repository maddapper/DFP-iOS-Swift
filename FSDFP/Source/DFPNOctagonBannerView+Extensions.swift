////
////  DFPBanner+Extensions.swift
////  FSDFP
////
////  Created by Dean Chang on 4/11/19.
////  Copyright © 2019 Freestar. All rights reserved.
////
//
//import Foundation
//import GoogleMobileAds
//import FSCommon
//
//public typealias FSAdEventHandler = @convention(block) (_ methodName: String, _ params: [ String : Any]) -> Void
//
//@objc public protocol FSRegistrationDelegate { }
//
//@objc extension DFPNOctagonBannerView : GADBannerViewDelegate {
//    
//    // MARK: static property hash tables
//    private static let kDefaultRefreshRate: TimeInterval = 20.01
//    private static var _deinitObserver = [String:DeinitializationObserver]()
//    private static var _fsManaged = [String:Bool]()
//    private static var _fsRefreshRate = [String:TimeInterval]()
//    private static var _fsIdentifier = [String:String]()
//    private static var _fsTimer = [String:FSWeakGCDTimer]()
//    private static var _fsEventHandler = [String:FSAdEventHandler]()
//    private static var _fsRequest = [String:GADRequest]()
//    private static var _paused = [String:Bool]()
//    private static var _registrationDelegate = [String:FSRegistrationDelegate]()
//    
//    // MARK: convenience constructor
//    convenience init(eventHandler: @escaping FSAdEventHandler) {
//        self.init()
//        self.fsEventHandler = eventHandler
//        self.fsManaged = true
//        self.isAutoloadEnabled = false
//        self.delegate = self
//        
//        onDeinit {
//            // timer cleanup
//            self.fsTimer!.invalidate()
//        }
//    }
//    
//    public convenience init(eventHandler: @escaping FSAdEventHandler, size adSize: GADAdSize) {
//        self.init(eventHandler: eventHandler)
//        if validate(adSize) {
//            self.adSize = adSize
//            self.validAdSizes = [NSValueFromGADAdSize(adSize)]
//        }
//    }
//    
//    // MARK: deinit
//    func onDeinit(_ execute: @escaping () -> ()) {
//        deinitObserver = DeinitializationObserver(execute: execute)
//    }
//    
//    // MARK: static dispatch queue
//    static var fsQueue: DispatchQueue = {
//        var queue = DispatchQueue(label: "io.freestar.mobile.queue.dfpbanner")
//        return queue
//    }()
//    
//    // MARK: size validation
//    func validate(_ adSize: GADAdSize) -> Bool {
//        var validSize = false
//        validSize = IsGADAdSizeValid(adSize)
//        if validSize {
//            // weed out invalid default ad sizes
//            let invalidAdSizeMin: GADAdSize = GADAdSizeFromCGSize(CGSize.zero)
//            let invalidAdSizeMax: GADAdSize = GADAdSizeFromCGSize(CGSize(width: 1000, height: 1000))
//            let invalidAdSizeVMax: GADAdSize = GADAdSizeFromCGSize(CGSize(width: 0, height: 1000))
//            let invalidAdSizeHMax: GADAdSize = GADAdSizeFromCGSize(CGSize(width: 1000, height: 0))
//            let invalidAdSizeVMin: GADAdSize = GADAdSizeFromCGSize(CGSize(width: 0, height: 1))
//            let invalidAdSizeHMin: GADAdSize = GADAdSizeFromCGSize(CGSize(width: 1, height: 0))
//            if GADAdSizeEqualToSize(adSize, invalidAdSizeMin) || GADAdSizeEqualToSize(adSize, invalidAdSizeMax) || GADAdSizeEqualToSize(adSize, invalidAdSizeVMax) || GADAdSizeEqualToSize(adSize, invalidAdSizeHMax) || GADAdSizeEqualToSize(adSize, invalidAdSizeVMin) || GADAdSizeEqualToSize(adSize, invalidAdSizeHMin) {
//                validSize = false
//            }
//        }
//        return validSize
//    }
//    
//    // MARK: pause / refresh
//    public func pauseRefresh() {
//        paused = true
//    }
//    
//    public func resumeRefresh() {
//        paused = false
//        fsTimer!.fire()
//    }
//    
//    //TODO: fsReload
//    func fsReload() {
//        var skipReload = false
//        if Thread.isMainThread {
//            // only allow reload if view is in window
//            if superview == nil {
//                skipReload = true
//            }
//        } else {
//            weak var weakSelf = self
//            DispatchQueue.main.sync(execute: {
//                let strongSelf = weakSelf
//                if strongSelf?.superview == nil {
//                    skipReload = true
//                }
//            })
//        }
//        
//        if skipReload || paused {
//            return
//        }
//        
//        // only allow reload if loadRequest was called
//        if let _ = self.adUnitID, let request = fsRequest  {
//            DispatchQueue.main.async(execute: {
//                self.load(request)
//            })
//        }
//    }
//    
//    // MARK: GADBannerViewDelegate
//    public func adViewDidReceiveAd(_ bannerView: GADBannerView) {
//        guard let _ = fsEventHandler else { return }
//        fsEventHandler!(#function, [String.eventBannerViewKey : bannerView])
//    }
//    
//    public func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
//        guard let _ = fsEventHandler else { return }
//        fsEventHandler!(#function, [String.eventBannerViewKey : bannerView, String.eventErrorKey : error])
//    }
//    
//    public func adViewWillPresentScreen(_ bannerView: GADBannerView) {
//        guard let _ = fsEventHandler else { return }
//        fsEventHandler!(#function, [String.eventBannerViewKey : bannerView])
//    }
//    
//    public func adViewWillDismissScreen(_ bannerView: GADBannerView) {
//        guard let _ = fsEventHandler else { return }
//        fsEventHandler!(#function, [String.eventBannerViewKey : bannerView])
//    }
//    
//    public func adViewDidDismissScreen(_ bannerView: GADBannerView) {
//        guard let _ = fsEventHandler else { return }
//        fsEventHandler!(#function, [String.eventBannerViewKey : bannerView])
//    }
//    
//    public func adViewWillLeaveApplication(_ bannerView: GADBannerView) {
//        guard let _ = fsEventHandler else { return }
//        fsEventHandler!(#function, [String.eventBannerViewKey : bannerView])
//    }
//    
//    // MARK: stored properties
//    fileprivate var deinitObserver:DeinitializationObserver {
//        get {
//            let tmpAddress = String(format: "%p", unsafeBitCast(self, to: Int.self))
//            return DFPNOctagonBannerView._deinitObserver[tmpAddress]!
//        }
//        
//        set(newValue) {
//            let tmpAddress = String(format: "%p", unsafeBitCast(self, to: Int.self))
//            DFPNOctagonBannerView._deinitObserver[tmpAddress] = newValue
//        }
//    }
//    
//    var fsManaged:Bool {
//        get {
//            let tmpAddress = String(format: "%p", unsafeBitCast(self, to: Int.self))
//            return DFPNOctagonBannerView._fsManaged[tmpAddress]!
//        }
//        
//        set(newValue) {
//            let tmpAddress = String(format: "%p", unsafeBitCast(self, to: Int.self))
//            DFPNOctagonBannerView._fsManaged[tmpAddress] = newValue
//        }
//    }
//    
//    public var fsRefreshRate:TimeInterval {
//        get {
//            let tmpAddress = String(format: "%p", unsafeBitCast(self, to: Int.self))
//            if let refreshRate: TimeInterval = DFPNOctagonBannerView._fsRefreshRate[tmpAddress] {
//                return refreshRate
//            } else {
//                // unset so return default
//                return DFPNOctagonBannerView.kDefaultRefreshRate
//            }
//        }
//        
//        set(newValue) {
//            guard newValue > TimeInterval.bannerRefreshIntervalMax, newValue < TimeInterval.bannerRefreshIntervalMin else {
//                // validation
//                return
//            }
//            
//            fsTimer!.invalidate()
//            fsTimer = FSWeakGCDTimer.scheduledTimer(withTimeInterval: newValue,
//                                                    target: self,
//                                                    selector: #selector(self.fsReload),
//                                                    userInfo: nil,
//                                                    repeats: true,
//                                                    dispatchQueue: DFPNOctagonBannerView.fsQueue)
//            
//            let tmpAddress = String(format: "%p", unsafeBitCast(self, to: Int.self))
//            DFPNOctagonBannerView._fsRefreshRate[tmpAddress] = newValue
//        }
//    }
//    
//    public var fsIdentifier:String? {
//        get {
//            let tmpAddress = String(format: "%p", unsafeBitCast(self, to: Int.self))
//            return DFPNOctagonBannerView._fsIdentifier[tmpAddress]!
//        }
//        
//        set(newValue) {
//            let tmpAddress = String(format: "%p", unsafeBitCast(self, to: Int.self))
//            DFPNOctagonBannerView._fsIdentifier[tmpAddress] = newValue
//        }
//    }
//    
//    var fsTimer:FSWeakGCDTimer? {
//        get {
//            let tmpAddress = String(format: "%p", unsafeBitCast(self, to: Int.self))
//            return DFPNOctagonBannerView._fsTimer[tmpAddress]!
//        }
//        
//        set(newValue) {
//            let tmpAddress = String(format: "%p", unsafeBitCast(self, to: Int.self))
//            DFPNOctagonBannerView._fsTimer[tmpAddress] = newValue
//        }
//    }
//    
//    var fsEventHandler:FSAdEventHandler? {
//        get {
//            let tmpAddress = String(format: "%p", unsafeBitCast(self, to: Int.self))
//            return DFPNOctagonBannerView._fsEventHandler[tmpAddress]!
//        }
//        
//        set(newValue) {
//            let tmpAddress = String(format: "%p", unsafeBitCast(self, to: Int.self))
//            DFPNOctagonBannerView._fsEventHandler[tmpAddress] = newValue
//        }
//    }
//    
//    var fsRequest:GADRequest? {
//        get {
//            let tmpAddress = String(format: "%p", unsafeBitCast(self, to: Int.self))
//            return DFPNOctagonBannerView._fsRequest[tmpAddress]!
//        }
//        
//        set(newValue) {
//            let tmpAddress = String(format: "%p", unsafeBitCast(self, to: Int.self))
//            DFPNOctagonBannerView._fsRequest[tmpAddress] = newValue
//        }
//    }
//    
//    public var paused:Bool {
//        @objc(isPaused)
//        get {
//            let tmpAddress = String(format: "%p", unsafeBitCast(self, to: Int.self))
//            return DFPNOctagonBannerView._paused[tmpAddress]!
//        }
//        
//        set(newValue) {
//            let tmpAddress = String(format: "%p", unsafeBitCast(self, to: Int.self))
//            DFPNOctagonBannerView._paused[tmpAddress] = newValue
//        }
//    }
//    
//    public weak var registrationDelegate:FSRegistrationDelegate? {
//        get {
//            let tmpAddress = String(format: "%p", unsafeBitCast(self, to: Int.self))
//            return DFPNOctagonBannerView._registrationDelegate[tmpAddress]!
//        }
//        
//        set(newValue) {
//            let tmpAddress = String(format: "%p", unsafeBitCast(self, to: Int.self))
//            DFPNOctagonBannerView._registrationDelegate[tmpAddress] = newValue
//        }
//    }
//    
//    public func fsAdSize() -> CGSize {
//        return adSize.size
//    }
//}
