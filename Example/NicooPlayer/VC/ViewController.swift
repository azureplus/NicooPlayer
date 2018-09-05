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
   
    override func viewDidLoad() {
        super.viewDidLoad()
    
    }
 
    @IBAction func playInView(_ sender: UIButton) {
        let vc = PlayVideoVC()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func playInCell(_ sender: UIButton) {
        
        let vc = CellPlayVC()
        self.navigationController?.pushViewController(vc, animated: true)
       
    }
    
    /// 下载完成的文件播放
    @IBAction func palyInFullScreenClick(_ sender: UIButton) {
        let localPlayVC = DownLoadedVideoPlayerVC()
        navigationController?.pushViewController(localPlayVC, animated: true)
    }
    @IBOutlet weak var playInFullScreen: UIButton!
    
}

