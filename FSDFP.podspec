Pod::Spec.new do |s|

  s.name             = 'FSDFP'
  s.version          = '7.50.1'
  s.summary          = 'Freestar iOS Mobile Advertising SDK.'
  s.description      = "Freestar's SDK to easily display ads from over 30 demand sources. Visit freestar.io for more info."
  s.homepage         = 'https://freestar.io'
  s.author           = { 'Freestar - Dean Chang' => 'dean.chang@freestar.io' }
  s.license          = { :type => 'Freestar Limited License' }
  s.platform         = :ios, '9.0'
  s.source           = { :git => 'https://github.com/maddapper/DFP-iOS-Swift.git', :tag => s.version.to_s }
  s.swift_version    = '5.0'
  s.source_files     = 'FSDFP/Source/*.{h,m,swift}'
  s.framework        = ['UIKit', 'Foundation']
  s.dependency      'Google-Mobile-Ads-SDK', '7.50.0'
  s.dependency	    'PrebidMobileFS', '~> 0.6.1'
  s.dependency	    'FSCache'
  s.dependency	    'FSCommon'
  s.static_framework = true
  # s.xcconfig     =  { 'FRAMEWORK_SEARCH_PATHS' => '"$(PODS_ROOT)/Google-Mobile-Ads-SDK/Frameworks/GoogleMobileAdsFramework-Current/"' }

end
