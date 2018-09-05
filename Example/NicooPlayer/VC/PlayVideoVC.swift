//
//  PlayVideoVC.swift
//  NicooPlayer_Example
//
//  Created by 小星星 on 2018/6/19.
//  Copyright © 2018年 CocoaPods. All rights reserved.
//

import UIKit
import NicooPlayer

let kScreenWidth = UIScreen.main.bounds.width
let kScreenHeight = UIScreen.main.bounds.height

class PlayVideoVC: UIViewController {
    
    
    /// 这里重写系统方法，为了让 StatusBar 跟随播放器的操作栏一起 隐藏或显示，且在全屏播放时， StatusBar 样式变为 lightContent
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if isLightContentStatusBarInFullScreen {
            if playerView.superview != nil {
                if !playerView.isFullScreen! {  // 播放器添加，全屏（这里因为横竖屏切换时，先调用这个属性，再走横竖屏的方法，所以在走这里的时候，isFullScreen还没有附上值，所以取反）
                    return .lightContent
                } else {
                    return .default
                }
            } else {  // 播放器没有添加，返回默认
                return .default
            }
        } else {
            return .default
        }
    }
    /// 全屏播放时，让状态栏变为 lightContent
    /// 1.如果整个项目的状态栏已经为 lightContent，则不需要这些操作，直接播放就好。
    /// 2.如果整个项目状态栏为default，则需要在添加播放器的页面加上一个bool判断， 再重写preferredStatusBarStyle属性,将状态栏样式与播放器的横竖屏关联，plist文件中添加: Status bar is initially hidden = YES
    var isLightContentStatusBarInFullScreen: Bool = false
    
    
    
    
    
    private lazy var playOrPauseBtn: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("重置播放器", for: .normal)
        button.backgroundColor = UIColor.gray
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.addTarget(self, action: #selector(PlayVideoVC.btnclick(_:)), for: .touchUpInside)
        return button
    }()
    private lazy var playOrPauseBtn1: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("改变父视图", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.backgroundColor = UIColor.gray
        button.addTarget(self, action: #selector(PlayVideoVC.btnclick1(_:)), for: .touchUpInside)
        return button
    }()
    private lazy var getInfoBtn: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("获取进度", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.backgroundColor = UIColor.gray
        button.addTarget(self, action: #selector(PlayVideoVC.btnclick2(_:)), for: .touchUpInside)
        return button
    }()
    private lazy var fateherView: UIView = {
        let view = UIView()
        view.frame = CGRect(x:0, y: 100, width: kScreenWidth, height: kScreenWidth*9/16)
        view.backgroundColor = UIColor.gray
        return view
    }()
    private lazy var fateherView1: UIView = {
        let view = UIView()
        view.frame = CGRect(x:10, y: 120 + kScreenWidth * 9/16, width: (kScreenWidth - 20), height: (kScreenWidth - 20)*9/16)
        view.backgroundColor = UIColor.darkGray
        return view
    }()
    
    private lazy var playerView: NicooPlayerView = {
        let player = NicooPlayerView(frame: self.fateherView.bounds, bottomBarBothSide: true)
        player.delegate = self
        return player
    }()
    
    
    deinit {
        print("视图控制器被释放了11")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(fateherView)
        view.addSubview(fateherView1)
        view.addSubview(playOrPauseBtn)
        view.addSubview(playOrPauseBtn1)
        view.addSubview(getInfoBtn)
        view.backgroundColor = UIColor.white
        layoutAllSubviews()
    }
    
    @objc func btnclick(_ sender: UIButton) {
        //  初始化播放器
        let url = URL(string: "http://img.ytsg.cn/video/2/6/1531478862326.mp4")
        playerView.playVideo(url, "这里传递视屏名称", fateherView)
        isLightContentStatusBarInFullScreen = true
        // 初始化播放器，并从某个时间点开始播放
        // playerView.replayVideo("https://dn-mykplus.qbox.me/3.mp4", "视屏名称", fateherView, 180.0)
        
    }
    
    @objc func btnclick1(_ sender: UIButton) {
        
        playerView.changeVideoContainerView(fateherView1) // 改变父视图
        
        //playerView.playerStatu = TZPlayerView.PlayerStatus.Pause  // 检测到网络变化时调用
        
        
    }
    
    /// 获取播放时间，加载时间，视频总时长
    ///
    /// - Parameter sender:
    @objc func btnclick2(_ sender: UIButton) {
        // 获取加载进度
        let poloading  =  playerView.getLoadingPositionTime()
        
        // 获取播放时间和视频总时长   返回数组， 数组第一个元素为： 播放时间    第二个元素为： 视频总时长
        let playTime =  playerView.getNowPlayPositionTimeAndVideoDuration()
        
        print("已加载时间 = \(poloading) .播放时间 = \(playTime[0]) . 视频总时长= \(playTime[1])")
        sender.setTitle(String(format: "%.2f s", playTime[0]), for: .normal)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        // 如果当前播放器已经添加，支持横竖屏
        if fateherView.subviews.contains(playerView) {
            orientationSupport = OrientationSupport.orientationAll
            isLightContentStatusBarInFullScreen = true
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        /// 离开视频播放页面，只支持竖屏
        playerView.playerStatu = PlayerStatus.Pause
        orientationSupport = OrientationSupport.orientationPortrait
        isLightContentStatusBarInFullScreen = false
    }
   
}

// MARK: - NicooPlayerDelegate

extension PlayVideoVC: NicooPlayerDelegate {
    
    func retryToPlayVideo(_ videoModel: NicooVideoModel?, _ fatherView: UIView?) {
        print("网络不可用时调用")
        let url = URL(string: videoModel?.videoUrl ?? "")
        if  let sinceTime = videoModel?.videoPlaySinceTime, sinceTime > 0 {
            isLightContentStatusBarInFullScreen = true
            playerView.replayVideo(url, videoModel?.videoName, fatherView, sinceTime)
        }else {
            isLightContentStatusBarInFullScreen = true
            playerView.playVideo(url, videoModel?.videoName, fatherView)
        }
    }
    
}

// MARK: - Layout
extension PlayVideoVC {
    
    private func layoutAllSubviews() {
        fateherView.snp.makeConstraints { (make) in
            make.leading.equalTo(0)
            make.trailing.equalTo(0)
            make.top.equalTo(160)
            make.height.equalTo(kScreenWidth * 9/16)
        }
        fateherView1.snp.makeConstraints { (make) in
            make.leading.equalTo(10)
            make.trailing.equalTo(-10)
            make.top.equalTo(180 + kScreenWidth*9/16)
            make.height.equalTo((kScreenWidth - 20) * 9/16)
        }
        playOrPauseBtn.snp.makeConstraints { (make) in
            make.top.equalTo(self.view.snp.top).offset(120)
            make.centerX.equalToSuperview().offset(-60)
            make.width.equalTo(90)
            make.height.equalTo(30)
        }
        playOrPauseBtn1.snp.makeConstraints { (make) in
            make.top.equalTo(self.view.snp.top).offset(120)
            make.centerX.equalToSuperview().offset(80)
            make.width.equalTo(90)
            make.height.equalTo(30)
        }
        getInfoBtn.snp.makeConstraints { (make) in
            make.top.equalTo(self.view.snp.top).offset(70)
            make.centerX.equalToSuperview().offset(80)
            make.width.equalTo(90)
            make.height.equalTo(30)
        }
    }
}

