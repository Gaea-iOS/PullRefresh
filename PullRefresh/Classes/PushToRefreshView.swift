//
//  PushToRefreshView.swift
//  Gaea-Example
//
//  Created by 王小涛 on 2016/12/18.
//  Copyright © 2016年 王小涛. All rights reserved.
//

import UIKit

public class PushToRefreshView: UIView, RefreshViewType {
    
    private lazy var backgroudView = UIView()
    
    private lazy var label: UILabel = {
        let view = UILabel()
        view.font = UIFont.systemFont(ofSize: 15)
        view.textColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
        view.textAlignment = .center
        return view
    }()
    
    private lazy var indicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroudView.backgroundColor = UIColor(red: 0.96, green: 0.96, blue: 0.96, alpha: 1)
        addSubview(backgroudView)
        addSubview(label)
        addSubview(indicator)
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        backgroudView.frame = CGRect(x: 0, y: 0, width: bounds.size.width, height: 500 + bounds.size.height)
        label.frame = bounds
        indicator.center = center
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func pulling(progress: CGFloat) {
        label.isHidden = false
        indicator.isHidden = true
        if progress < 1 {
            label.text = "上拉加载更多"
        }else {
            label.text = "松开刷新"
        }
    }
    
    public func startRefreshAnimation() {
        label.isHidden = true
        indicator.isHidden = false
        indicator.startAnimating()
    }
    
    public func stopRefreshAnimation() {
        label.isHidden = true
        indicator.isHidden = true
    }
}


