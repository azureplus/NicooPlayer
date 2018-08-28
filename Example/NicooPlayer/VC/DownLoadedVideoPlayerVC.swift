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
        if isLightContentStatusBar {
            return .lightContent
        } else {
            return .default
        }
    }
   
    
    var isLightContentStatusBar: Bool = false
    
    fileprivate lazy var videoPlayer: NicooPlayerView = {
        //  这里应该走另一条线，一个简单的视频播放，将播放View旋转90度。
        let player = NicooPlayerView(frame: self.view.frame, bottomBarBothSide: true)
        player.delegate = self
        return player
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        
        isLightContentStatusBar = true // 开始播放，状态栏变为白色
        
        let fileUrl = Bundle.main.path(forResource: "localFile", ofType: ".mp4")
        videoPlayer.playLocalVideoInFullscreen(fileUrl, "localFile", view, sinceTime: 0)
        videoPlayer.playLocalFileVideoCloseCallBack = { [weak self] (playValue) in
            // 这里由于出现了一个处理不了的bug，所以才这样先横屏再竖屏的
            self?.isLightContentStatusBar = false   // 变为黑色
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
