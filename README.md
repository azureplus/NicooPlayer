# NicooPlayer

videoPlayer for swift4.1


[![CI Status](https://img.shields.io/travis/504672006@qq.com/NicooPlayer.svg?style=flat)](https://travis-ci.org/504672006@qq.com/NicooPlayer)
[![Version](https://img.shields.io/cocoapods/v/NicooPlayer.svg?style=flat)](https://cocoapods.org/pods/NicooPlayer)
[![License](https://img.shields.io/cocoapods/l/NicooPlayer.svg?style=flat)](https://cocoapods.org/pods/NicooPlayer)
[![Platform](https://img.shields.io/cocoapods/p/NicooPlayer.svg?style=flat)](https://cocoapods.org/pods/NicooPlayer)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## 怎么用
如果整个项目不支持横屏，播放视频的页面需要横屏，在APPDelegate 内添加方法 ：
func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?)
-> UIInterfaceOrientationMask {if isAllowAutorotate { return [.portrait, .landscapeLeft, .landscapeRight]}else {return .portrait}}   其中 isAllowAutorotate为整个项目的全局变量

实现此方法之后，在需要横屏的VC内的viewWillAppear 中设置为true， viewDidDisappear中设置为false.


点击播放按钮时，调用：
playerView.playVideo("视频链接", "视频名称", fateherView)

如果是接着上次播放的点播放，就像腾讯播放器的记录上次播放， 调用 ：
playerView.replayVideo("视频链接", "视频名称", fateherView, 上次播放到的时间)

在播放途中需要切换到另外的地方去播放 ，比如cell滑出屏幕时需要将播放器显示在一个小窗播放，可以调用：
playerView.changeVideoContainerView ( fateherView1 )  ，传入需要的父视图。

播放时，获取播放进度，存入数据库，以便下次进入时，可以直接从上次播放的时间开始播放 ： 
// 获取播放时间和视频总时长   返回数组， 数组第一个元素为： 播放时间    第二个元素为： 视频总时长
let playTime =  playerView.getNowPlayPositionTimeAndVideoDuration()


另外还要实现两个代理



## Installation

NicooPlayer is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'NicooPlayer'
```

## Author

504672006@qq.com, yangxin@tzpt.com

## License

NicooPlayer is available under the MIT license. See the LICENSE file for more info.

