//
//  VideoPlayerFatherView.swift
//  NicooPlayer_Example
//
//  Created by 小星星 on 2018/8/23.
//  Copyright © 2018年 CocoaPods. All rights reserved.
//

import UIKit
import NicooPlayer

class VideoPlayerFatherView: UIView {

    private lazy var playerView: NicooPlayerView = {
        let player = NicooPlayerView(frame: self.bounds)
        player.delegate = self
        return player
    }()
    
    private var videoUrl: String?
    
    deinit {
        print("playerView bgView 释放")
    }
    init(frame: CGRect, _ videoUrl: String?) {
        super.init(frame: frame)
        self.videoUrl = videoUrl
        
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

//MARK: - Public Funcs

extension VideoPlayerFatherView {
    
    func playLocalVideo(fileUrl: String, videoName: String?, sinceTime: Float?, _ VC: DownLoadedVideoPlayerVC) {
        self.videoUrl = fileUrl
        playerView.playLocalVideoInFullscreen(self.videoUrl, videoName, self, sinceTime: sinceTime)
        playerView.playLocalFileVideoCloseCallBack = { [weak self] (playValue) in
            VC.isLightContentStatusBar = false   // 状态栏变为黑色
            guard let strongSelf = self else {
                return
            }
            // 移除播放器
            if let container = strongSelf.superview {
                if container.subviews.contains(strongSelf) {
                    strongSelf.removeFromSuperview()
                }
            }
        }
        
    }
}


//MARK: - NicooPlayerDelegate

extension VideoPlayerFatherView: NicooPlayerDelegate {
    
    func retryToPlayVideo(_ videoModel: NicooVideoModel?, _ fatherView: UIView?) {
        playerView.playLocalVideoInFullscreen(self.videoUrl, videoModel?.videoName, self, sinceTime: videoModel?.videoPlaySinceTime)
    }
    
    func currentVideoPlayToEnd(_ videoModel: NicooVideoModel?, _ isPlayingDownLoadFile: Bool) {
        
    }
}
