require 'json'

package = JSON.parse(File.read(File.join(__dir__, '..', 'package.json')))

Pod::Spec.new do |s|
  s.name           = 'Galeria'
  s.version        = package['version']
  s.summary        = package['description']
  s.description    = package['description']
  s.license        = package['license']
  s.author         = package['author']
  s.homepage       = package['homepage']
  s.platform       = :ios, '13.0'
  s.swift_version  = '5.4'
  s.source         = { git: 'https://github.com/nandorojo/galeria' }
  s.static_framework = true

  s.dependency 'ExpoModulesCore'
  s.dependency 'ImageViewer.swift', '~> 3.0'
  s.dependency 'ImageViewer.swift/Fetcher', '~> 3.0'
  s.dependency 'SDWebImage', '~> 5.15.8'

  # Swift/Objective-C compatibility
  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'SWIFT_COMPILATION_MODE' => 'wholemodule'
  }

  
  s.source_files = "**/*.{h,m,swift}"
end
