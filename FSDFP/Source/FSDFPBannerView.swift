//
//  FSDFPBannerView.swift
//  FSDFP
//
//  Created by Dean Chang on 9/19/19.
//  Copyright © 2019 Freestar. All rights reserved.
//

import Foundation
import GoogleMobileAds
import FSCommon
import os

@objc(FSDFPBannerView)
open class FSDFPBannerView: DFPBannerView, GADBannerViewDelegate {
    // logger
    @available(iOS 10, *)
    lazy private var logger = OSLog(FSDFPBannerView.self, category: String.loggerBannerCategory)
    
    lazy private var failsafeModeEnabled: Bool = {
        let plist = Plist<FreestarInfoBundle>()
        guard let info = plist.decode() else {
            return false
        }
        guard let freestarInfo = info.freestar else {
            return false
        }
        guard let failsafeModeEnabled = freestarInfo.failsafeModeEnabled else {
            return false
        }
        return failsafeModeEnabled
    }()
    
    
    // MARK: public properties
    @objc public private(set) var fsIdentifier:String?
    @objc public var paused: Bool = false
    @objc public weak var registrationDelegate:FSRegistrationDelegate?
    @objc public var isRegistered: Bool = false
    
    private var _fsAutoLoadEnabled: Bool = true
    @objc public var fsAutoLoadEnabled: Bool {
        @objc(isFsAutoLoadEnabled)
        get {
            return _fsAutoLoadEnabled
        }
        set {
            _fsAutoLoadEnabled = newValue
        }
    }
    
    // MARK: private properties
    private var fsTimer:FSWeakGCDTimer?
    private var fsEventHandler:FSAdEventHandler?
    private var fsRequest:GADRequest?
    private var _fsRefreshRate: TimeInterval = TimeInterval.bannerRefreshIntervalDefault
    private var applicationObserverResignActive: (Any & NSObjectProtocol)?
    private var applicationObserverBecomeActive: (Any & NSObjectProtocol)?
    
    // MARK: computed properties
    @objc public var fsAdSize: CGSize {
        get {
            return adSize.size
        }
    }
    
    @objc public private(set) var adUnitId:String? {
        get {
            return super.adUnitID
        }
        
        set(newValue) {
            super.adUnitID = newValue
        }
    }
    
