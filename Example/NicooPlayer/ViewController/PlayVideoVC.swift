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
        let orirntation = UIApplication.shared.statusBarOrientation
        if  orirntation == UIInterfaceOrientation.landscapeLeft || orirntation == UIInterfaceOrientation.landscapeRight {
            return .lightContent
        }
        return .default
    }
    /// 全屏播放时，让状态栏变为 lightContent
    /// 1.如果整个项目的状态栏已经为 lightContent，则不需要这些操作，直接播放就好。
    /// 2.如果整个项目状态栏为default，则需要在添加播放器的页面加上一个bool判断， 再重写preferredStatusBarStyle属性,将状态栏样式与播放器的横竖屏关联，plist文件中添加: Status bar is initially hidden = YES
    
    
    
    
    
    
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
        let player = NicooPlayerView(frame: self.fateherView.bounds, bothSidesTimelable: true)
        player.videoLayerGravity = .resizeAspectFill
        player.videoNameShowOnlyFullScreen = true
        player.delegate = self
        player.customViewDelegate = self
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
    
    //  初始化播放器
    @objc func btnclick(_ sender: UIButton) {
        // http://v.zhubodasai.com/v2/m_20181030_4690/1/d104cd51ca787c02b4ceaf084801ace4_free.m3u8
        // http://youku163.zuida-bofang.com/20180905/13609_155264ac/index.m3u8
        let url = URL(string: "http://api.gfs100.cn/upload/20180201/201802011423168057.mp4")
        playerView.playVideo(url, "VideoName", fateherView)
        
        // 初始化播放器，并从某个时间点开始播放
        //playerView.replayVideo(url, "视屏名称", fateherView, 10.0)
    }
    
    // 改变父视图
    @objc func btnclick1(_ sender: UIButton) {
        playerView.changeVideoContainerView(fateherView1)
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
            orientationSupport = NicooPlayerOrietation.orientationAll
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        /// 离开视频播放页面，只支持竖屏
        playerView.playerStatu = PlayerStatus.Pause
        orientationSupport = NicooPlayerOrietation.orientationPortrait
    }
    
    @objc func topBarCustonButtonClick(_ sender: UIButton) {
        print("button.imageName = \(sender)")
        push()
    }
    
    func push() {
        playerView.interfaceOrientation(UIInterfaceOrientation.portrait)  // 先回到竖屏状态
        navigationController?.pushViewController(NextViewController(), animated: true)
    }
    
}

// MARK: - NicooPlayerDelegate

extension PlayVideoVC: NicooPlayerDelegate, NicooCustomMuneDelegate {
    
    //    func customTopBarActions() -> [UIButton]? {
    //        var buttonS = [UIButton]()
    //        for i in 0..<3 {
    //            let button = UIButton(type: .custom)
    //            button.backgroundColor = UIColor.white
    //            button.setImage(UIImage(named: ["collection","downLoad","shareAction"][i]), for: .normal)
    //            button.addTarget(self, action: #selector(topBarCustonButtonClick(_:)), for: .touchUpInside)
    //            buttonS.append(button)
    //        }
    //        return buttonS
    //    }
    //
    func showCustomMuneView() -> UIView? {
        let view1 = CustomMuneView11(frame: self.view.bounds)
        view1.itemClick = { [weak self] in
            print("itemClick ===== ?>>>>>>>>")
        }
        return view1
        
    }
    
    func retryToPlayVideo(_ player: NicooPlayerView, _ videoModel: NicooVideoModel?, _ fatherView: UIView?) {
        print("网络不可用时调用")
        let url = URL(string: videoModel?.videoUrl ?? "")
        if  let sinceTime = videoModel?.videoPlaySinceTime, sinceTime > 0 {
            player.replayVideo(url, videoModel?.videoName, fatherView, sinceTime)
        }else {
            player.playVideo(url, videoModel?.videoName, fatherView)
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

