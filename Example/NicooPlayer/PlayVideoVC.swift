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
class PlayVideoVC: UIViewController,NicooPlayerDelegate {
    
    
    
    lazy var playOrPauseBtn: UIButton = {
        let button = UIButton(type: .custom)
        
        button.setTitle("重置播放器", for: .normal)
        button.backgroundColor = UIColor.gray
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.addTarget(self, action: #selector(PlayVideoVC.btnclick(_:)), for: .touchUpInside)
        return button
    }()
    lazy var playOrPauseBtn1: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("改变父视图", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.backgroundColor = UIColor.gray
        button.addTarget(self, action: #selector(PlayVideoVC.btnclick1(_:)), for: .touchUpInside)
        return button
    }()
    lazy var getInfoBtn: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("获取进度", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.backgroundColor = UIColor.gray
        button.addTarget(self, action: #selector(PlayVideoVC.btnclick2(_:)), for: .touchUpInside)
        return button
    }()
    lazy var fateherView: UIView = {
        let view = UIView()
        view.frame = CGRect(x:0, y: 100, width: kScreenWidth, height: kScreenWidth*9/16)
        view.backgroundColor = UIColor.gray
        return view
    }()
    lazy var fateherView1: UIView = {
        let view = UIView()
        view.frame = CGRect(x:10, y: 120 + kScreenWidth * 9/16, width: (kScreenWidth - 20), height: (kScreenWidth - 20)*9/16)
        view.backgroundColor = UIColor.darkGray
        return view
    }()
    lazy var playerView: NicooPlayerView = {
        let player = NicooPlayerView(frame: self.fateherView.bounds)
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
        
        view.backgroundColor = UIColor.white
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
        view.addSubview(playOrPauseBtn)
        view.addSubview(playOrPauseBtn1)
        view.addSubview(getInfoBtn)
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
    
    @objc func btnclick(_ sender: UIButton) {
        //  初始化播放器
        playerView.playVideo("https://dn-mykplus.qbox.me/2.mp4", "这里传递视屏名称", fateherView)
        
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
    
    // 暴力支持横屏
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isAllowAutorotate = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        isAllowAutorotate = false
       
    }
    
    //MARK: - NicooPlayerDelegate
    func retryToPlayVideo(_ videoModel: NicooVideoModel?, _ fatherView: UIView?) {
        print("网络不可用时调用")
        if  let sinceTime = videoModel?.videoPlaySinceTime, sinceTime > 0 {
            playerView.replayVideo(videoModel?.videoUrl, videoModel?.videoName, fatherView, sinceTime)
        }else {
            playerView.playVideo(videoModel?.videoUrl, videoModel?.videoName, fatherView)
        }
    }
    func playerDidSelectedItemIndex(_ index: Int) {
        print("分享按钮点击第几个: index = \(index)")
    }
    
}

