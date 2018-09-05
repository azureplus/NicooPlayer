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
        if isLightContentStatusBarInFullScreen {
            if playerView.superview != nil {
                if !playerView.isFullScreen! {  // 播放器添加，全屏（这里因为横竖屏切换时，先调用这个属性，再走横竖屏的方法，所以在走这里的时候，isFullScreen还没有附上值，所以取反）
                    return .lightContent
                } else {
                    return .default
                }
            } else {  // 播放器没有添加，返回默认
                return .default
            }
        } else {
            return .default
        }
    }
    /// 全屏播放时，让状态栏变为 lightContent
    /// 1.如果整个项目的状态栏已经为 lightContent，则不需要这些操作，直接播放就好。
    /// 2.如果整个项目状态栏为default，则需要在添加播放器的页面加上一个bool判断， 再重写preferredStatusBarStyle属性,将状态栏样式与播放器的横竖屏关联，plist文件中添加: Status bar is initially hidden = YES
    var isLightContentStatusBarInFullScreen: Bool = false
    
    
    /// 播放器控件
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
    
    //cell上播放需要添加deinit， 移除播放器。释放播放器
    deinit {
        print("试图控制器被释放了")
        playerView.removeFromSuperview()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 如果当前播放器已经添加，支持横竖屏
        if playerView.superview != nil {
            orientationSupport = OrientationSupport.orientationAll
            // 视图出现时，播放器存在与当前页面
            isLightContentStatusBarInFullScreen = true
            playerView.playerStatu = PlayerStatus.Playing
        }
       
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // 视图消失时，将状态栏变为默认
        playerView.playerStatu = PlayerStatus.Pause
        isLightContentStatusBarInFullScreen = false
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
            
        } else {
             print("已经允许当前电视剧非wifi播放，尽管看")
        }
        netWorkAlert.itemButtonClick = { [weak self] (index) in
            guard let strongSelf = self else {
                return
            }
            let next = NextViewController()
            strongSelf.navigationController?.pushViewController(next, animated: true)
        }
        netWorkAlert.showInWindow()
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
        
        cell?.playButtonClickBlock = { [weak self] (sender) in
            let url = URL(string: "http://img.ytsg.cn/video/2/6/1531478862326.mp4")
            self?.playerView.playVideo(url, "视频名称", cell?.backGroundImage)
            self?.isLightContentStatusBarInFullScreen = true
            
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
