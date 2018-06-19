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
    fileprivate lazy var playerView: NicooPlayerView = {
        let player = NicooPlayerView(frame: self.view.bounds)
        player.delegate = self
        return player
    }()
    static let cellIdentifier = "VideoCell"
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "视频列表播放"
        tableView.tableFooterView = UIView()
        tableView.snp.makeConstraints { (make) in
            if #available(iOS 11.0, *)  {
                make.edges.equalTo(self.view.safeAreaInsets)
            } else {
                make.edges.equalToSuperview()
            }
        }
        tableView.register(UINib(nibName: "NicooVideoCell", bundle: nil), forCellReuseIdentifier: CellPlayVC.cellIdentifier)
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isAllowAutorotate = true
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        isAllowAutorotate = false
        self.playerView.destructPlayerResource()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellPlayVC.cellIdentifier, for: indexPath) as? NicooVideoCell
        
        cell?.playButtonClickBlock = { (sender) in
            let url = String(format: "https://dn-mykplus.qbox.me/%ld.mp4", indexPath.row)
            self.playerView.playVideo(url, "视频名称", cell?.backGroundImage)
        }
        
        
        return cell!
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return kScreenWidth * 9/16
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
}
extension CellPlayVC: NicooPlayerDelegate {
    func retryToPlayVideo(_ videoModel: NicooVideoModel?, _ fatherView: UIView?) {
        if  let sinceTime = videoModel?.videoPlaySinceTime, sinceTime > 0 {
            playerView.replayVideo(videoModel?.videoUrl, videoModel?.videoName, fatherView, sinceTime)
        }else {
            playerView.playVideo(videoModel?.videoUrl, videoModel?.videoName, fatherView)
        }
    }
    func playerDidSelectedItemIndex(_ index: Int) {
        
    }
    
    
    
}
