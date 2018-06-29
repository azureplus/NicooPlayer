//
//  NicooImgManager.swift
//  NicooPlayer
//
//  Created by 小星星 on 2018/6/19.
//

import UIKit

class NicooImgManager: UIView {
    class func foundImage(imageName:String) -> UIImage? {
        let bundleB  = Bundle(for: self.classForCoder()) //先找到最外层Bundle
        guard let resrouseURL = bundleB.url(forResource: "NicooPlayer", withExtension: "bundle") else { return nil }
        let bundle = Bundle(url: resrouseURL) // 根据URL找到自己的Bundle
        return UIImage(named: imageName, in: bundle , compatibleWith: nil) //在自己的Bundle中找图片
    }
    
}
public struct  NicooVideoModel {
    public var videoName: String?
    public var videoUrl: String?
    public var videoPlaySinceTime: Float = 0
}

public extension UIDevice {
    public func isiPhoneX() -> Bool {
        if UIScreen.main.bounds.height == 812 {
            return true
        }
        return false
    }
}
