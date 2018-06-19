//
//  NicooVideoCell.swift
//  NicooPlayer_Example
//
//  Created by 小星星 on 2018/6/19.
//  Copyright © 2018年 CocoaPods. All rights reserved.
//

import UIKit

class NicooVideoCell: UITableViewCell {

    @IBOutlet weak var backGroundImage: UIImageView!
    lazy var playButton: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = UIColor.black
        button.layer.cornerRadius = 30
        button.layer.masksToBounds = true
        button.setImage(UIImage(named: "pause"), for: .normal)
        button.addTarget(self, action: #selector(playButtonClick(_:)), for: .touchUpInside)
        button.tag = 99         // 这里Ta必须要有， 并设为非0
        return button
    }()
    
    var playButtonClickBlock:((_ sender: UIButton) ->())?
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backGroundImage.addSubview(playButton)
        playButton.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.width.height.equalTo(60)
        }
    }
    
    @objc func playButtonClick(_ sender: UIButton) {
        if  self.playButtonClickBlock != nil {
            self.playButtonClickBlock!(sender)
        }
    }
    
}
