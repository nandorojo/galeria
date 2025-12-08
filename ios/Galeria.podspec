require 'json'

package = JSON.parse(File.read(File.join(__dir__, '..', 'package.json')))

new_arch_enabled = ENV['RCT_NEW_ARCH_ENABLED'] == '1'
new_arch_compiler_flags = '-DRCT_NEW_ARCH_ENABLED'

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

  s.compiler_flags = new_arch_compiler_flags if new_arch_enabled

  s.dependency 'ExpoModulesCore'
  s.dependency 'SDWebImage'

  spm_dependency(s,
    url: "https://github.com/b3ll/Motion.git",
    requirement: {kind: "upToNextMinorVersion", minimumVersion: "0.1.5"},
    products: ["Motion"]
  )

  # Swift/Objective-C compatibility
  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'SWIFT_COMPILATION_MODE' => 'wholemodule',
    'OTHER_SWIFT_FLAGS' => "$(inherited) #{new_arch_enabled ? new_arch_compiler_flags : ''}"
  }

  s.source_files = "**/*.{h,m,swift}"
end
