Pod::Spec.new do |s|

  s.name             = 'FSDFP'
  s.version          = '0.5.5'
  s.summary          = 'Freestar iOS Mobile Advertising SDK.'
  s.description      = "Freestar's SDK to easily display ads from over 30 demand sources. Visit freestar.io for more info."
  s.homepage         = 'https://freestar.io'
  s.author           = { 'Freestar - Dean Chang' => 'dean.chang@freestar.io' }
  s.license          = { :type => 'Freestar Limited License' }
  s.platform         = :ios, '9.0'
  s.source           = { :git => 'https://github.com/maddapper/DFP-iOS-Swift.git', :tag => s.version.to_s }
  s.swift_version    = '5.0'
  s.public_header_files = 'FSDFP/*.{h}'
  s.source_files     = 'FSDFP/Source/*.{h,m,swift}'
  s.framework        = ['UIKit', 'Foundation']
  # s.xcconfig     =  { 'FRAMEWORK_SEARCH_PATHS' => '"$(PODS_ROOT)/Google-Mobile-Ads-SDK/Frameworks/GoogleMobileAdsFramework-Current/"' }
  s.xcconfig         = {
                        :LIBRARY_SEARCH_PATHS => '$(inherited)',
                        :OTHER_CFLAGS => '$(inherited)',
                        :OTHER_LDFLAGS => '$(inherited)',
                        :HEADER_SEARCH_PATHS => '$(inherited)',
                        :FRAMEWORK_SEARCH_PATHS => '$(inherited)'
                      }

end
