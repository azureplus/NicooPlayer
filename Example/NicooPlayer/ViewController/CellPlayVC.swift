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
    
    static let cellIdentifier = "VideoCell"
    
    @IBOutlet weak var tableView: UITableView!
    
    var index = 0
    
    /// 这里重写系统方法，为了让 StatusBar 跟随播放器的操作栏一起 隐藏或显示，且在全屏播放时， StatusBar 样式变为 lightContent
    override var preferredStatusBarStyle: UIStatusBarStyle {
        let orirntation = UIApplication.shared.statusBarOrientation
        if  orirntation == UIInterfaceOrientation.landscapeLeft || orirntation == UIInterfaceOrientation.landscapeRight {
            return .lightContent
        }
        return .default
    }
    /// 全屏播放时，让状态栏变为 lightContent
    /// 1.如果整个项目的状态栏已经为 lightContent，则不需要这些操作，直接播放就好。
    /// 2.如果整个项目状态栏为default，则需要在添加播放器的页面加上一个bool判断， 再重写preferredStatusBarStyle属性,将状态栏样式与播放器的横竖屏关联，plist文件中添加: Status bar is initially hidden = YES
    
    
    
    /// 播放器控件
    fileprivate lazy var playerView: NicooPlayerView = {
        let player = NicooPlayerView(frame: self.view.bounds)
        player.videoLayerGravity = .resizeAspect
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
    
    //cell上播放需要添加deinit， 移除播放器。释放播放器
    deinit {
        print("试图控制器被释放了")
        playerView.removeFromSuperview()
    }
    
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
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 如果当前播放器已经添加，支持横竖屏
        if playerView.superview != nil {
            orientationSupport = NicooPlayerOrietation.orientationAll
            // 视图出现时，播放器存在与当前页面
            playerView.playerStatu = PlayerStatus.Playing
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // 视图消失时，暂停播放，屏幕只支持竖屏
        playerView.playerStatu = PlayerStatus.Pause
        orientationSupport = NicooPlayerOrietation.orientationPortrait
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if let cc = playerView.value(forKey: "retainCount"),let vv = self.value(forKey: "retainCount") {
            print("cccccccccccccccccc = \(cc)  ==  \(vv)")
        }
        
    }
    
    @objc func barButtonClick() {
        /// netWorkAlert 实际上应该是一个变量
        playerView.cancle()
        //        let netWorkAlert = NicooNetWorkAlert(frame: self.view.bounds, itemButtonTitles: ["不播放","继续"], message: "是否允许非wifi播放？")
        //        if  !netWorkAlert.allowedWWanPlayInCurrentVideoGroups {  // 当前这个部电视剧没有被允许
        //
        //        } else {
        //             print("已经允许当前电视剧非wifi播放，尽管看")
        //        }
        //        netWorkAlert.itemButtonClick = { [weak self] (index) in
        //            guard let strongSelf = self else {
        //                return
        //            }
        //            let next = NextViewController()
        //            strongSelf.navigationController?.pushViewController(next, animated: true)
        //        }
        //        netWorkAlert.showInWindow()
    }
    
    @objc func topBarCustonButtonClick(_ sender: UIButton) {
        self.push()
    }
    
    func push() {
        playerView.interfaceOrientation(UIInterfaceOrientation.portrait)  // 先回到竖屏状态
        navigationController?.pushViewController(NextViewController(), animated: true)
    }
    
}

// MARK: - UITableViewDelegate UITableViewDataSource

extension CellPlayVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellPlayVC.cellIdentifier, for: indexPath) as? NicooVideoCell
        //http://flv2.bn.netease.com/videolib3/1609/12/aOzvT5225/HD/movie_index.m3u8
        cell?.playButtonClickBlock = { [weak self] (sender) in
            var url = URL(string: ["http://api.gfs100.cn/upload/20180126/201801261120124536.mp4","http://flv2.bn.netease.com/videolib3/1609/12/aOzvT5225/HD/movie_index.m3u8","http://api.gfs100.cn/upload/20180201/201802011423168057.mp4","http://api.gfs100.cn/upload/20171218/201712181643211975.mp4"][indexPath.row])
            if indexPath.row == 0 {
                if let filePath = Bundle.main.path(forResource: "hubblecast", ofType: ".m4v") {
                    url = URL(fileURLWithPath: filePath)
                }
            }
            
            let videoDicPath: String = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).last!
            print("document = \(videoDicPath)")
            self?.playerView.playVideo(url, "VideoName", cell?.backGroundImage)
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
    
    func currentVideoPlayToEnd(_ videoModel: NicooVideoModel?, _ isPlayingDownLoadFile: Bool) {
        print("currentVideoPlayToEnd")
    }
    
    /// 自定义操作控件代理  ：NicooCustomMuneDelegate,   customTopBarActions 和 showCustomMuneView的优先级为  后者优先， 实现后者， 前者不起效
    
        func showCustomMuneView() -> UIView? {
    
            if self.index%2 == 0 {
                let view = CustomMuneView(frame: self.view.bounds)
                view.itemClick = { [weak self] in
                    self?.push()
                }
                 return view
            }else {
                let view1 = CustomMuneView11(frame: self.view.bounds)
                view1.itemClick = { [weak self] in
                     self?.push()
                }
                return view1
            }
    
        }
    
}
