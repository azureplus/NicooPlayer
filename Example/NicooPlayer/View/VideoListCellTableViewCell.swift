//
//  VideoListCellTableViewCell.swift
//  VideoProject
//
//  Created by 小星星 on 2018/6/14.
//  Copyright © 2018年 yangxin. All rights reserved.
//

import UIKit
import SnapKit
class VideoListCellTableViewCell: UITableViewCell {

    @IBOutlet weak var backgroundImage: UIImageView!
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
       self.backgroundImage.addSubview(playButton)
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
    func configureCell() {
//        let url = "http://img.wdjimg.com/image/video/cd47d8370569dbb9b223942674c41785_0_0.jpeg"
//        let imageUrl = URL(string: url)
//    
//        backgroundImage.kf.setImage(with: imageUrl, placeholder: nil, options: [.transition(ImageTransition.fade(1))], progressBlock: { (receivedSize, totalSize) in
//            
//        }) { (image, error, cacheType, imageUrl) in
//            
//        }
       
        
    }
}
