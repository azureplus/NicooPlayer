//
//  NicooImgManager.swift
//  NicooPlayer
//
//  Created by 小星星 on 2018/6/19.
//

import UIKit

class NicooImgManager: UIView {
    class func foundImage(imageName:String) -> UIImage{
        
        let bundleB  = Bundle(for: self.classForCoder()) //先找到最外层Bundle
        let resrouseURL = bundleB.url(forResource: "NicooPlayer", withExtension: "bundle")
        let bundle = Bundle(url: resrouseURL!) // 根据URL找到自己的Bundle
        let image = UIImage.init(named: imageName, in: bundle , compatibleWith: nil) //在自己的Bundle中找图片
        return image!
    }
    
}
public struct  NicooVideoModel {
    public var videoName: String?
    public var videoUrl: String?
    public var videoPlaySinceTime: Float = 0
}


