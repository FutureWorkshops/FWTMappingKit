#
# Be sure to run `pod lib lint FWTMappingKit.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "FWTMappingKit"
  s.version          = "0.1.0"
  s.summary          = "A short description of FWTMappingKit."
  s.description      = <<-DESC
                       An optional longer description of FWTMappingKit

                       * Markdown format.
                       * Don't worry about the indent, we strip it!
                       DESC
  s.homepage         = "https://github.com/<GITHUB_USERNAME>/FWTMappingKit"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "Jonathan Flintham" => "jonathan@futureworkshops.com" }
  s.source           = { :git => "https://github.com/<GITHUB_USERNAME>/FWTMappingKit.git", :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.default_subspecs = 'Core'

  ### Subspecs
  
  s.subspec 'Core' do |cs|
    cs.source_files = 'Pod/CoreClasses'
    cs.header_dir   = 'Pod/CoreClasses'
    
    cs.dependency     'RestKit', '~> 0.23.x'
  end
  
  s.subspec 'Testing' do |ts|
    ts.header_dir   = 'Pod/TestClasses'
    ts.source_files = 'Pod/TestClasses'
    
    ts.frameworks   = 'XCTest'
    ts.dependency     'FWTMappingKit/Core'
  end

end
