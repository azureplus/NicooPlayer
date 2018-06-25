//
//  NicooPlayerView.swift
//  NicooPlayer
//
//  Created by 小星星 on 2018/6/19.
//

import UIKit
import AVFoundation
import AVKit
import SnapKit
import MediaPlayer
import MBProgressHUD

public protocol NicooPlayerDelegate: class {
    /// 代理在外部处理网络问题
    func retryToPlayVideo(_ videoModel: NicooVideoModel?, _ fatherView: UIView?)
    /// 分享平台按钮点击代理
    ///
    /// - Parameter index: 分享点击的Item Index
    func playerDidSelectedItemIndex(_ index: Int)
    func screenOrientationSupportForScreenLock(_ screenLock: Bool)
}

open class NicooPlayerView: UIView {
    
    public enum PlayerStatus {
        case Failed
        case ReadyToPlay
        case Unknown
        case Buffering
        case Playing
        case Pause
    }
    /// 播放状态
    public var playerStatu: PlayerStatus? {
        didSet {
            if playerStatu == PlayerStatus.Playing {
                playControllViewEmbed.playOrPauseBtn.isSelected = true
                player?.play()
                if self.subviews.contains(pauseButton) {
                    pauseButton.removeFromSuperview()
                }
            }else if playerStatu == PlayerStatus.Pause {
                player?.pause()
                playControllViewEmbed.playOrPauseBtn.isSelected = false
                if !self.subviews.contains(pauseButton) {
                    insertSubview(pauseButton, aboveSubview: playControllViewEmbed)
                    layoutPauseButton()
                }
            }
        }
    }
    /// 滑动手势的方向
    enum PanDirection: Int {
        case PanDirectionHorizontal     //水平
        case PanDirectionVertical       //上下
    }
    var panDirection: PanDirection?     //滑动手势的方向
    var sumTime: CGFloat?               //记录拖动的值
    
    /// 进度条滑动之前的播放状态，保证滑动进度后，恢复到滑动之前的播放状态
    var beforeSliderChangePlayStatu: PlayerStatus?
    
    /// 是否是全屏
    var isFullScreen: Bool? = false {
        didSet {  // 监听全屏切换， 改变返回按钮，全屏按钮的状态和图片
            playControllViewEmbed.closeButton.isSelected = isFullScreen!
            playControllViewEmbed.fullScreenBtn.isSelected = isFullScreen!
            playControllViewEmbed.fullScreen = isFullScreen!
            if !isFullScreen! {
                if self.subviews.contains(shareMuneView) {
                    shareMuneView.removeFromSuperview()
                }
            }
        }
    }
    
    /// 是否允许全屏
    var isLandScape: Bool? = false
    
    var isDragged: Bool? = false  //是否有手势作用
    
    /// 视频截图
    private(set)  var imageGenerator: AVAssetImageGenerator?  // 用来做预览，目前没有预览的需求
    
    /// 当前屏幕状态
    var currentOrientation: UIInterfaceOrientation?
    /// 保存传入的播放时间起点
    var playTimeSince: Float = 0
    /// 当前播放进度
    var playedValue: Float = 0 {  // 播放进度
        didSet {
            if oldValue < playedValue {  // 表示在播放中
                if playControllViewEmbed.loadingView.isAnimating {
                    playControllViewEmbed.loadingView.stopAnimating()
                }
                if !playControllViewEmbed.panGesture.isEnabled && !playControllViewEmbed.screenIsLock! {
                    playControllViewEmbed.panGesture.isEnabled = true
                }
                self.hideLoadingHud()
            }
        }
    }
    /// 加载进度
    var loadedValue: Float = 0
    /// 视频总时长
    var videoDuration: Float = 0
    
    /// 父视图
    weak var fatherView: UIView?  {
        willSet {
            if newValue != nil {
                for view in (newValue?.subviews)! {
                    if view.tag != 0 {                  // 这里用于cell播放时，隐藏播放按钮
                        view.isHidden = true
                    }
                }
            }
        }
        didSet {
            if oldValue != nil && oldValue != fatherView {
                for view in (oldValue?.subviews)! {     // 当前播放器的tag为0
                    if view.tag != 0 {
                        view.isHidden = false           // 显示cell上的播放按钮
                    }
                }
            }
            if fatherView != nil && !(fatherView?.subviews.contains(self))! {
                fatherView?.addSubview(self)
            }
        }
    }
    
    /// 进入后台前的屏幕状态
    var beforeEnterBackgoundOrientation: UIInterfaceOrientation?  // 暂时没用到
    
