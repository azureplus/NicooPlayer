//
//  NicooPlayerOrietation.swift
//  MBProgressHUD
//
//  Created by 小星星 on 2018/6/27.
//

import UIKit

public enum OrientationSupport: Int {
    case orientationPortrait
    case orientationLeftAndRight
    case orientationAll
    
    public func getOrientSupports() -> UIInterfaceOrientationMask {
        switch self {
        case .orientationPortrait:
            return [.portrait]
        case .orientationLeftAndRight:
            return [.landscapeLeft, .landscapeRight]
        case .orientationAll:
            return [.portrait, .landscapeLeft, .landscapeRight]
        }
    }
}
public var orientationSupport: OrientationSupport = .orientationPortrait

class NicooPlayerOrietation: NSObject {

}
