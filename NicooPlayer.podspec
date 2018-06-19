

Pod::Spec.new do |s|
  s.name             = 'NicooPlayer'
  s.version          = '0.1.2'
  s.summary          = 'NicooVideoPlayer for swift4.1'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  创建播放器：
  playerView.playVideo("URL", "视频名称", fateherView)
  从某个时间点开始比方（用于播放上次播放记录）
  playerView.replayVideo(videoModel?.videoUrl, videoModel?.videoName, fatherView, sinceTime)
  改变播放器父视图:
  playerView.changeVideoContainerView(fateherView1)
  获取播放进度：
  playerView.getNowPlayPositionTimeAndVideoDuration()
  缓存进度：
  playerView.getLoadingPositionTime()
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
  s.dependency  'SnapKit', '~> 4.0.0'
  s.dependency 'MBProgressHUD','~> 0.9.2'
end
