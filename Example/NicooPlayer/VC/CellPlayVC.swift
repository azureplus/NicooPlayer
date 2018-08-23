//
//  CellPlayVC.swift
//  NicooPlayer_Example
//
//  Created by 小星星 on 2018/6/19.
//  Copyright © 2018年 CocoaPods. All rights reserved.
//

import UIKit
import NicooPlayer


class CellPlayVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var index = 0
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if playerView.superview != nil {
            if !playerView.isFullScreen! {
                return .lightContent
            } else {
                return .default
            }
        } else {
            return .default
        }
        
    }
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .none
    }
    
    
    
    fileprivate lazy var playerView: NicooPlayerView = {
        let player = NicooPlayerView(frame: self.view.bounds)
        player.delegate = self
        player.customViewDelegate = self   // 这个是用于自定义右上角按钮的显示
        return player
    }()
    /// 网络变化按钮
    private lazy var barButton: UIBarButtonItem = {
        let barBtn = UIBarButtonItem(title: "模拟网络变化",  style: .plain, target: self, action: #selector(CellPlayVC.barButtonClick))
        barBtn.tintColor = UIColor.red
        return barBtn
    }()
    static let cellIdentifier = "VideoCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "视频列表播放"
        navigationItem.rightBarButtonItem = barButton
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
 
    @objc func barButtonClick() {
        /// netWorkAlert 实际上应该是一个变量
        let netWorkAlert = NicooNetWorkAlert(frame: self.view.bounds, itemButtonTitles: ["不播放","继续"], message: "是否允许非wifi播放？")
        if  !netWorkAlert.allowedWWanPlayInCurrentVideoGroups {  // 当前这个部电视剧没有被允许
            print("当前这个部电视剧没有被允许")
        } else {
             print("已经允许当前电视剧非wifi播放，尽管看")
        }
        netWorkAlert.itemButtonClick = { [weak self] (index) in
           
        }
        netWorkAlert.showInWindow()
    }
    
}

// MARK: - UITableViewDelegate UITableViewDataSource

extension CellPlayVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellPlayVC.cellIdentifier, for: indexPath) as? NicooVideoCell
        
        cell?.playButtonClickBlock = { [weak self] (sender) in
            let url = URL(string: "http://img.ytsg.cn/video/2/6/1531478862326.mp4")
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

// MARK: - 代理方法： 1. 网络不好，点击重试的操作。   2、 自定义操作栏

extension CellPlayVC: NicooPlayerDelegate, NicooCustomMuneDelegate {
    
    // NicooPlayerDelegate 网络重试
    
    func retryToPlayVideo(_ videoModel: NicooVideoModel?, _ fatherView: UIView?) {
         let url = URL(string: videoModel?.videoUrl ?? "")
        if  let sinceTime = videoModel?.videoPlaySinceTime, sinceTime > 0 {
            playerView.replayVideo(url, videoModel?.videoName, fatherView, sinceTime)
        }else {
            playerView.playVideo(url, videoModel?.videoName, fatherView)
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
      
    }
    
}
