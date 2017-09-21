//
//  PullRefreshView.swift
//  Football
//
//  Created by 王小涛 on 2017/7/14.
//  Copyright © 2017年 bet007. All rights reserved.
//

import UIKit
import PullRefresh
import Reusable

class PullRefreshView: UIView, NibLoadable, RefreshViewType {
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var textLabel: UILabel!
    
    public func pulling(progress: CGFloat) {
        textLabel.text = progress < 1 ? "下拉刷新": "释放刷新"
    }
    
    public func startRefreshAnimation() {
        textLabel.text = "加载中..."
        let animation: CABasicAnimation = {
            let animation = CABasicAnimation(keyPath: "transform.rotation.z")
            animation.fromValue = 0
            animation.toValue = Double.pi * 2
            animation.duration = 0.2
            animation.autoreverses = false
            animation.fillMode = kCAFillModeForwards
            animation.repeatCount = .greatestFiniteMagnitude
            return animation
        }()
        iconImageView.layer.add(animation, forKey: nil)
    }
    
    public func stopRefreshAnimation() {
        iconImageView.layer.removeAllAnimations()
    }
}

extension UIScrollView {

    func addPullToRefresh(_ action: @escaping () -> Void) {
        addPullRefresh(refreshView: PullRefreshView.loadFromNib(), refreshAction: action)
    }
}
