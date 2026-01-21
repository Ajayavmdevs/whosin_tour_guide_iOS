platform :ios, '14.0'
inhibit_all_warnings!

def common_dependencies
  use_frameworks!
  
  pod 'Alamofire'
  pod 'CocoaLumberjack/Swift'
  pod 'DialCountries'
  pod 'DifferenceKit'
  pod 'Device'
  pod 'DeviceKit'
  pod 'DZNEmptyDataSet'
  pod 'ExpandableLabel'
  pod 'FAPanels'
  pod 'FloatRatingView'
  pod 'GSKStretchyHeaderView'
  pod 'IQKeyboardManagerSwift', '7.1.1'
  pod 'libPhoneNumber-iOS'
  pod 'LinearProgressBar'
  pod 'SwiftyJSON'
  pod 'MediaBrowser',"~>2.3.0"
  pod 'ObjectMapper'
  pod 'PanModal'
  pod 'PINCache'
  pod 'ReachabilitySwift'
  pod 'SkeletonView'
  pod 'SnapKit', '~> 5.0.0'
  pod 'SwiftyGif'
  pod 'Parchment'
  pod 'RealmSwift', '~> 10.7.7'
  pod 'TPKeyboardAvoiding'
  pod 'Toast-Swift'
  pod 'NotificationBannerSwift'
  pod 'MHLoadingButton'
  pod 'Hero'
  pod 'GSPlayer'
  pod 'GradientProgress'
  pod 'CountdownLabel'
  pod 'StripePaymentsUI'
  pod 'StripePaymentSheet'
  pod 'Stripe'
  pod 'CollectionViewPagingLayout'
  pod "PlayerKit"
  pod 'Socket.IO-Client-Swift'
  pod 'GrowingTextView'
  pod 'Lightbox'
  pod 'SwiftLocation/Core'
  pod 'FSCalendar'
  pod 'NVActivityIndicatorView'
  pod "StickyHeader"
  pod 'GoogleSignIn', '~>7.0.0'
  #  pod 'FBSDKLoginKit', '~>14.1.0'
  pod 'RangeSeekSlider'
  pod 'ContextMenuSwift'
  pod 'WSTagsField'
  pod 'lottie-ios'
  pod 'TTTAttributedLabel'
  pod 'DropDown'
  pod 'Amplitude'
  pod 'NISdk', '~>6.0.0'
  
end


def firebase_dependencies
  pod 'Firebase', '~> 10.0.0'
    pod 'Firebase/Messaging', '~> 10.0.0'
    pod 'Firebase/InAppMessaging', '~> 10.0.0'
    pod 'Firebase/Analytics', '~> 10.0.0'
    pod 'Firebase/Crashlytics', '~> 10.0.0'
    pod 'Firebase/Auth', '~> 10.0.0'
end


target 'Whosin' do
  common_dependencies
  firebase_dependencies
end


post_install do |installer|
  installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
          config.build_settings['LD_NO_PIE'] = 'NO'
          config.build_settings['GCC_WARN_INHIBIT_ALL_WARNINGS'] = 'YES'
          config.build_settings['SWIFT_SUPPRESS_WARNINGS'] = 'YES'
          config.build_settings['APPLICATION_EXTENSION_API_ONLY'] = 'NO'
          config.build_settings['ENABLE_BITCODE'] = 'YES'
          config.build_settings.delete 'IPHONEOS_DEPLOYMENT_TARGET'
          config.build_settings['ONLY_ACTIVE_ARCH'] = 'NO'
          config.build_settings['BUILD_LIBRARY_FOR_DISTRIBUTION'] = 'YES'
          config.build_settings['SWIFT_VERSION'] = '5.0'
      end
  end
end
