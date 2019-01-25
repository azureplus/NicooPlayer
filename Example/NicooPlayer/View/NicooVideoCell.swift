//
//  NicooVideoCell.swift
//  NicooPlayer_Example
//
//  Created by 小星星 on 2018/6/19.
//  Copyright © 2018年 CocoaPods. All rights reserved.
//

import UIKit

class NicooVideoCell: UITableViewCell {

    static let cellIdentifier = "VideoCell"
    
    @IBOutlet weak var backGroundImage: UIImageView!
    lazy var playButton: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = UIColor.black
        button.layer.cornerRadius = 30
        button.layer.masksToBounds = true
        button.setImage(UIImage(named: "pause"), for: .normal)
        button.addTarget(self, action: #selector(playButtonClick(_:)), for: .touchUpInside)
        return button
    }()
    // 是否播放器已经存在
    var isPlayerExist = false
    
    var playButtonClickBlock:((_ sender: UIButton) ->())?
    var goDetailClick:((_ sender: UIButton) ->Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backGroundImage.addSubview(playButton)
        playButton.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.width.height.equalTo(60)
        }
    }
    
    @IBAction func goNextDetail(_ sender: UIButton) {
        goDetailClick?(sender)
    }
    
    @objc func playButtonClick(_ sender: UIButton) {
        if  self.playButtonClickBlock != nil {
            self.playButtonClickBlock!(sender)
        }
    }
    
}
