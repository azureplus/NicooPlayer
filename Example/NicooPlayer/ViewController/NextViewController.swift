//
//  NextViewController.swift
//  NicooPlayer_Example
//
//  Created by 小星星 on 2018/9/5.
//  Copyright © 2018年 CocoaPods. All rights reserved.
//

import UIKit
import NicooPlayer

class NextViewController: UIViewController {

    lazy var fateherView: UIView = {
        let view = UIView()
        view.frame = CGRect(x:0, y: 100, width: kScreenWidth, height: kScreenWidth*9/16)
        view.backgroundColor = UIColor.gray
        return view
    }()
    private lazy var barButton: UIBarButtonItem = {
        let barBtn = UIBarButtonItem(title: "跳转下页",  style: .plain, target: self, action: #selector(NextViewController.barButtonClick))
        barBtn.tintColor = UIColor.red
        return barBtn
    }()
    
    var playerViewExist = false
    var videoUrl: String?
    var playerView: NicooPlayerView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        navigationItem.rightBarButtonItem = barButton
        view.addSubview(fateherView)
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        createOrRecivePlayer()
        // 如果当前播放器已经添加，支持横竖屏
        if fateherView.subviews.contains(playerView!) {
            orientationSupport = NicooPlayerOrietation.orientationAll
        }
        
    }
    
    /// 创建或者接收播放器
    private func createOrRecivePlayer() {
        if !playerViewExist {
            if playerView != nil {
                /// 接受列表页面传过来的 播放器
                recivePlayerFromLastPage()
            } else {
                /// 创建一个播放器
                playerView = NicooPlayerView.init(frame: fateherView.bounds, bothSidesTimelable: true)
                playerView?.delegate = self
                let url = URL(string: videoUrl ?? "")
                playerView?.playVideo(url, "i am new palyer", fateherView)
            }
            playerViewExist = true
        }
    }
    
    /// 接收上个页面的播放器
    private func recivePlayerFromLastPage() {
        if playerView != nil {
            playerView!.changeVideoContainerView(fateherView)
            playerView!.delegate = self
        }
    }
    
    @objc func barButtonClick() {
        /// 离开视频详情播放页面，push进入别的页面，只支持竖屏
        
        //(这里，如果有网络监听，要将网络监听取消掉，否则在4G切换到wifi 时视频会自动播放，导致，页面在下一级页面，而播放器却在播放声音)
        /// 移除监听 ： 详情页面会有  
        NotificationCenter.default.removeObserver(self)
        
        playerView!.playerStatu = PlayerStatus.Pause
        orientationSupport = NicooPlayerOrietation.orientationPortrait
        let next = UIViewController()
        next.view.backgroundColor = UIColor.white
        navigationController?.pushViewController(next, animated: true)
    }
    

}

// MARK: - NicooPlayerDelegate
extension NextViewController: NicooPlayerDelegate {
    
    func retryToPlayVideo(_ player: NicooPlayerView , _ videoModel: NicooVideoModel?, _ fatherView: UIView?) {
        
    }
    
    func currentVideoPlayToEnd(_ videoModel: NicooVideoModel?, _ isPlayingDownLoadFile: Bool) {
        print("NextViewController -->> currentVideoPlayToEnd")
    }
}
