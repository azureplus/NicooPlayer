//
//  CustomMuneView.swift
//  NicooPlayer_Example
//
//  Created by 小星星 on 2018/7/5.
//  Copyright © 2018年 CocoaPods. All rights reserved.
//

import UIKit

class CustomMuneView: UIView {

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.removeFromSuperview()
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor(white: 0, alpha: 0.7)
        loadUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func loadUI() {
        let sideView = UIView()
        addSubview(sideView)
        sideView.backgroundColor = UIColor(white: 1, alpha: 0.9)
        sideView.snp.makeConstraints { (make) in
            make.top.trailing.bottom.equalToSuperview()
            make.width.equalTo(200)
        }
        
        for index in 0...5 {
            let button = UIButton(type: .custom)
            button.setTitle(["QQ", "微信", "朋友圈","QQ空间" , "新浪微博", "复制链接"][index], for: .normal)
            button.setImage(UIImage(named: ["qq","wechat","session","qzone","sinaweibo","copyLink"][index]), for: .normal)
            button.setTitleColor(UIColor.darkGray, for: .normal)
            button.tag = index + 33
            button.titleLabel?.font = UIFont.systemFont(ofSize: 17)
            button.titleEdgeInsets.left = 20
            button.addTarget(self, action: #selector(muneButtonClick(_:)), for: .touchUpInside)
            sideView.addSubview(button)
            button.snp.makeConstraints { (make) in
                make.leading.equalTo(10)
                make.trailing.equalTo(-10)
                make.top.equalTo(20+55*index)
                make.height.equalTo(40)
            }
        }
    }
    @objc func muneButtonClick(_ sender: UIButton) {
        print("sender.title = \(String(describing: sender.titleLabel?.text))")
    }

}

class CustomMuneView11: UIView {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.removeFromSuperview()
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor(white: 0, alpha: 0.5)
        loadUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func loadUI() {
        let sideView = UIView()
        addSubview(sideView)
        sideView.backgroundColor = UIColor(white: 1, alpha: 1)
        sideView.snp.makeConstraints { (make) in
            make.leading.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.equalTo(120)
            make.height.equalTo(190)
        }
        
        for index in 0...2 {
            let button = UIButton(type: .custom)
            button.setTitle(["下载", "分享", "收藏"][index], for: .normal)
            button.setImage(UIImage(named: ["downLoad","shareAction","collection"][index]), for: .normal)
            button.setTitleColor(UIColor.darkGray, for: .normal)
            button.tag = index + 33
            button.titleLabel?.font = UIFont.systemFont(ofSize: 17)
            button.titleEdgeInsets.left = 20
            button.addTarget(self, action: #selector(muneButtonClick(_:)), for: .touchUpInside)
            sideView.addSubview(button)
            button.snp.makeConstraints { (make) in
                make.leading.equalTo(15)
                make.trailing.equalTo(-20)
                make.top.equalTo(20+55*index)
                make.height.equalTo(40)
            }
        }
    }
    @objc func muneButtonClick(_ sender: UIButton) {
        print("sender.title = \(String(describing: sender.titleLabel?.text))")
    }
    
}

