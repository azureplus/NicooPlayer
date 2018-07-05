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
 1.  如果整个项目不支持横屏，播放视频时，页面需要横屏，在APPDelegate 内导入播放器头文件 , 添加方法 ：
/***********************************************************************************************************/
 func application(_ application: UIApplication, supportedInterfaceOrientationsFor window:  
UIWindow?)
-> UIInterfaceOrientationMask {
guard let num =  OrientationSupport(rawValue: orientationSupport.rawValue) else {
return [.portrait]
}
return num.getOrientSupports()   
}
/***********************************************************************************************************/

2. 点击播放按钮时，调用：

/***********************************************************************************************************/
playerView.playVideo("视频链接", "视频名称", fateherView)
/***********************************************************************************************************/

 3. 如果是接着上次播放的点播放，就像腾讯播放器的记录上次播放， 调用 ：
 /***********************************************************************************************************/
playerView.replayVideo("视频链接", "视频名称", fateherView, 上次播放到的时间)
/***********************************************************************************************************/

4. 在播放途中需要切换到另外的地方去播放 ，比如cell滑出屏幕时需要将播放器显示在一个小窗播放，可以调用：
/***********************************************************************************************************/
playerView.changeVideoContainerView ( fateherView1 )   // 传入需要的父视图。
/***********************************************************************************************************/

5. 播放时，获取播放进度，存入数据库，以便下次进入时，可以直接从上次播放的时间开始播放 ： 
// 获取播放时间和视频总时长   返回数组， 数组第一个元素为： 播放时间    第二个元素为： 视频总时长
/***********************************************************************************************************/
let playTime =  playerView.getNowPlayPositionTimeAndVideoDuration()
/***********************************************************************************************************/


6. 另外还要实现两个代理，具体看Demo   :  （）

let player = NicooPlayerView(frame: self.view.bounds)
player.delegate = self  
player.customMuneDelegate = self        // 这个是用于自定义右上角按钮的显示

delegate 对应的代理方法 ：  func retryToPlayVideo(_ videoModel: NicooVideoModel?, _ fatherView: UIView?) 
此方法是在网络加载失败后点击"重试"按钮时调用。

customMuneDelegate 对应的代理方法：  func showCustomMuneView() -> UIView?

此方法是全屏播放时右上角按钮点击后调用：返回一个自定义的控件，实现操作自定义。


如果你需要自定义右上角按钮的操作控件： 设置    customMuneDelegate   ，实现方法： 

/***********************************************************************************************************/
 func showCustomMuneView() -> UIView?
 /***********************************************************************************************************/
 
 如果你不需要右上角的按钮以及自定义操作控件 ： 不设置 customMuneDelegate 即可。

 



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

