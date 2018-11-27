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
        
        cell?.playButtonClickBlock = { [weak self] (sender) in
            var url = URL(string: ["http://api.gfs100.cn/upload/20180126/201801261120124536.mp4","http://jdplay.lecloud.com/play.videocache.lecloud.com/274/39/9/letv-uts/14/ver_00_22-1122095005-avc-417919-aac-48000-6194667-370046165-413523a2317e7a63c6f251ada14b61d8-1541752825177.m3u8?crypt=44aa7f2e178&b=477&nlh=4096&nlt=60&bf=30&p2p=1&video_type=mp4&termid=0&tss=ios&platid=1&splatid=105&its=0&qos=3&fcheck=0&amltag=100&mltag=100&proxy=2071799162,2073440964,2071799162&uid=3663232245.rp&keyitem=GOw_33YJAAbXYE-cnQwpfLlv_b2zAkYctFVqe5bsXQpaGNn3T1-vhw..&ntm=1543321800&nkey=869176ed3f6540260f44ae010bed918b&nkey2=8b03bcfdc0269c83bb4e0c63719c4b4f&auth_key=1543321800-1-0-1-105-a7ed32217a62fb43d1ddbd1c3baf9962&geo=CN-23-323-1&mmsid=66884366&tm=1543303040&key=6f77e67dfd92ba9d6539faed6131d129&playid=0&vtype=13&cvid=1650604119571&payff=0&uidx=0&errc=0&gn=50038&ndtype=2&vrtmcd=106&buss=100&cips=218.88.124.245","http://api.gfs100.cn/upload/20180201/201802011423168057.mp4","http://api.gfs100.cn/upload/20171218/201712181643211975.mp4"][indexPath.row])
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
    
    func customTopBarActions() -> [UIButton]? {
        var buttonS = [UIButton]()
        for i in 0..<3 {
            let button = UIButton(type: .custom)
            button.backgroundColor = UIColor.white
            button.setImage(UIImage(named: ["collection","downLoad","shareAction"][i]), for: .normal)
            button.addTarget(self, action: #selector(topBarCustonButtonClick(_:)), for: .touchUpInside)
            buttonS.append(button)
        }
        return buttonS
    }
    
    func currentVideoPlayToEnd(_ videoModel: NicooVideoModel?, _ isPlayingDownLoadFile: Bool) {
        print("currentVideoPlayToEnd")
    }
    
    /// 自定义操作控件代理  ：NicooCustomMuneDelegate,   customTopBarActions 和 showCustomMuneView的优先级为  后者优先， 实现后者， 前者不起效
    
    //    func showCustomMuneView() -> UIView? {
    //
    //        if self.index%2 == 0 {
    //            let view = CustomMuneView(frame: self.view.bounds)
    //            view.itemClick = { [weak self] in
    //                self?.push()
    //            }
    //             return view
    //        }else {
    //            let view1 = CustomMuneView11(frame: self.view.bounds)
    //            view1.itemClick = { [weak self] in
    //                 self?.push()
    //            }
    //            return view1
    //        }
    //
    //    }
    
}
