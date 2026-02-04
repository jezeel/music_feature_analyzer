#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint music_feature_analyzer.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'music_feature_analyzer'
  s.version          = '1.0.3'
  s.summary          = 'Extract song metadata and AI music features from audio files'
  s.description      = <<-DESC
Flutter plugin to get song metadata (title, artist, album, duration, bitrate, album art, genre, etc.) and AI-powered music features from audio files. Supports Android and iOS.
                       DESC
  s.homepage         = 'https://github.com/jezeel/music_feature_analyzer'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'P M JESIL' => 'jxz101m@gmail.com' }
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
