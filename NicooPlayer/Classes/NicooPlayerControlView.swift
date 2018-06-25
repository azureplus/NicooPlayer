//
//  NicooPlayerControlView.swift
//  NicooPlayer
//
//  Created by 小星星 on 2018/6/19.
//

import UIKit


import SnapKit


protocol NicooPlayerControlViewDelegate: class {
    
    func sliderTouchBegin(_ sender: UISlider)
    func sliderTouchEnd(_ sender: UISlider)
    func sliderValueChange(_ sender: UISlider)
}

class NicooPlayerControlView: UIView {
    
    /// 顶部控制栏
    lazy var topControlBarView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.2, alpha: 0.2)
        return view
    }()
    lazy var closeButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(NicooImgManager.foundImage(imageName: "player_close"), for: .normal)
        button.setImage(NicooImgManager.foundImage(imageName: "back"), for: .selected)
        button.setImage(NicooImgManager.foundImage(imageName: "back_hight"), for: .highlighted)
        button.addTarget(self, action: #selector(closeButtonClick(_:)), for: .touchUpInside)
        return button
    }()
    lazy var munesButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(NicooImgManager.foundImage(imageName: "share"), for: .normal)
        button.setImage(NicooImgManager.foundImage(imageName: "share_hight"), for: .highlighted)
        button.addTarget(self, action: #selector(munesButtonClick(_:)), for: .touchUpInside)
        button.isHidden = true   // 默认隐藏
        return button
    }()
    lazy var videoNameLable: UILabel = {
        let lable = UILabel()
        lable.textColor = .white
        lable.font = UIFont.systemFont(ofSize: 15)
        lable.textAlignment = .left
        return lable
    }()
    /// 加载loadingView
    lazy var loadingView: UIActivityIndicatorView = {
        let loadActivityView = UIActivityIndicatorView()
        loadActivityView.activityIndicatorViewStyle = .whiteLarge
        loadActivityView.backgroundColor = UIColor.clear
        return loadActivityView
    }()
    /// 重播按钮
    lazy var replayContainerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 6
        view.backgroundColor = UIColor(white: 0.2, alpha: 0.2)
        view.layer.masksToBounds = true
        return view
    }()
    lazy var replayButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(NicooImgManager.foundImage(imageName: "replay"), for: .normal)
        button.setImage(NicooImgManager.foundImage(imageName: "replay_hight"), for: .highlighted)
        button.addTarget(self, action: #selector(NicooPlayerControlView.replayButtonClick(_:)), for: .touchUpInside)
        return button
    }()
    lazy var replayLable: UILabel = {
        let lable = UILabel()
        lable.textAlignment = .center
        lable.text = "重播"
        lable.font = UIFont.systemFont(ofSize: 13)
        lable.textColor = .white
        return lable
    }()
    /// 底部控制栏
    lazy var bottomControlBarView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.2, alpha: 0.2)
        return view
    }()
    lazy var loadedProgressView: UIProgressView = {
        let progressView = UIProgressView()
        progressView.progress = 0
        progressView.progressTintColor = UIColor.lightGray
        progressView.trackTintColor = UIColor(white: 0.2, alpha: 0.5)
        progressView.backgroundColor = UIColor.clear
        progressView.contentMode = UIViewContentMode.scaleAspectFit
        progressView.tintColor = UIColor.clear
        return progressView
    }()
    lazy var timeSlider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 0
        slider.maximumValue = 1.0
        slider.backgroundColor = UIColor.clear
        slider.contentMode = UIViewContentMode.scaleAspectFit
        slider.minimumTrackTintColor = UIColor.white
        slider.maximumTrackTintColor = UIColor.clear
        slider.setThumbImage(NicooImgManager.foundImage(imageName: "NicooPlayer_slider"), for: .normal)
        slider.addTarget(self, action: #selector(sliderValueChange(_:)),for:.valueChanged)
        slider.addTarget(self, action: #selector(sliderAllTouchBegin(_:)), for: .touchDown)
        slider.addTarget(self, action: #selector(sliderAllTouchEnd(_:)), for: .touchCancel)
        slider.addTarget(self, action: #selector(sliderAllTouchEnd(_:)), for: .touchUpInside)
        slider.addTarget(self, action: #selector(sliderAllTouchEnd(_:)), for: .touchUpOutside)
        return slider
    }()
    
    lazy var positionTimeLab: UILabel = {
        let lable = UILabel()
        lable.textAlignment = .left
        lable.text = "00:00"
        lable.font = UIFont.systemFont(ofSize: 13)
        lable.textColor = .white
        return lable
    }()
    lazy var durationTimeLab: UILabel = {
        let durationLab = UILabel()
        durationLab.textAlignment = .right
        durationLab.text = "00:00/00:00"
        durationLab.font = UIFont.systemFont(ofSize: 13)
        durationLab.textColor = .white
        return durationLab
    }()
    
    lazy var playOrPauseBtn: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(NicooImgManager.foundImage(imageName: "pause"), for: .normal)
        button.setImage(NicooImgManager.foundImage(imageName: "Player_pause"), for: .selected)
        button.addTarget(self, action: #selector(playOrPauseBtnClick(_:)), for: .touchUpInside)
        return button
    }()
    lazy var screenLockButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(NicooImgManager.foundImage(imageName: "unlock"), for: .normal)
        button.setImage(NicooImgManager.foundImage(imageName: "lockscreen"), for: .selected)
        button.addTarget(self, action: #selector(screenLockButtonClick(_:)), for: .touchUpInside)
        button.isHidden = true
        return button
    }()
    lazy var fullScreenBtn: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(NicooImgManager.foundImage(imageName: "NicooPlayer_fullscreen"), for: .normal)
        button.setImage(NicooImgManager.foundImage(imageName: "shrinkScreen"), for: .selected)
        button.addTarget(self, action: #selector(fullScreenBtnClick(_:)), for: .touchUpInside)
        return button
    }()
    /// 手势
    lazy var singleTapGesture: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer()
        gesture.addTarget(self, action: #selector(singleTapGestureRecognizers(_:)))
        gesture.numberOfTapsRequired = 1
        gesture.numberOfTouchesRequired = 1
        return gesture
    }()
    lazy var doubleTapGesture: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer()
        gesture.addTarget(self, action: #selector(doubleTapGestureRecognizers(_:)))
        gesture.numberOfTapsRequired = 2
        gesture.numberOfTouchesRequired = 1
        return gesture
    }()
    lazy var panGesture: UIPanGestureRecognizer = {
        let gesture = UIPanGestureRecognizer()
        gesture.addTarget(self, action: #selector(panGestureRecognizers(_:)))
        gesture.maximumNumberOfTouches = 1
        gesture.isEnabled = false          //先让手势不能触发
        return gesture
    }()
    
    var barIsHidden: Bool? = false {
        didSet {
            if let barIsHiden = barIsHidden {
                topControlBarView.isHidden = barIsHiden
                bottomControlBarView.isHidden = barIsHiden
                if self.fullScreen! && !self.screenIsLock! {
                    screenLockButton.isHidden = barIsHiden
                }
            }
        }
    }
    var fullScreen: Bool? = false {
        didSet {
            self.screenLockButton.isHidden = !fullScreen!     // 只有全屏能锁定屏幕
            self.munesButton.isHidden = !fullScreen!          // 只有全屏显示分享按钮
        }
    }
    
    var screenIsLock: Bool? = false {
        didSet {
            if screenIsLock! {
                self.doubleTapGesture.isEnabled = false
                self.panGesture.isEnabled = false
            }else {
                self.doubleTapGesture.isEnabled = true
                self.panGesture.isEnabled = true
            }
        }
    }
    weak var delegate: NicooPlayerControlViewDelegate?
    
    var fullScreenButtonClickBlock: ((_ sender: UIButton) -> ())?
    var playOrPauseButtonClickBlock: ((_ sender: UIButton) -> ())?
    var closeButtonClickBlock: ((_ sender: UIButton) -> ())?
    var muneButtonClickBlock:((_ sender: UIButton) -> ())?
    var replayButtonClickBlock: ((_ sender: UIButton) -> ())?
    var screenLockButtonClickBlock: ((_ sender: UIButton) -> ())?
    var pangeustureAction: ((_ sender: UIPanGestureRecognizer) ->())?
    
    init(frame: CGRect, fullScreen: Bool) {
        super.init(frame: frame)
        topControlBarView.addSubview(closeButton)
        topControlBarView.addSubview(videoNameLable)
        topControlBarView.addSubview(munesButton)
        
        bottomControlBarView.addSubview(playOrPauseBtn)
        //bottomControlBarView.addSubview(positionTimeLab)
        bottomControlBarView.addSubview(loadedProgressView)
        bottomControlBarView.addSubview(timeSlider)
        bottomControlBarView.addSubview(durationTimeLab)
        bottomControlBarView.addSubview(fullScreenBtn)
        replayContainerView.addSubview(replayButton)
        replayContainerView.addSubview(replayLable)
        
        addSubview(topControlBarView)
        addSubview(bottomControlBarView)
        addSubview(loadingView)
        addSubview(replayContainerView)
        addSubview(screenLockButton)
        
        layoutAllPageViews()
        addGestureAllRecognizers()
        
        replayContainerView.isHidden = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - add - GestureRecognizers
    
    fileprivate func addGestureAllRecognizers() {
        self.addGestureRecognizer(singleTapGesture)
        self.addGestureRecognizer(doubleTapGesture)
        self.addGestureRecognizer(panGesture)
        // 解决点击当前view时候响应其他控件事件
        singleTapGesture.delaysTouchesBegan = true
        doubleTapGesture.delaysTouchesBegan = true
        panGesture.delaysTouchesBegan = true
        panGesture.delaysTouchesEnded = true
        panGesture.cancelsTouchesInView = true
        // 双击，滑动 ，失败响应单击事件,
        singleTapGesture.require(toFail: doubleTapGesture)
        singleTapGesture.require(toFail: panGesture)
    }
    @objc func singleTapGestureRecognizers(_ sender: UITapGestureRecognizer) {
        if screenIsLock! {                                                    // 锁屏状态下，单击手势只显示锁屏按钮
            screenLockButton.isHidden = !screenLockButton.isHidden
            if screenLockButton.isHidden {
                NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(autoHideScreenLockButton), object: nil)
                self.perform(#selector(autoHideScreenLockButton), with: nil, afterDelay: 5)
            }
            
        }else {
            barIsHidden = !barIsHidden! // 单击改变操作栏的显示隐藏
            if !barIsHidden! {
                NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(autoHideScreenLockButton), object: nil)
                self.perform(#selector(autoHideTopBottomBar), with: nil, afterDelay: 5)
            }
        }
    }
    @objc func doubleTapGestureRecognizers(_ sender: UITapGestureRecognizer) {
        self.playOrPauseBtnClick(playOrPauseBtn) // 双击时直接响应播放暂停按钮点击
    }
    @objc func panGestureRecognizers(_ sender: UIPanGestureRecognizer) {
        if let panGestureAction = self.pangeustureAction {
            panGestureAction(sender)
        }
    }
    /// 自动隐藏操作栏
    @objc func autoHideTopBottomBar() {
        barIsHidden = true
    }
    /// 自动隐藏锁屏按钮
    @objc func autoHideScreenLockButton() {
        screenLockButton.isHidden = true
    }
    
    // MARK: - Slider - Action
    
    @objc func sliderValueChange (_ sender: UISlider) {
        barIsHidden = false
        delegate?.sliderValueChange(sender)
    }
    @objc func sliderAllTouchBegin(_ sender: UISlider) {
        barIsHidden = false  // 防止拖动进度时，操作栏5秒后自动隐藏
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(autoHideTopBottomBar), object: nil)
        delegate?.sliderTouchBegin(sender)
        
    }
    @objc func sliderAllTouchEnd(_ sender: UISlider) {
        delegate?.sliderTouchEnd(sender)
        if !barIsHidden! {   // 拖动完成后，操作栏5秒后自动隐藏
            self.perform(#selector(autoHideTopBottomBar), with: nil, afterDelay: 5)
        }
    }
    
    // MARK: - closeButton - Action
    
    @objc func closeButtonClick(_ sender: UIButton) {
        if self.closeButtonClickBlock != nil {
            self.closeButtonClickBlock!(sender)
        }
    }
    // MARK: - munesButton - Action
    @objc func munesButtonClick(_ sender: UIButton) {
        if self.muneButtonClickBlock != nil {
            self.muneButtonClickBlock!(sender)
        }
    }
    // MARK: - PlayOrPause - Action
    
    @objc func playOrPauseBtnClick(_ sender: UIButton) {
        if self.playOrPauseButtonClickBlock != nil {
            self.playOrPauseButtonClickBlock!(sender)
        }
    }
    // MARK: - screenLockButton - Action
    
    @objc func screenLockButtonClick(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        self.screenIsLock = sender.isSelected
        self.barIsHidden = self.screenIsLock
        if self.screenLockButtonClickBlock != nil {
            self.screenLockButtonClickBlock!(sender)
        }
    }
    
    // MARK: - FullScreen - Action
    
    @objc func fullScreenBtnClick(_ sender: UIButton){
        if self.fullScreenButtonClickBlock != nil {
            self.fullScreenButtonClickBlock!(sender)
        }
    }
    
    // MARK: - ReplayButtonClick
    @objc func replayButtonClick(_ sender: UIButton) {
        if self.replayButtonClickBlock != nil {
            self.replayButtonClickBlock!(sender)
        }
    }
    // MARK: - layoutAllSubviews
    
    private func layoutAllPageViews() {
        layoutTopControlBarView()
        layoutCloseButton()
        layoutMunesButton()
        layoutVideoNameLable()
        layoutBottomControlBarView()
        layoutPlayOrPauseBtn()
        // layoutPositionTimeLab()
        layoutFullScreenBtn()
        layoutDurationTimeLab()
        layoutLoadedProgressView()
        layoutTimeSlider()
        layoutLoadingActivityView()
        layoutReplayContainerView()
        layoutReplayButton()
        layoutReplayLable()
        layoutScreenLockButton()
    }
    private func layoutBottomControlBarView() {
        bottomControlBarView.snp.makeConstraints { (make) in
            make.leading.bottom.trailing.equalTo(0)
            make.height.equalTo(40)
        }
    }
    private func layoutCloseButton() {
        closeButton.snp.makeConstraints { (make) in
            make.leading.top.bottom.equalToSuperview()
            make.width.equalTo(40)
        }
    }
    private func layoutMunesButton() {
        munesButton.snp.makeConstraints { (make) in
            make.trailing.top.bottom.equalToSuperview()
            make.width.equalTo(60)
        }
    }
    private func layoutVideoNameLable() {
        videoNameLable.snp.makeConstraints { (make) in
            make.top.bottom.equalToSuperview()
            make.leading.equalTo(closeButton.snp.trailing).offset(5)
            make.trailing.equalToSuperview().offset(80)
        }
    }
    private func layoutLoadingActivityView() {
        loadingView.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.width.equalTo(40)
            make.height.equalTo(40)
        }
    }
    private func layoutReplayContainerView() {
        replayContainerView.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.width.equalTo(70)
            make.height.equalTo(70)
        }
    }
    private func layoutReplayButton() {
        replayButton.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(5)
            make.height.equalTo(40)
            make.width.equalTo(40)
        }
    }
    private func layoutScreenLockButton() {
        screenLockButton.snp.makeConstraints { (make) in
            make.leading.equalTo(10)
            make.centerY.equalToSuperview()
            make.height.equalTo(60)
            make.width.equalTo(60)
        }
    }
    private func layoutReplayLable() {
        replayLable.snp.makeConstraints { (make) in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(25)
        }
    }
    private func layoutTopControlBarView() {
        topControlBarView.snp.makeConstraints { (make) in
            make.leading.top.trailing.equalTo(0)
            make.height.equalTo(40)
        }
    }
    private func layoutPlayOrPauseBtn() {
        playOrPauseBtn.snp.makeConstraints { (make) in
            make.top.leading.equalTo(5)
            make.bottom.equalTo(-5)
            make.width.equalTo(30)
        }
    }
    private func layoutPositionTimeLab() {
        positionTimeLab.snp.makeConstraints { (make) in
            make.leading.equalTo(playOrPauseBtn.snp.trailing).offset(5)
            make.centerY.equalTo(bottomControlBarView.snp.centerY)
            make.height.equalTo(25)
            make.width.equalTo(45)
        }
    }
    private func layoutLoadedProgressView() {
        loadedProgressView.snp.makeConstraints { (make) in
            make.centerY.equalTo(bottomControlBarView.snp.centerY)
            make.height.equalTo(1.5)
            make.leading.equalTo(playOrPauseBtn.snp.trailing).offset(5)
            make.trailing.equalTo(durationTimeLab.snp.leading).offset(-5)
        }
    }
    private func layoutTimeSlider() {
        timeSlider.snp.makeConstraints { (make) in
            make.centerY.equalTo(loadedProgressView.snp.centerY).offset(-1)  // 调整一下进度条和 加载进度条的位置
            make.leading.equalTo(loadedProgressView.snp.leading)
            make.trailing.equalTo(loadedProgressView.snp.trailing)
            make.height.equalTo(30)
        }
    }
    private func layoutDurationTimeLab() {
        durationTimeLab.snp.makeConstraints { (make) in
            make.trailing.equalTo(fullScreenBtn.snp.leading).offset(-5)
            make.height.equalTo(25)
            make.centerY.equalTo(bottomControlBarView.snp.centerY)
            make.width.equalTo(80)
        }
    }
    private func layoutFullScreenBtn() {
        fullScreenBtn.snp.makeConstraints { (make) in
            make.trailing.top.bottom.equalToSuperview()
            make.width.equalTo(40)
        }
    }
    
}
