#
# Be sure to run `pod spec lint NotifyChangeLog.podspec' to ensure this is a
# valid spec.
#
# Remove all comments before submitting the spec. Optional attributes are commented.
#
# For details see: https://github.com/CocoaPods/CocoaPods/wiki/The-podspec-format
#
Pod::Spec.new do |s|
  s.name         = "NotifyChangeLog"
  s.version      = "0.0.1"
  s.summary      = "Notify change log in the app the first time they launch after an update. "
  s.homepage     = "https://github.com/azu/notify-changeLog"
  s.license      = 'MIT'

  s.author       = { "azu" => "azuciao@gmail.com" }
  s.source       = { :git => "https://github.com/azu/notify-changeLog.git" }
  s.platform     = :ios
  s.source_files = 'notify-changeLog/NotifyChangeLog/*.{h,m}'
end
