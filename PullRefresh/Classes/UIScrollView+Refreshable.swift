//
//  UIScrollView+Refreshable.swift
//  Refresh
//
//  Created by 王小涛 on 2016/12/17.
//  Copyright © 2016年 王小涛. All rights reserved.
//

import UIKit

public extension UIScrollView {
    
    public func addPullRefresh(refreshView: RefreshViewType = PullToRefreshView(), refreshAction: (() -> Void)? = nil) {
        
        if pullRefreshableContainer == nil {
            let height: CGFloat = 60
            let frame = CGRect(x: 0, y: -height, width: self.frame.size.width, height: height)
            pullRefreshableContainer = PullRefreshableContainer(frame: frame, refreshView: refreshView, refreshAction: refreshAction)
            pullRefreshableContainer!.autoresizingMask = [.flexibleWidth]
            insertSubview(pullRefreshableContainer!, at: 0)
        }
    }
    
    public func startPullRefresh() {
        pullRefreshableContainer?.state = .refreshing
    }
    
    public func stopPullRefresh() {
        pullRefreshableContainer?.state = .stoped
    }
    
    public func removePullRefresh() {
        if pullRefreshableContainer != nil {
            pullRefreshableContainer?.state = .stoped
            pullRefreshableContainer?.removeFromSuperview()
            pullRefreshableContainer = nil
        }
    }
}

public extension UIScrollView {
    
    public func addPushRefresh(refreshView: RefreshViewType = PushToRefreshView(), refreshAction: (() -> Void)? = nil) {
        
        if pushRefreshableContainer == nil {
            let height: CGFloat = 60
            let frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: height)
            pushRefreshableContainer = PushRefreshableContainer(frame: frame, refreshView: refreshView, refreshAction: refreshAction)
            pushRefreshableContainer!.autoresizingMask = [.flexibleWidth]
            insertSubview(pushRefreshableContainer!, at: 1)
        }
    }
        
    public func stopPushRefresh() {
        pushRefreshableContainer?.state = .stoped
    }
    
    public func removePushRefresh() {
        if pushRefreshableContainer != nil {
            pushRefreshableContainer?.state = .stoped
            pushRefreshableContainer?.removeFromSuperview()
            pushRefreshableContainer = nil
        }
    }
}

private extension UIScrollView {
    
    struct AssociatedObjectKey {
        static var pullRefresh = "pullRefreshKey"
        static var pushRefresh = "pushRefreshKey"
    }
    
    var pullRefreshableContainer: PullRefreshableContainer? {
        get {
            return objc_getAssociatedObject(self, &AssociatedObjectKey.pullRefresh) as? PullRefreshableContainer
        }
        set {
            objc_setAssociatedObject(self,
                                     &AssociatedObjectKey.pullRefresh,
                                     newValue,
                                     .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var pushRefreshableContainer: PushRefreshableContainer? {
        get {
            return objc_getAssociatedObject(self, &AssociatedObjectKey.pushRefresh) as? PushRefreshableContainer
        }
        set {
            objc_setAssociatedObject(self,
                                     &AssociatedObjectKey.pushRefresh,
                                     newValue,
                                     .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}