    /// 嵌入式播放控制View
    fileprivate lazy var playControllViewEmbed: NicooPlayerControlView = {
        let playControllView = NicooPlayerControlView(frame: self.bounds, fullScreen: false)
        playControllView.delegate = self
        return playControllView
    }()
    /// 显示拖动进度的显示
    fileprivate lazy var draggedProgressView: UIView = {
        let view = UIView()
        view.backgroundColor =  UIColor(white: 0.2, alpha: 0.4)
        view.addSubview(self.draggedStatusButton)
        view.addSubview(self.draggedTimeLable)
        view.layer.cornerRadius = 3
        return view
    }()
    fileprivate lazy var draggedStatusButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(NicooImgManager.foundImage(imageName: "forward"), for: .normal)
        button.setImage(NicooImgManager.foundImage(imageName: "backward"), for: .selected)
        button.isUserInteractionEnabled = false
        return button
    }()
    fileprivate lazy var draggedTimeLable: UILabel = {
        let lable = UILabel()
        lable.textColor = UIColor.white
        lable.font = UIFont.systemFont(ofSize: 13)
        lable.textAlignment = .center
        return lable
    }()
    /// 暂停按钮
    lazy var pauseButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(NicooImgManager.foundImage(imageName: "pause"), for: .normal)
        button.backgroundColor = UIColor(white: 0.1, alpha: 0.98)
        button.layer.cornerRadius = 30
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(pauseButtonClick), for: .touchUpInside)
        return button
    }()
    /// 分享菜单
    fileprivate lazy var shareMuneView: NicooPlayerShareView = {
        let shareView = NicooPlayerShareView(frame: self.bounds)
        shareView.backgroundColor = UIColor(white: 0.1, alpha: 0.7)
        shareView.delegate = self
        return shareView
    }()
    /// 网络不好时提示
    fileprivate lazy var loadedFailedView: NicooLoadedFailedView = {
        let failedView = NicooLoadedFailedView(frame: self.bounds)
        failedView.backgroundColor = UIColor(white: 0.2, alpha: 0.5)
        return failedView
    }()
    /// 视频链接(每次对链接赋值，都会重置播放器)
    fileprivate var playUrlString: String? {
        didSet {
            if let videoUrl = playUrlString {
                resetPlayerResource(videoUrl)
            }
        }
    }
    /// 视频名称
    fileprivate var videoName: String? {
        didSet {
            if let videoTitle = self.videoName {
                playControllViewEmbed.videoNameLable.text = String(format: "%@", videoTitle)
            }
        }
    }
    public weak var delegate: NicooPlayerDelegate?
    fileprivate var playerLayer: AVPlayerLayer?
    fileprivate var player: AVPlayer?
    fileprivate var avItem: AVPlayerItem?
    fileprivate var avAsset: AVAsset?
    /// 音量显示
    fileprivate var volumeSlider: UISlider?
    /// 亮度显示
    fileprivate var brightnessSlider: NicooBrightnessView = {
        let brightView = NicooBrightnessView(frame: CGRect(x: 0, y: 0, width: 155, height: 155))
        return brightView
    }()
    
    deinit {
        print("播放器被释放了")
        NotificationCenter.default.removeObserver(self)
        self.avItem?.removeObserver(self, forKeyPath: "status")
        self.avItem?.removeObserver(self, forKeyPath: "loadedTimeRanges")
        self.avItem?.removeObserver(self, forKeyPath: "playbackBufferEmpty")
        self.avItem?.removeObserver(self, forKeyPath: "playbackLikelyToKeepUp")
    }
    public init(frame: CGRect, controlView: UIView? = nil) {
        super.init(frame: frame)
        self.backgroundColor = .black
        
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        // 注册屏幕旋转通知
        NotificationCenter.default.addObserver(self, selector: #selector(NicooPlayerView.orientChange(_:)), name: NSNotification.Name.UIDeviceOrientationDidChange, object: UIDevice.current)
        // 注册APP被挂起 + 进入前台通知
        NotificationCenter.default.addObserver(self, selector: #selector(NicooPlayerView.applicationResignActivity(_:)), name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(NicooPlayerView.applicationBecomeActivity(_:)), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 初始化播放器
    ///
    /// - Parameters:
    ///   - videoUrl: 视频链接
    ///   - videoName: 视频名称（非必传）
    ///   - containerView: 视频父视图
    open func playVideo(_ videoUrl: String?, _ videoName: String? = nil, _ containerView: UIView?) {
        // 👇三个属性的设置顺序很重要
        self.playUrlString = videoUrl   // 判断视频链接是否更改，更改了就重置播放器
        self.videoName = videoName      // 视频名称
        self.fatherView = containerView // 更换父视图时
        
        layoutAllPageSubviews()
        playerStatu = PlayerStatus.Playing // 初始状态为播放
        listenTothePlayer()
        addUserActionBlock()
        playControllViewEmbed.closeButton.snp.updateConstraints { (make) in
            make.width.equalTo(40)
        }
    }
    
    ///   从某个时间点开始播放
    ///
    /// - Parameters:
    ///   - videoUrl: 视频连接
    ///   - videoTitle: 视屏名称
    ///   - containerView: 视频父视图
    ///   - lastPlayTime: 上次播放的时间点
    open func replayVideo(_ videoUrl: String?, _ videoTitle: String? = nil, _ containerView: UIView?, _ lastPlayTime: Float) {
        self.playVideo(videoUrl, videoTitle, containerView)
        guard let avItem = self.avItem else {
            return
        }
        self.playTimeSince = lastPlayTime      // 保存播放起点，在网络断开时，点击重试，可以找到起点
        self.playerStatu = PlayerStatus.Pause
        if self.playControllViewEmbed.loadingView.isAnimating {
            self.playControllViewEmbed.loadingView.stopAnimating()
        }
        showLoadingHud()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let lastPositionValue = CMTimeMakeWithSeconds(Float64(lastPlayTime), (avItem.duration.timescale))
            self.playSinceTime(lastPositionValue)
        }
        
    }
    /// 改变播放器的父视图
    ///
    /// - Parameter containerView: New fatherView
    open func changeVideoContainerView(_ containerView: UIView) {
        fatherView = containerView
        layoutAllPageSubviews()        //改变了父视图，需要重新布局
        playControllViewEmbed.closeButton.snp.updateConstraints { (make) in
            make.width.equalTo(0)
        }
    }
    /// 获取当前播放时间点 + 视频总时长
    ///
    /// - Returns: 返回当前视频播放的时间,和视频总时长 （单位: 秒）
    open func getNowPlayPositionTimeAndVideoDuration() -> [Float] {
        return [self.playedValue, self.videoDuration]
    }
    /// 获取当前已缓存的时间点
    ///
    /// - Returns: 返回当前已缓存的时间 （单位: 秒）
    open func getLoadingPositionTime() -> Float {
        return self.loadedValue
    }
    fileprivate func showLoadingHud() {
        let hud = MBProgressHUD.showAdded(to: self, animated: false)
        hud?.labelText = "正在加载..."
        hud?.labelFont = UIFont.systemFont(ofSize: 15)
        hud?.opacity = 0.0
    }
    
    fileprivate func hideLoadingHud() {
        MBProgressHUD.hideAllHUDs(for: self, animated: false)
    }
    
    /// 初始化播放源
    ///
    /// - Parameter videoUrl: 视频链接
    fileprivate func setUpPlayerResource(_ videoUrl: String) {
        let url = URL(string: videoUrl)
        avAsset = AVAsset(url: url!)
        avItem = AVPlayerItem(asset: self.avAsset!)
        player = AVPlayer(playerItem: self.avItem!)
        playerLayer = AVPlayerLayer(player: self.player!)
        self.layer.addSublayer(playerLayer!)
        self.addSubview(playControllViewEmbed)
        playControllViewEmbed.timeSlider.value = 0
        playControllViewEmbed.loadedProgressView.setProgress(0, animated: false)
        NSObject.cancelPreviousPerformRequests(withTarget: playControllViewEmbed, selector: #selector(NicooPlayerControlView.autoHideTopBottomBar), object: nil)
        playControllViewEmbed.perform(#selector(NicooPlayerControlView.autoHideTopBottomBar), with: nil, afterDelay: 5)
        showLoadingHud()
    }
    
    /// 重置播放器
    ///
    /// - Parameter videoUrl: 视频链接
    fileprivate func resetPlayerResource(_ videoUrl: String) {
        self.avAsset = nil
        self.avItem = nil
        self.player?.replaceCurrentItem(with: nil)
        self.player = nil
        self.playerLayer?.removeFromSuperlayer()
        self.layer.removeAllAnimations()
        startReadyToPlay()
        setUpPlayerResource(videoUrl)
    }
    
    /// 销毁播放器
    fileprivate func destructPlayerResource() {
        self.avAsset = nil
        self.avItem = nil
        self.player?.replaceCurrentItem(with: nil)
        self.player = nil
        self.playerLayer?.removeFromSuperlayer()
        if let superView = self.fatherView {
            for view in superView.subviews {
                if view.tag != 0 {
                    view.isHidden = false
                }
            }
        }
        self.removeFromSuperview()
        self.layer.removeAllAnimations()
    }
    /// 从某个点开始播放
    ///
    /// - Parameter time: 要从开始的播放起点
    fileprivate func playSinceTime(_ time: CMTime) {
        if CMTIME_IS_VALID(time) {
            avItem?.seek(to: time, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero, completionHandler: { [weak self] (finish) in
                if finish {
                    self?.playerStatu = PlayerStatus.Playing
                    self?.hideLoadingHud()
                }
            })
            return
        }else {
            self.hideLoadingHud()
            //  这里讲网络加载失败的情况代理出去，在外部处理
            //delegate?.playerLoadedVideoUrlFailed()
            showLoadedFailedView()
        }
    }
    /// 获取系统音量
    fileprivate func configureSystemVolume() {
        let volumeView = MPVolumeView()
        self.volumeSlider = nil                 //每次获取要将之前的置为nil
        for view in volumeView.subviews {
            if view.classForCoder.description() == "MPVolumeSlider" {
                if let vSlider = view as? UISlider {
                    self.volumeSlider = vSlider
                }
                break
            }
        }
    }
    
    // MARK: - PlayerPlayendNotifacation
    fileprivate func addNotificationAndObserver() {
        guard let avItem = self.avItem else {return}
        NotificationCenter.default.addObserver(self, selector: #selector(playToEnd(_:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        avItem.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions.new, context: nil)
        avItem.addObserver(self, forKeyPath: "loadedTimeRanges", options: NSKeyValueObservingOptions.new, context: nil)
        avItem.addObserver(self, forKeyPath: "playbackBufferEmpty", options: NSKeyValueObservingOptions.new, context: nil)
        avItem.addObserver(self, forKeyPath: "playbackLikelyToKeepUp", options: NSKeyValueObservingOptions.new, context: nil)
    }
    
    // MARK: - 返回，关闭，全屏，播放，暂停,重播,音量，亮度，进度拖动 - UserAction
    @objc func pauseButtonClick() {
        self.playerStatu = PlayerStatus.Playing
    }
    private func addUserActionBlock() {
        // 返回，关闭
        playControllViewEmbed.closeButtonClickBlock = { [weak self] (sender) in
            guard let strongSelf = self else {
                return
            }
            if strongSelf.isFullScreen! {                                    // 如果全屏，关闭按钮 关闭全屏
                strongSelf.interfaceOrientation(UIInterfaceOrientation.portrait)
            }else {                                                    // 非全屏状态，停止播放，移除播放视图
                print("非全屏状态，停止播放，移除播放视图")
                strongSelf.destructPlayerResource()
            }
        }
        // 全屏
        playControllViewEmbed.fullScreenButtonClickBlock = { [weak self] (sender) in
            guard let strongSelf = self else {
                return
            }
            if strongSelf.isFullScreen! {
                strongSelf.interfaceOrientation(UIInterfaceOrientation.portrait)
            }else{
                strongSelf.interfaceOrientation(UIInterfaceOrientation.landscapeRight)
            }
        }
        // 播放暂停
        playControllViewEmbed.playOrPauseButtonClickBlock = { [weak self] (sender) in
            if self?.playerStatu == PlayerStatus.Playing {
                self?.playerStatu = PlayerStatus.Pause
            }else if self?.playerStatu == PlayerStatus.Pause {
                self?.playerStatu = PlayerStatus.Playing
            }
        }
        playControllViewEmbed.screenLockButtonClickBlock = { [weak self] (sender) in
            print("锁屏")
            self?.delegate?.screenOrientationSupportForScreenLock(sender.isSelected)
        }
        // 重播
        playControllViewEmbed.replayButtonClickBlock = { [weak self] (_) in
            self?.avItem?.seek(to: kCMTimeZero)
            self?.startReadyToPlay()
            self?.playerStatu = PlayerStatus.Playing
        }
        // 分享按钮点击
        playControllViewEmbed.muneButtonClickBlock = { [weak self] (_) in
            guard let strongSelf = self else {
                return
            }
            if !strongSelf.subviews.contains(strongSelf.shareMuneView) {
                strongSelf.addSubview(strongSelf.shareMuneView)
            }
            strongSelf.shareMuneView.snp.makeConstraints({ (make) in
                make.edges.equalToSuperview()
            })
        }
        // 音量，亮度，进度拖动
        self.configureSystemVolume()             // 获取系统音量控件   可以选择自定义，效果会比系统的好
        
        playControllViewEmbed.pangeustureAction = { [weak self] (sender) in
            guard let avItem = self?.avItem  else {return}                     // 如果 avItem 不存在，手势无响应
            guard let strongSelf = self else {return}
            let locationPoint = sender.location(in: strongSelf.playControllViewEmbed)
            /// 根据上次和本次移动的位置，算出一个速率的point
            let veloctyPoint = sender.velocity(in: strongSelf.playControllViewEmbed)
            switch sender.state {
            case .began:
                
                NSObject.cancelPreviousPerformRequests(withTarget: strongSelf.playControllViewEmbed, selector: #selector(NicooPlayerControlView.autoHideTopBottomBar), object: nil)    // 取消5秒自动消失控制栏
                strongSelf.playControllViewEmbed.barIsHidden = false
                
                // 使用绝对值来判断移动的方向
                let x = fabs(veloctyPoint.x)
                let y = fabs(veloctyPoint.y)
                
                if x > y {                       //水平滑动
                    strongSelf.panDirection = PanDirection.PanDirectionHorizontal
                    strongSelf.beforeSliderChangePlayStatu = strongSelf.playerStatu  // 拖动开始时，记录下拖动前的状态
                    strongSelf.playerStatu = PlayerStatus.Pause                // 拖动开始，暂停播放
                    strongSelf.pauseButton.isHidden = true                     // 拖动时隐藏暂停按钮
                    strongSelf.sumTime = CGFloat(avItem.currentTime().value)/CGFloat(avItem.currentTime().timescale)
                    if !strongSelf.subviews.contains(strongSelf.draggedProgressView) {
                        strongSelf.addSubview(strongSelf.draggedProgressView)
                        strongSelf.layoutDraggedContainers()
                    }
                    
                }else if x < y {
                    strongSelf.panDirection = PanDirection.PanDirectionVertical
                    if locationPoint.x > strongSelf.playControllViewEmbed.bounds.size.width/2 && locationPoint.y < strongSelf.playControllViewEmbed.bounds.size.height - 40 {  // 触摸点在视图右边，控制音量
                        // 如果需要自定义 音量控制显示，在这里添加自定义VIEW
                        
                    }else if locationPoint.x < strongSelf.playControllViewEmbed.bounds.size.width/2 && locationPoint.y < strongSelf.playControllViewEmbed.bounds.size.height - 40 {
                        if !strongSelf.subviews.contains(strongSelf.brightnessSlider) {
                            strongSelf.addSubview(strongSelf.brightnessSlider)
                            strongSelf.brightnessSlider.snp.makeConstraints({ (make) in
                                make.center.equalToSuperview()
                                make.width.equalTo(155)
                                make.height.equalTo(155)
                            })
                        }
                    }
                }
                break
            case .changed:
                switch strongSelf.panDirection! {
                case .PanDirectionHorizontal:
                    let durationValue = CGFloat(avItem.duration.value)/CGFloat(avItem.duration.timescale)
                    let draggedValue = strongSelf.horizontalMoved(veloctyPoint.x)
                    let positionValue = CMTimeMakeWithSeconds(Float64(durationValue) * Float64(draggedValue), (avItem.duration.timescale))
                    avItem.seek(to: positionValue, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero)
                    break
                case .PanDirectionVertical:
                    if locationPoint.x > strongSelf.playControllViewEmbed.bounds.size.width/2 && locationPoint.y < strongSelf.playControllViewEmbed.bounds.size.height - 40 {
                        strongSelf.veloctyMoved(veloctyPoint.y, true)
                    }else if locationPoint.x < strongSelf.playControllViewEmbed.bounds.size.width/2 && locationPoint.y < strongSelf.playControllViewEmbed.bounds.size.height - 40 {
                        strongSelf.veloctyMoved(veloctyPoint.y, false)
                    }
                    break
                }
                break
            case .ended:
                switch strongSelf.panDirection! {
                case .PanDirectionHorizontal:
                    let position = CGFloat(avItem.duration.value)/CGFloat(avItem.duration.timescale)
                    let sliderValue = strongSelf.sumTime!/position
                    if !strongSelf.playControllViewEmbed.loadingView.isAnimating {
                        strongSelf.playControllViewEmbed.loadingView.startAnimating()
                    }
                    let po = CMTimeMakeWithSeconds(Float64(position) * Float64(sliderValue), (avItem.duration.timescale))
                    avItem.seek(to: po, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero)
                    /// 拖动完成，sumTime置为0 回到之前的播放状态，如果播放状态为
                    strongSelf.sumTime = 0
                    strongSelf.pauseButton.isHidden = false
                    strongSelf.playerStatu = strongSelf.beforeSliderChangePlayStatu!
                    
                    //进度拖拽完成，5庙后自动隐藏操作栏
                    strongSelf.playControllViewEmbed.perform(#selector(NicooPlayerControlView.autoHideTopBottomBar), with: nil, afterDelay: 5)
                    
                    if strongSelf.subviews.contains(strongSelf.draggedProgressView) {
                        strongSelf.draggedProgressView.removeFromSuperview()
                    }
                    break
                case .PanDirectionVertical:
                    //进度拖拽完成，5庙后自动隐藏操作栏
                    strongSelf.playControllViewEmbed.perform(#selector(NicooPlayerControlView.autoHideTopBottomBar), with: nil, afterDelay: 5)
                    if locationPoint.x < strongSelf.playControllViewEmbed.bounds.size.width/2 {    // 触摸点在视图左边 隐藏屏幕亮度
                        strongSelf.brightnessSlider.removeFromSuperview()
                    }
                    break
                }
                break
                
            case .possible:
                break
            case .failed:
                break
            case .cancelled:
                break
            }
        }
    }
    // MARK: - 水平拖动进度手势
    fileprivate func horizontalMoved(_ moveValue: CGFloat) ->CGFloat {
        guard var sumValue = self.sumTime else {
            return 0
        }
        // 限定sumTime的范围
        guard let avItem = self.avItem else {
            return 0
        }
        // 这里可以调整拖动灵敏度， 数字（99）越大，灵敏度越低
        sumValue += moveValue / 99
        
        let totalMoveDuration = CGFloat(avItem.duration.value)/CGFloat(avItem.duration.timescale)
        
        if sumValue > totalMoveDuration {
            sumValue = totalMoveDuration
        }
        if sumValue < 0 {
            sumValue = 0
        }
        let dragValue = sumValue / totalMoveDuration
        // 拖动时间展示
        let allTimeString =  self.formatTimDuration(position: Int(sumValue), duration: Int(totalMoveDuration))
        let draggedTimeString = self.formatTimPosition(position: Int(sumValue), duration: Int(totalMoveDuration))
        self.draggedTimeLable.text = String(format: "%@|%@", draggedTimeString,allTimeString)
        
        self.draggedStatusButton.isSelected = moveValue < 0
        self.playControllViewEmbed.positionTimeLab.text = self.formatTimPosition(position: Int(sumValue), duration: Int(totalMoveDuration))
        self.playControllViewEmbed.timeSlider.value = Float(dragValue)
        self.sumTime = sumValue
        return dragValue
        
    }
    // MARK - 上下拖动手势
    fileprivate func veloctyMoved(_ movedValue: CGFloat, _ isVolume: Bool) {
        // isVolume ? (self.volumeSlider?.value -= movedValue / 10000) : (UIScreen.main.brightness -= movedValue / 10000)
        if isVolume {
            self.volumeSlider?.value  -= Float(movedValue/10000)
        }else {
            UIScreen.main.brightness  -= movedValue/10000
            self.brightnessSlider.updateBrightness(UIScreen.main.brightness)
        }
    }
    
    /// 播放结束时调用
    ///
    /// - Parameter sender: 监听播放结束
    @objc func playToEnd(_ sender: Notification) {
        self.playerStatu = PlayerStatus.Pause //同时为暂停状态
        self.pauseButton.isHidden = true
        playControllViewEmbed.replayContainerView.isHidden = false
        playControllViewEmbed.barIsHidden = true
        playControllViewEmbed.topControlBarView.isHidden = false //单独显示顶部操作栏
        playControllViewEmbed.singleTapGesture.isEnabled = false
        playControllViewEmbed.doubleTapGesture.isEnabled = false
        playControllViewEmbed.panGesture.isEnabled = false
        playControllViewEmbed.timeSlider.value = 0
        playControllViewEmbed.loadedProgressView.setProgress(0, animated: false)
        playControllViewEmbed.loadingView.stopAnimating()
    }
    // MARK: - 开始播放准备
    fileprivate func startReadyToPlay() {
        playControllViewEmbed.barIsHidden = false
        playControllViewEmbed.replayContainerView.isHidden = true
        playControllViewEmbed.singleTapGesture.isEnabled = true
        playControllViewEmbed.doubleTapGesture.isEnabled = true
        playControllViewEmbed.panGesture.isEnabled = true
        self.loadedFailedView.removeFromSuperview()
    }
    // MARK: - 网络提示显示
    fileprivate func showLoadedFailedView() {
        self.addSubview(loadedFailedView)
        loadedFailedView.retryButtonClickBlock = { [weak self] (sender) in
            let model = NicooVideoModel(videoName: self?.videoName, videoUrl: self?.playUrlString, videoPlaySinceTime: (self?.playTimeSince)!)
            self?.delegate?.retryToPlayVideo(model, self?.fatherView)
        }
        loadedFailedView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    /// 横竖屏适配
    ///
    /// - Parameter sender: 通知
    @objc func orientChange(_ sender: Notification) {
        let orirntation = UIApplication.shared.statusBarOrientation
        if  orirntation == UIInterfaceOrientation.landscapeLeft || orirntation == UIInterfaceOrientation.landscapeRight  {
            isFullScreen = true
            self.removeFromSuperview()
            UIApplication.shared.keyWindow?.addSubview(self)
            UIView.animate(withDuration: 0.2, delay: 0, options: UIViewAnimationOptions.transitionCurlUp, animations: {
                self.snp.makeConstraints({ (make) in
                    make.edges.equalTo(UIApplication.shared.keyWindow!)
                })
                self.playControllViewEmbed.snp.makeConstraints({ (make) in
                    make.edges.equalToSuperview()
                })
                self.layoutIfNeeded()
                self.playControllViewEmbed.layoutIfNeeded()
            }, completion: nil)
        }else if orirntation == UIInterfaceOrientation.portrait {
            if !self.playControllViewEmbed.screenIsLock! {
                isFullScreen = false
                self.removeFromSuperview()
                
                if let containerView = self.fatherView {
                    containerView.addSubview(self)
                    UIView.animate(withDuration: 0.2, delay: 0, options: UIViewAnimationOptions.curveLinear, animations: {
                        self.snp.makeConstraints({ (make) in
                            make.edges.equalTo(containerView)
                        })
                        self.layoutIfNeeded()
                        self.playControllViewEmbed.layoutIfNeeded()
                    }, completion: nil)
                }
            }
            
        }
       // self.layoutIfNeeded()
    }
    
    /// 强制横屏
    ///
    /// - Parameter orientation: 通过KVC直接设置屏幕旋转方向
    private func interfaceOrientation(_ orientation: UIInterfaceOrientation) {
        if orientation == UIInterfaceOrientation.landscapeRight || orientation == UIInterfaceOrientation.landscapeLeft {
            UIDevice.current.setValue(NSNumber(integerLiteral: UIInterfaceOrientation.landscapeRight.rawValue), forKey: "orientation")
        }else if orientation == UIInterfaceOrientation.portrait {
            UIDevice.current.setValue(NSNumber(integerLiteral: UIInterfaceOrientation.portrait.rawValue), forKey: "orientation")
        }
    }
    /// APP将要被挂起
    ///
    /// - Parameter sender: 记录被挂起前的播放状态，进入前台时恢复状态
    @objc func applicationResignActivity(_ sender: NSNotification) {
        self.beforeSliderChangePlayStatu = self.playerStatu  // 记录下进入后台前的播放状态
        self.playerStatu = PlayerStatus.Pause
    }
    /// APP进入前台，恢复播放状态
    @objc func applicationBecomeActivity(_ sender: NSNotification) {
        if let oldStatu = self.beforeSliderChangePlayStatu {
            self.playerStatu = oldStatu                      // 恢复进入后台前的播放状态
        }else {
            self.playerStatu = PlayerStatus.Pause
        }
    }
    // MARK: - 布局
    private func layoutAllPageSubviews() {
        layoutSelf()
        layoutPlayControllView()
    }
    private func layoutDraggedContainers() {
        layoutDraggedProgressView()
        layoutDraggedStatusButton()
        layoutDraggedTimeLable()
    }
    private func layoutSelf() {
        self.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    private func layoutPlayControllView() {
        playControllViewEmbed.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    private func layoutDraggedProgressView() {
        draggedProgressView.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.height.equalTo(70)
            make.width.equalTo(120)
        }
    }
    private func layoutDraggedStatusButton() {
        draggedStatusButton.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(8)
            make.height.equalTo(30)
            make.width.equalTo(40)
        }
    }
    private func layoutDraggedTimeLable() {
        draggedTimeLable.snp.makeConstraints { (make) in
            make.leading.equalTo(8)
            make.trailing.equalTo(-8)
            make.bottom.equalToSuperview()
            make.top.equalTo(draggedStatusButton.snp.bottom)
        }
    }
    private func layoutPauseButton() {
        pauseButton.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.width.equalTo(60)
            make.height.equalTo(60)
        }
    }
    override open func layoutSubviews() {
        super.layoutSubviews()
        playerLayer?.frame = self.bounds
    }
}

// MARK: - TZPlayerControlViewDelegate

extension NicooPlayerView: NicooPlayerControlViewDelegate {
    func sliderTouchBegin(_ sender: UISlider) {
        beforeSliderChangePlayStatu = playerStatu
        playerStatu = PlayerStatus.Pause
        pauseButton.isHidden = true
    }
    func sliderTouchEnd(_ sender: UISlider) {
        guard let avItem = self.avItem else {
            return
        }
        let position = Float64 ((avItem.duration.value)/Int64(avItem.duration.timescale))
        let po = CMTimeMakeWithSeconds(Float64(position) * Float64(sender.value), (avItem.duration.timescale))
        avItem.seek(to: po, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero)
        pauseButton.isHidden = false
        playerStatu = beforeSliderChangePlayStatu
        if !playControllViewEmbed.loadingView.isAnimating {
            playControllViewEmbed.loadingView.startAnimating()
        }
        
    }
    func sliderValueChange(_ sender: UISlider) {
        guard let avItem = self.avItem else {
            return
        }
        let position = Float64 ((avItem.duration.value)/Int64(avItem.duration.timescale))
        let po = CMTimeMakeWithSeconds(Float64(position) * Float64(sender.value), (avItem.duration.timescale))
        avItem.seek(to: po, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero)
    }
}

// MARK: - 监听播放状态

extension NicooPlayerView {
    
    /// 监听PlayerItem对象
    fileprivate func listenTothePlayer() {
        guard let avItem = self.avItem else {return}
        player?.addPeriodicTimeObserver(forInterval: CMTimeMake(Int64(1.0), Int32(1.0)), queue: nil, using: { [weak self] (time) in
            if Int(avItem.duration.value) > 0 && Int(avItem.currentTime().value) > 0 {
                let value = Int(avItem.currentTime().value)/Int(avItem.currentTime().timescale)
                let duration = Int(avItem.duration.value)/Int(avItem.duration.timescale)
                let playValue = Float(value)/Float(duration)
                // print("timeValue = \(value) s,alltime = \(duration) s  playvalue = \(playValue)")
                if  let stringDuration = self?.formatTimDuration(position: value, duration:duration), let stringValue = self?.formatTimPosition(position: value, duration: duration) {
                    //self.playControllViewEmbed.positionTimeLab.text = stringValue
                    self?.playControllViewEmbed.timeSlider.value = playValue
                    self?.playControllViewEmbed.durationTimeLab.text = String(format: "%@/%@", stringValue, stringDuration)
                }
                self?.playedValue = Float(value)                                      // 保存播放进度
            }
        })
        addNotificationAndObserver()
    }
    /// KVO 监听播放状态
    override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let avItem = object as? AVPlayerItem else {
            return
        }
        if  keyPath == "status" {
            if avItem.status == AVPlayerItemStatus.readyToPlay {
                let duration = Float(avItem.duration.value)/Float(avItem.duration.timescale)
                let currentTime =  avItem.currentTime().value/Int64(avItem.currentTime().timescale)
                let durationHours = (Int(duration) / 3600) % 60
                if (durationHours != 0) {
                    playControllViewEmbed.durationTimeLab.snp.updateConstraints { (make) in
                        make.width.equalTo(122)
                    }
                    //                    playControllViewEmbed.positionTimeLab.snp.updateConstraints { (make) in
                    //                        make.width.equalTo(67)
                    //                    }
                }
                self.videoDuration = Float(duration)
                print("时长 = \(duration) S, 已播放 = \(currentTime) s")
            }else if avItem.status == AVPlayerItemStatus.unknown {
                //视频加载失败，或者未知原因
                // playerStatu = PlayerStatus.Unknow
                hideLoadingHud()
                
            }else if avItem.status == AVPlayerItemStatus.failed {
                print("PlayerStatus.failed")
                // 代理出去，在外部处理网络问题
                if playControllViewEmbed.loadingView.isAnimating {
                    playControllViewEmbed.loadingView.stopAnimating()
                }
                hideLoadingHud()
                showLoadedFailedView()
            }
        } else if keyPath == "loadedTimeRanges" {                             //监听缓存进度，根据时间来监听
            let timeRange = avItem.loadedTimeRanges
            let cmTimeRange = timeRange[0] as! CMTimeRange
            let startSeconds = CMTimeGetSeconds(cmTimeRange.start)
            let durationSeconds = CMTimeGetSeconds(cmTimeRange.duration)
            let timeInterval = startSeconds + durationSeconds                    // 计算总进度
            let totalDuration = CMTimeGetSeconds(avItem.duration)
            self.loadedValue = Float(timeInterval)                               // 保存缓存进度
            self.playControllViewEmbed.loadedProgressView.setProgress(Float(timeInterval/totalDuration), animated: true)
        } else if keyPath == "playbackBufferEmpty" {                     // 监听播放器正在缓冲数据
            
        } else if keyPath == "playbackLikelyToKeepUp" {                   //监听视频缓冲达到可以播放的状态
            if playControllViewEmbed.loadingView.isAnimating {
                playControllViewEmbed.loadingView.stopAnimating()
            }
        }
    }
}
// MARK: - 时间转换格式
extension NicooPlayerView {
    
    fileprivate func formatTimPosition(position: Int, duration:Int) -> String{
        guard position != 0 && duration != 0 else{
            return "00:00"
        }
        let positionHours = (position / 3600) % 60
        let positionMinutes = (position / 60) % 60
        let positionSeconds = position % 60
        let durationHours = (Int(duration) / 3600) % 60
        if (durationHours == 0) {
            return String(format: "%02d:%02d",positionMinutes,positionSeconds)
        }
        return String(format: "%02d:%02d:%02d",positionHours,positionMinutes,positionSeconds)
    }
    
    fileprivate func formatTimDuration(position: Int, duration:Int) -> String{
        guard  duration != 0 else{
            return "00:00"
        }
        let durationHours = (duration / 3600) % 60
        let durationMinutes = (duration / 60) % 60
        let durationSeconds = duration % 60
        if (durationHours == 0)  {
            return String(format: "%02d:%02d",durationMinutes,durationSeconds)
        }
        return String(format: "%02d:%02d:%02d",durationHours,durationMinutes,durationSeconds)
    }
}
extension NicooPlayerView: NicooPlayerShareDelegate {
    public func shareMuneItemSelected(_ shreType: Int) {
        delegate?.playerDidSelectedItemIndex(shreType)
    }
}
