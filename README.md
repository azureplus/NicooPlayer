## Requirements



1.  如果整个项目不支持横屏，播放视频时，页面需要横屏，在APPDelegate 内导入播放器头文件 , 添加方法 ：

（在实际项目中，如果有做组件化，这里应该通过路由去拿OrientationSupport 状态，如果对路由有兴趣的朋友可以到：demo地址 查看Swift路由Demo） 



另外由于播放器对系统的状态栏做了操作， 所以需要在主工程的 info.plist 文件中添加：Status bar is initially hidden == YES ， 并在有播放器的VC中重写 Status bar 样式的方法：





/// 重写系统方法，为了让 StatusBar 跟随播放器的操作栏一起 隐藏或显示，且在全屏播放时， StatusBar 样式变为 lightContent

// 播放器添加，全屏（这里因为横竖屏切换时，先调用这个属性，再走横竖屏的方法，所以在走这里的时候，isFullScreen还没有附上值，所以取反）

/// 全屏播放时，让状态栏变为 lightContent

/// 1.如果整个项目的状态栏已经为 lightContent，则不需要这些操作，直接播放就好。

/// 2.如果整个项目状态栏为default，则需要在添加播放器的页面加上一个bool判断， 再重写preferredStatusBarStyle属性,将状态栏样式与播放器的横竖屏关联，plist文件中添加: Status bar is initially hidden = YES   ，在有播放器的VC中添加： 


（具体看Demo）

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

2.点击播放按钮时，调用：

/***********************************************************************************************************/

playerView.playVideo("视频链接", "视频名称", fateherView)

/***********************************************************************************************************/

3.如果是接着上次播放的点播放，就像腾讯播放器的记录上次播放， 调用 ：

/***********************************************************************************************************/

playerView.replayVideo("视频链接", "视频名称", fateherView, 上次播放到的时间)

/***********************************************************************************************************/

4.在播放途中需要切换到另外的地方去播放 ，比如cell滑出屏幕时需要将播放器显示在一个小窗播放，可以调用：

/***********************************************************************************************************/

playerView.changeVideoContainerView ( fateherView1 )  // 传入需要的父视图。

/***********************************************************************************************************/

5.播放时，获取播放进度，存入数据库，以便下次进入时，可以直接从上次播放的时间开始播放 ： 

// 获取播放时间和视频总时长  返回数组， 数组第一个元素为： 播放时间    第二个元素为： 视频总时长

/***********************************************************************************************************/

let playTime =  playerView.getNowPlayPositionTimeAndVideoDuration()

/***********************************************************************************************************/

6.播放本地视频文件

playerView.playLocalVideoInFullscreen(self.videoUrl, videoName, self, sinceTime: sinceTime)



7.另外还要实现两个代理，具体看Demo  :  （）

let player = NicooPlayerView(frame: self.view.bounds)

player.delegate = self 

player.customMuneDelegate = self        // 这个是用于自定义右上角按钮的显示

delegate 对应的代理方法 ： 

func retryToPlayVideo(_ videoModel: NicooVideoModel?, _ fatherView: UIView?) 

此方法是在网络加载失败后点击"重试"按钮时调用。

customMuneDelegate 对应的代理方法：  func showCustomMuneView() -> UIView?

此方法是全屏播放时右上角按钮点击后调用：返回一个自定义的控件，实现操作自定义。

如果你需要自定义右上角按钮的操作控件： 设置    customMuneDelegate  ，实现方法： 

/***********************************************************************************************************/

func showCustomMuneView() -> UIView?

/***********************************************************************************************************/



如果你不需要右上角的按钮以及自定义操作控件 ： 不设置 customMuneDelegate 即可。

新增视频播放完的回调代理：

func currentVideoPlayToEnd(_ videoModel: NicooVideoModel?, _ isPlayingDownLoadFile: Bool) {

}

## Installation

NicooPlayer is available through[CocoaPods](https://cocoapods.org). To install

it, simply add the following line to your Podfile:

```ruby

pod 'NicooPlayer'

```

## Author

504672006@qq.com, yangxin@tzpt.com

## License

NicooPlayer is available under the MIT license. See the LICENSE file for more info.
