Pod::Spec.new do |s|
  s.name         = "FSDFP"
  s.version      = "0.0.1"
  s.summary      = "DFP module for Freestar Ad SDK."
  s.description  = "Google Mobile Ads dependency for the Freestar Ad SDK."
  s.homepage     = "https://freestar.io"
  s.license      = "MIT"
  s.author   = { "Freestar Mobile Engineering" => "dean.chang@freestar.io" }
  s.source       = { :git => "https://github.com/freestarcapital/FSDFP.git", :tag => s.version.to_s }
  s.ios.deployment_target  = "8.0"
  s.ios.vendored_frameworks = "build/FSDFP.framework"
  s.dependency       'Google-Mobile-Ads-SDK', '7.43.0'
end
