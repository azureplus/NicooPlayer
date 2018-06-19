//
//  NicooShareMuneView.swift
//  NicooPlayer
//
//  Created by 小星星 on 2018/6/19.
//

import UIKit
import SnapKit
public protocol NicooPlayerShareDelegate: class {
    /// 分享到平台按钮点击
    ///
    /// - Parameter shreType: 点击按钮的Index
    func shareMuneItemSelected(_ shreType:Int)
}

class NicooPlayerShareView: UIView {
    
    weak var delegate: NicooPlayerShareDelegate?
    
    fileprivate lazy var shareMunesContainer: NicooPlayerShareMuneView = {
        let view = NicooPlayerShareMuneView(frame: CGRect(x: 0, y: 0, width: 70*6, height: 70))
        view.backgroundColor = UIColor.clear
        return view
    }()
    fileprivate lazy var titleLab: UILabel = {
        let lable = UILabel()
        lable.textAlignment = .center
        lable.textColor = UIColor.white
        lable.font = UIFont.systemFont(ofSize: 17)
        lable.text = "分享到"
        return lable
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadShareView()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private func loadShareView() {
        self.addSubview(shareMunesContainer)
        self.addSubview(titleLab)
        layoutShareContainer()
        shareMunesContainer.muneItemClick = { [weak self] (shareIndex) in
            self?.delegate?.shareMuneItemSelected(shareIndex)
            self?.removeFromSuperview()
        }
    }
    private func layoutShareContainer() {
        titleLab.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-70)
        }
        shareMunesContainer.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.height.equalTo(70)
            make.width.equalTo(70*6)
        }
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.removeFromSuperview()
    }
}
class NicooPlayerShareMuneView: UIView {
    
    fileprivate var muneItemClick:((_ type: Int) ->())?
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createShareMuneView()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private func createShareMuneView() {
        let shareImages = ["wechat","session","qq","qzone","sinaweibo","copyLink"]
        let shareTitles = ["微信","朋友圈","QQ","QQ空间","新浪微博","复制链接"]
        for index in 0...5 {
            let mune = ShareMuneVie(frame: CGRect(x: 0, y: 0, width: 70, height: 70))
            mune.backgroundColor = UIColor.clear
            mune.muneButton.tag = index
            mune.muneButton.setImage(NicooImgManager.foundImage(imageName: shareImages[index]), for: .normal)
            mune.muneButton.addTarget(self, action: #selector(shareMuneButtonClick(_:)), for: .touchUpInside)
            mune.muneLable.text = shareTitles[index]
            self.addSubview(mune)
            mune.snp.makeConstraints { (make) in
                make.centerX.equalTo(35+70*index)
                make.centerY.equalToSuperview()
                make.width.equalTo(70)
                make.height.equalTo(70)
            }
        }
    }
    @objc func shareMuneButtonClick(_ sender: UIButton) {
        if self.muneItemClick != nil {
            self.muneItemClick!(sender.tag)
        }
        
    }
    
}
class ShareMuneVie: UIView {
    fileprivate lazy var muneButton: UIButton = {
        let button = UIButton(type: .custom)
        return button
    }()
    fileprivate lazy var muneLable: UILabel = {
        let lable = UILabel()
        lable.textAlignment = .center
        lable.font = UIFont.systemFont(ofSize: 13)
        lable.textColor = UIColor.white
        return lable
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadUI()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private func loadUI() {
        addSubview(muneButton)
        addSubview(muneLable)
        layoutMuneSubviews()
    }
    private func layoutMuneSubviews() {
        muneButton.snp.makeConstraints { (make) in
            make.top.centerX.equalToSuperview()
            make.height.equalTo(44)
            make.width.equalTo(44)
        }
        muneLable.snp.makeConstraints { (make) in
            make.top.equalTo(muneButton.snp.bottom).offset(7)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
}