    @objc public var fsRefreshRate:TimeInterval {
        get {
            return _fsRefreshRate
        }
        
        set(newValue) {
            guard newValue.validateForBanner() else {
                if #available(iOS 10, *) {
                    logger.error("Cannot reset timer due to invalid refresh rate: %@", fsRefreshRate)
                }
                return
            }
            _fsRefreshRate = newValue
            resetTimer()
        }
    }
    
    private func resetTimer() {
        guard let timer = fsTimer else {
            // bail since timer is nil
            return
        }
            
        timer.invalidate()
        fsTimer = FSWeakGCDTimer.scheduledTimer(withTimeInterval: fsRefreshRate,
                                                target: self,
                                                selector: #selector(self.fsReload),
                                                userInfo: nil,
                                                repeats: true,
                                                dispatchQueue: FSDFPBannerView.fsQueue)
    }
    
    // MARK: static dispatch queue
    static var fsQueue: DispatchQueue = {
//        var queue = DispatchQueue(label: "io.freestar.mobile.queue.dfpbanner")
        var queue = DispatchQueue.main
        return queue
    }()
    
    deinit {
        // timer cleanup
        guard let timer = fsTimer else {
            return
        }
        timer.invalidate()
        guard let applicationObserverResignActive = applicationObserverResignActive else {
            return
        }
        NotificationCenter.default.removeObserver(applicationObserverResignActive)
        guard let applicationObserverBecomeActive = applicationObserverBecomeActive else {
            return
        }
        NotificationCenter.default.removeObserver(applicationObserverBecomeActive)
    }
    
    init(_ size: GADAdSize) {
        if (size.validate()) {
            super.init(adSize: size)
            validAdSizes = [NSValueFromGADAdSize(size)]
        } else {
            // default to banner if ad size is invalid
            super.init(adSize: kGADAdSizeBanner)
        }
    }
    
    public required init?(coder aDecoder: NSCoder) {
        paused = aDecoder.decodeObject(forKey: "paused") as! Bool
        isRegistered = aDecoder.decodeObject(forKey: "isRegistered") as! Bool
        _fsRefreshRate = aDecoder.decodeObject(forKey: "fsRefreshRate") as! TimeInterval
        fsEventHandler = aDecoder.decodeObject(forKey: "fsEventHandler") as? FSAdEventHandler
        registrationDelegate = aDecoder.decodeObject(forKey: "registrationDelegate") as? FSRegistrationDelegate
        fsIdentifier = aDecoder.decodeObject(forKey: "fsIdentifier") as? String
        fsTimer = aDecoder.decodeObject(forKey: "fsTimer") as? FSWeakGCDTimer
        fsRequest = aDecoder.decodeObject(forKey: "fsRequest") as? GADRequest
        
        super.init(coder: aDecoder)
    }
    
    // MARK: convenience constructor
    @objc public convenience init(eventHandler: FSAdEventHandler?, size: GADAdSize) {
        self.init(size)
        fsEventHandler = eventHandler
        isAutoloadEnabled = false
        delegate = self
        applicationObserverResignActive = NotificationCenter.default.addObserver(forName:UIApplication.willResignActiveNotification, object: nil, queue: OperationQueue.main) {
            [weak self] _ in
            guard let self = self else { return }
            if !self.fsAutoLoadEnabled { return }
            if !self.paused {
                self.pauseRefresh()
            }
        }
        applicationObserverBecomeActive = NotificationCenter.default.addObserver(forName:UIApplication.didBecomeActiveNotification, object: nil, queue: OperationQueue.main) {
            [weak self] _ in
            guard let self = self else { return }
            if !self.fsAutoLoadEnabled { return }
            if self.paused && self.superview != nil && self.window != nil {
                self.resumeRefresh()
            }
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    public override init(adSize: GADAdSize, origin: CGPoint) {
        super.init(adSize: adSize, origin: origin)
    }
    
    // MARK: overriden methods
    @objc open override func load(_ request: GADRequest?) {
        guard let request = request else {
            return
        }
        
        Utils.shared.removeHBKeywords(request: request as? DFPRequest)
        Utils.shared.validateAndAttachKeywords(request: request as? DFPRequest, identifier: fsIdentifier)
        super.load(request)
        fsRequest = request
        if fsTimer == nil {
            // first time load
            fsTimer = FSWeakGCDTimer.scheduledTimer(withTimeInterval: fsRefreshRate,
                                                    target: self,
                                                    selector: #selector(self.fsReload),
                                                    userInfo: nil,
                                                    repeats: true,
                                                    dispatchQueue: FSDFPBannerView.fsQueue)
        } else {
            resetTimer()
        }
    }
    
    // MARK: overriden properties
    open override var adSize: GADAdSize {
        // ensure valid ad size
        set {
            if newValue.validate() {
                super.adSize = newValue
            } else {
                assertionFailure("Cannot instantiate ad object due to invalid ad size: \(NSStringFromGADAdSize(adSize))")
            }
        }
        get {
            return super.adSize
        }
    }
    
    // MARK: refresh setter
    @objc public func setFsRefreshRate(_ refreshRate: TimeInterval, sender: Any?) {
        // only set refresh rate if it hasn't been set
        guard _fsRefreshRate == TimeInterval.bannerRefreshIntervalDefault
            && refreshRate.validateForBanner() else {
                return
        }
        fsRefreshRate = refreshRate
    }
    
    private static func validate(_ refreshRate: TimeInterval) -> Bool {
        return refreshRate < TimeInterval.bannerRefreshIntervalMax && refreshRate
            > TimeInterval.bannerRefreshIntervalMin
    }
    
    // MARK: pause / refresh
    @objc public func pauseRefresh() {
        guard let _ = fsRequest else {
            // load has not yet been called since fsRequest is nil
            return
        }
        
        paused = true
    }
    
    @objc public func resumeRefresh() {
        if paused {
            paused = false
            resetTimer()
            dispatchLoadOnMain()
        }
    }
    
    // MARK: internal reload
    @objc private func fsReload() {
        if paused || superview == nil || window == nil {
            // bail if paused
            return
        }
                
        dispatchLoadOnMain()
    }
    
    private func dispatchLoadOnMain() {
        if let _ = adUnitID, let request = fsRequest  {
            DispatchQueue.main.async(execute: {
                Utils.shared.removeHBKeywords(request: request as? DFPRequest)
                Utils.shared.validateAndAttachKeywords(request: request as? DFPRequest, identifier: self.fsIdentifier)
                super.load(request)
            })
        }
    }
    
    // MARK: GADBannerViewDelegate
    public func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        self.resize(bannerView.adSize)
        guard let _ = fsEventHandler else { return }
        fsEventHandler!(#function, [String.eventBannerViewKey : bannerView])
        if #available(iOS 10, *) {
            if !failsafeModeEnabled {
//                logger.debug("Failsafe mode: %@", failsafeModeEnabled)
                return
            }
        }
        
        DispatchQueue.main.async { [weak self] in
            if self?.superview == nil || self?.window == nil {
                if #available(iOS 10, *) {
                    self?.logger.error("### %@ has no superview or is not in the window. ###", self!)
                    self?.logger.error("### This may negatively affect fill rate. ###", self!)
                    assertionFailure("### CRASHING NOW DUE TO FAILSAFE CONSTRAINT! ###")
                }
            }
        }
    }
    
    public func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        guard let _ = fsEventHandler else { return }
        fsEventHandler!(#function, [String.eventBannerViewKey : bannerView, String.eventErrorKey : error])
    }
    
    public func adViewWillPresentScreen(_ bannerView: GADBannerView) {
        guard let _ = fsEventHandler else { return }
        fsEventHandler!(#function, [String.eventBannerViewKey : bannerView])
    }
    
    public func adViewWillDismissScreen(_ bannerView: GADBannerView) {
        guard let _ = fsEventHandler else { return }
        fsEventHandler!(#function, [String.eventBannerViewKey : bannerView])
    }
    
    public func adViewDidDismissScreen(_ bannerView: GADBannerView) {
        guard let _ = fsEventHandler else { return }
        fsEventHandler!(#function, [String.eventBannerViewKey : bannerView])
    }
    
    public func adViewWillLeaveApplication(_ bannerView: GADBannerView) {
        guard let _ = fsEventHandler else { return }
        fsEventHandler!(#function, [String.eventBannerViewKey : bannerView])
    }
}

