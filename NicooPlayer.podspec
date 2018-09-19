

Pod::Spec.new do |s|
  s.name             = 'NicooPlayer'
  s.version          = '1.2.1'
  s.summary          = 'NicooVideoPlayer for swift4.1'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  播放器： 1. 播放本地网络视频。 2.播放已下载本地文件。 3. 全屏不可切换竖屏播放。 3. 横竖屏，锁屏，进度拖动，网络重试，状态栏跟随，操作栏暗影效果，时间样式选择。
                       DESC

  s.homepage         = 'https://github.com/yangxina/NicooPlayer'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { '504672006@qq.com' => '504672006@qq.com' }
  s.source           = { :git => 'https://github.com/yangxina/NicooPlayer.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'NicooPlayer/Classes/**/*'
  
   s.resource_bundles = {
     'NicooPlayer' => ['NicooPlayer/Assets/*.png']
   }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  s.dependency 'SnapKit'
  s.dependency 'MBProgressHUD','~> 0.9.2'
end
