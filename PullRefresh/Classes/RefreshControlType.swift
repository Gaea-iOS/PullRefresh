//
//  RefreshControlType.swift
//  Refresh
//
//  Created by 王小涛 on 2016/12/17.
//  Copyright © 2016年 王小涛. All rights reserved.
//

import UIKit

public protocol RefreshControlType: UIView {
    
    var refreshView: UIView { get}

    func pulling(progress: CGFloat)
    
    func startRefreshAnimation()
    
    func stopRefreshAnimation()

    var refreshAction: (() -> ())? { get set }
}

public extension RefreshControlType where Self: UIView {

    var refreshView: UIView {
        return self
    }
}
