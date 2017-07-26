#
# Be sure to run `pod lib lint ${POD_NAME}.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'Anna'
  s.version          = '0.2.0'
  s.summary          = 'Separate the analytics from your main business logic.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
Anna is an analytics abstraction library which helps separate the analyzing part of code from the main business logic. Although inspired by AOP, Anna doesn't require method-swizzling, which consumes considerable runtime. Instead, it needs a tiny piece of code to be inserted into the analyzed method. And then all the magic starts.
                       DESC

  s.homepage         = 'https://github.com/coppercash/Anna'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'William' => 'coderdreamer@gmail.com' }
  s.source           = { :git => 'https://github.com/coppercash/Anna.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'Anna/**/*.{h,m,swift}', 'Anna_iOS/Anna.h'
  s.exclude_files = 'Anna/Type.swift'
  
  # s.resource_bundles = {
  #   '${POD_NAME}' => ['${POD_NAME}/Assets/*.png']
  # }

  s.public_header_files = 'Anna/**/*.h', 'Anna_iOS/Anna.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
