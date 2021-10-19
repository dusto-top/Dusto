#
#  Be sure to run `pod spec lint Dusto.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |spec|

  spec.name         = "Dusto"
  spec.version      = "0.1.4"
  spec.summary      = "A wrapper to make it easy to deal with Dusto."
  spec.description  = <<-DESC
                       DustoApp is a simple utility class for dealing with Dusto.
                   DESC
  spec.homepage     = "https://github.com/dusto-top/Dusto"
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.author       = { "anonymous" => "anonymous@users.noreply.github.com" }
  spec.platform     = :ios, "7.0"
  spec.source       = { :git => "https://github.com/dusto-top/Dusto.git", :tag => "#{spec.version}" }
  spec.source_files  = "Dusto/*.{h,m}"
  spec.public_header_files = "Dusto/*.h"
  spec.frameworks = "UIKit", "Foundation"
  spec.requires_arc = true

end
