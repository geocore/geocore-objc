Pod::Spec.new do |s|
  s.name             = "ObjectiveGeocore"
  s.version          = "0.3.5"
  s.summary          = "Geocore Objective-C Client API"
  s.description      = <<-DESC
                       Objective-C client library for accessing Geocore API server.

                       * Currently under development.
                       DESC
  s.homepage         = "https://github.com/geocore/geocore-objc"
  s.license          = "Apache License, Version 2.0"
  s.author           = { "Mamad Purbo" => "purbo@mapmotion.jp" }
  s.source           = { :git => "https://github.com/geocore/geocore-objc.git", :tag => s.version.to_s }
  s.platform         = :ios
  s.ios.deployment_target = '7.0'
  s.source_files     = 'Classes'
  s.requires_arc     = true
  s.dependency 'PromiseKit/Promise', '~> 1.5'
  s.dependency 'PromiseKit/When', '~> 1.5'
  s.dependency 'AFNetworking'
end
