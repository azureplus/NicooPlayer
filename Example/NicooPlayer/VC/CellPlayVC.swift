//
//  CellPlayVC.swift
//  NicooPlayer_Example
//
//  Created by 小星星 on 2018/6/19.
//  Copyright © 2018年 CocoaPods. All rights reserved.
//

import UIKit
import NicooPlayer
class CellPlayVC: UIViewController,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var index = 0
    
    
    fileprivate lazy var playerView: NicooPlayerView = {
        let player = NicooPlayerView(frame: self.view.bounds)
        player.delegate = self
        player.customMuneDelegate = self   // 这个是用于自定义右上角按钮的显示
        return player
    }()
    static let cellIdentifier = "VideoCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "视频列表播放"
        tableView.tableFooterView = UIView()
        tableView.snp.makeConstraints { (make) in
            if #available(iOS 11.0, *)  {
                make.edges.equalTo(self.view.safeAreaLayoutGuide.snp.edges)
            } else {
                make.edges.equalToSuperview()
            }
        }
        tableView.register(UINib(nibName: "NicooVideoCell", bundle: nil), forCellReuseIdentifier: CellPlayVC.cellIdentifier)
        
    }
    
    deinit {
        print("试图控制器被释放了")
        playerView.removeFromSuperview()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
       
        if let cc = playerView.value(forKey: "retainCount"),let vv = self.value(forKey: "retainCount") {
            print("cccccccccccccccccc = \(cc)  ==  \(vv)")
        }
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellPlayVC.cellIdentifier, for: indexPath) as? NicooVideoCell
        
        cell?.playButtonClickBlock = { [weak self] (sender) in
            let url = String(format: "https://dn-mykplus.qbox.me/%ld.mp4", indexPath.row+1)
            self?.playerView.playVideo(url, "视频名称", cell?.backGroundImage)
            self?.index = indexPath.row
        }
        
        return cell!
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return kScreenWidth * 9/16
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    
    
}

/// MARK: 代理方法： 1. 网络不好，点击重试的操作。   2、 自定义操作栏

extension CellPlayVC: NicooPlayerDelegate, NicooCustomMuneDelegate {
    
    // NicooPlayerDelegate 网络重试
    
    func retryToPlayVideo(_ videoModel: NicooVideoModel?, _ fatherView: UIView?) {
        if  let sinceTime = videoModel?.videoPlaySinceTime, sinceTime > 0 {
            playerView.replayVideo(videoModel?.videoUrl, videoModel?.videoName, fatherView, sinceTime)
        }else {
            playerView.playVideo(videoModel?.videoUrl, videoModel?.videoName, fatherView)
        }
    }
    
    /// 自定义操作控件代理  ：NicooCustomMuneDelegate
    
    func showCustomMuneView() -> UIView? {
        
        if self.index%2 == 0 {
             let view = CustomMuneView(frame: self.view.bounds)
             return view
        }else {
            let view1 = CustomMuneView11(frame: self.view.bounds)
            return view1
        }
      return nil
    }
    
}
