//
//  DownLoadedVideoPlayerVC.swift
//  NicooPlayer_Example
//
//  Created by 小星星 on 2018/7/19.
//  Copyright © 2018年 CocoaPods. All rights reserved.
//

import UIKit
import NicooPlayer


/// 播放本地视频
/// 模拟播放已下载好的本地视频

class DownLoadedVideoPlayerVC: UIViewController {
    
   
    /// 播放本地文件的时候，状态栏颜色样式与是否全屏无关 （默认全屏）
    override var preferredStatusBarStyle: UIStatusBarStyle {
        let orirntation = UIApplication.shared.statusBarOrientation
        if  orirntation == UIInterfaceOrientation.landscapeLeft || orirntation == UIInterfaceOrientation.landscapeRight {
            return .lightContent
        }
        return .default
    }
   
    
    fileprivate lazy var videoPlayer: NicooPlayerView = {
        let player = NicooPlayerView(frame: self.view.frame, bothSidesTimelable: true)
        player.delegate = self
        return player
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let fileUrl = Bundle.main.path(forResource: "localFile", ofType: ".mp4")
        videoPlayer.playLocalVideoInFullscreen(fileUrl, "localFile", view, sinceTime: 0)
        videoPlayer.playLocalFileVideoCloseCallBack = { [weak self] (playValue) in
            self?.navigationController?.popViewController(animated: false)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}

// MARK: - User Actions

extension DownLoadedVideoPlayerVC {
    
    
}

// MARK: - NicooPlayerDelegate

extension DownLoadedVideoPlayerVC: NicooPlayerDelegate {
    
    func retryToPlayVideo(_ videoModel: NicooVideoModel?, _ fatherView: UIView?) {
        
    }
    
    
}
