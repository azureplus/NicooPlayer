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
        /// netWorkAlert 实际上应该是一个变量
        let netWorkAlert = NicooNetWorkAlert(frame: self.view.bounds, itemButtonTitles: ["流量贵","不差钱"], message: "当前为非WIFI状态，是否继续播放？")
        if  !netWorkAlert.allowedWWanPlayInCurrentVideoGroups {  // 当前这个部电视剧没有被允许
            print("当前这个部电视剧没有被允许")
        } else {
            print("已经允许当前电视剧非wifi播放，尽管看")
        }
        netWorkAlert.itemButtonClick = { [weak self] (index) in
            if index == 1 {
                netWorkAlert.allowedWWanPlayInCurrentVideoGroups = true
                let vc = CellPlayVC()
                self?.navigationController?.pushViewController(vc, animated: true)
            } else {
                netWorkAlert.allowedWWanPlayInCurrentVideoGroups = false
            }
        }
        netWorkAlert.showInWindow()
       
    }
    
    /// 下载完成的文件播放
    @IBAction func palyInFullScreenClick(_ sender: UIButton) {
        let localPlayVC = DownLoadedVideoPlayerVC()
        navigationController?.pushViewController(localPlayVC, animated: true)
    }
    @IBOutlet weak var playInFullScreen: UIButton!
    
}

