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
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    /// 播放本地文件的时候，状态栏颜色样式与是否全屏无关 （默认全屏）
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if isLightContentStatusBar {
            return .lightContent
        } else {
            return .default
        }
    }
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .none
    }
    
    var isLightContentStatusBar: Bool = false
    
    fileprivate lazy var playLocalButton: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = UIColor.yellow
        button.setTitle("播放本地文件", for: .normal)
        button.setTitleColor(UIColor.darkGray, for: .normal)
        button.addTarget(self, action: #selector(DownLoadedVideoPlayerVC.playLacalFileVideo), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        
        view.addSubview(playLocalButton)
        layouPageSubviews()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}

// MARK: - User Actions

extension DownLoadedVideoPlayerVC {
    
    @objc func playLacalFileVideo() {
        isLightContentStatusBar = true  // 开始播放，状态栏变为白色
        
        let fileUrl = Bundle.main.path(forResource: "localFile", ofType: ".mp4")
        let videoBgView = VideoPlayerFatherView(frame: self.view.bounds, fileUrl)
        videoBgView.backgroundColor = UIColor.blue
        view.addSubview(videoBgView)
        layoutVideoBgView(videoBgView)
        videoBgView.playLocalVideo(fileUrl: fileUrl!, videoName:  "localFile", sinceTime: 0, self)
    }
    
}

// MARK: - Layout

extension DownLoadedVideoPlayerVC {
    
    func layouPageSubviews() {
        layoutPlayButton()
    }
    func layoutVideoBgView(_ videoBGview: UIView) {
        videoBGview.snp.makeConstraints { (make) in
            make.leading.trailing.top.equalToSuperview()
            make.height.equalTo(UIScreen.main.bounds.size.width * 9/16)
        }
    }
    func layoutPlayButton() {
        playLocalButton.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.height.equalTo(70)
            make.width.equalTo(120)
        }
    }
}
