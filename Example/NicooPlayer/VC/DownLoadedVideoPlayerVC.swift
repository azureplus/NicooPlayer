//
//  DownLoadedVideoPlayerVC.swift
//  NicooPlayer_Example
//
//  Created by 小星星 on 2018/7/19.
//  Copyright © 2018年 CocoaPods. All rights reserved.
//

import UIKit
import NicooPlayer
class DownLoadedVideoPlayerVC: UIViewController {
    override var prefersStatusBarHidden: Bool {
        return true
    }
    override func viewDidLoad() {
        super.viewDidLoad()
 
        self.view.backgroundColor = UIColor.white
        //  这里应该走另一条线，一个简单的视频播放，将播放View旋转90度。
        let player = NicooPlayerView(frame: self.view.frame)
        
        let fileUrl = Bundle.main.path(forResource: "localFile", ofType: ".mp4")
        
        player.playLocalVideoInFullscreen(fileUrl, "videoName", view)
        
        player.playLocalFileVideoCloseCallBack = { [weak self] (playValue) in
            self?.dismiss(animated: true, completion: nil)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
