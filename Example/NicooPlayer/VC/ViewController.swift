//
//  ViewController.swift
//  NicooPlayer
//
//  Created by 504672006@qq.com on 06/19/2018.
//  Copyright (c) 2018 504672006@qq.com. All rights reserved.
//

import UIKit
import NicooPlayer
class ViewController: UIViewController{
    override var prefersStatusBarHidden: Bool {
        return true
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    
    }

    
    @IBAction func playInView(_ sender: UIButton) {
        let vc = PlayVideoVC()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func playInCell(_ sender: UIButton) {
        let vc = CellPlayVC()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    /// 下载完成的，播放时不需要网络，不需要实现 delegate ，可以选择实现customVideDelegate
    @IBAction func palyInFullScreenClick(_ sender: UIButton) {
       self.present(DownLoadedVideoPlayerVC(), animated: false, completion: nil)
    }
    @IBOutlet weak var playInFullScreen: UIButton!
    
}

