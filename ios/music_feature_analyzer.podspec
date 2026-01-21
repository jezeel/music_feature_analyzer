#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint music_feature_analyzer.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'music_feature_analyzer'
  s.version          = '1.0.1-beta-01'
  s.summary          = 'A comprehensive music feature analysis package using YAMNet AI and signal processing'
  s.description      = <<-DESC
A Flutter plugin for extracting audio metadata and features from music files.
Supports Android and iOS with automatic native code registration.
                       DESC
  s.homepage         = 'https://github.com/jezeel/music_feature_analyzer'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '12.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
  
  # Required frameworks for AVFoundation
  s.frameworks = 'AVFoundation', 'Foundation'
end
