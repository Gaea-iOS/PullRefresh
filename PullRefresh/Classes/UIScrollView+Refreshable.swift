//
//  UIScrollView+Refreshable.swift
//  Refresh
//
//  Created by 王小涛 on 2016/12/17.
//  Copyright © 2016年 王小涛. All rights reserved.
//

import UIKit

public extension UIScrollView {

    var pullRefreshControl: RefreshControlType? {
        get {
            return pullRefreshableContainer?.refreshControl
        }
        set {
            if let newValue = newValue {
                addPullRefreshControl(refreshControl: newValue)
            } else {
                removePullRefreshControl()
            }
        }
    }

    func startPullRefresh() {
        pullRefreshableContainer?.state = .refreshing
    }
    
    func stopPullRefresh() {
        pullRefreshableContainer?.state = .stoped
    }

    private func addPullRefreshControl(refreshControl: RefreshControlType) {
        if pullRefreshableContainer == nil {
            let height: CGFloat = 60
            let frame = CGRect(x: 0, y: -height, width: self.frame.width, height: height)
            pullRefreshableContainer = PullRefreshControlContainer(frame: frame)
            pullRefreshableContainer!.autoresizingMask = [.flexibleWidth]
            insertSubview(pullRefreshableContainer!, at: 0)
        }
        pullRefreshableContainer?.refreshControl = refreshControl
    }

    private func removePullRefreshControl() {
        if pullRefreshableContainer != nil {
            pullRefreshableContainer?.state = .stoped
            pullRefreshableContainer?.removeFromSuperview()
            pullRefreshableContainer = nil
        }
    }

    @available(*, deprecated, message: "Use scrollView.pullRefreshControl instead of scrollView.addPullRefresh")
    func addPullRefresh(refreshControl: RefreshControlType = PullToRefreshControl(), refreshAction: (() -> ())? = nil) {
        pullRefreshControl = refreshControl
        pullRefreshControl?.refreshAction = refreshAction
    }

    @available(*, deprecated, message: "Use scrollView.pullRefreshControl instead of scrollView.removePullRefresh")
    func removePullRefresh() {
        pullRefreshControl = nil
    }
}

public extension UIScrollView {

    var pushRefreshControl: RefreshControlType? {
        get {
            return pushRefreshableContainer?.refreshControl
        }
        set {
            if let newValue = newValue {
                addPushRefreshControl(refreshControl: newValue)
            } else {
                removePushRefreshControl()
            }
        }
    }
    
    func stopPushRefresh() {
        pushRefreshableContainer?.state = .stoped
    }

    private func addPushRefreshControl(refreshControl: RefreshControlType) {
        if pushRefreshableContainer == nil {
            let height: CGFloat = 60
            let frame = CGRect(x: 0, y: 0, width: self.frame.width, height: height)
            pushRefreshableContainer = PushRefreshControlContainer(frame: frame)
            pushRefreshableContainer!.autoresizingMask = [.flexibleWidth]
            insertSubview(pushRefreshableContainer!, at: 1)
        }
        pushRefreshableContainer?.refreshControl = refreshControl
    }
    
    private func removePushRefreshControl() {
        if pushRefreshableContainer != nil {
            pushRefreshableContainer?.state = .stoped
            pushRefreshableContainer?.removeFromSuperview()
            pushRefreshableContainer = nil
        }
    }

    @available(*, deprecated, message: "Use scrollView.pushRefreshControl instead of scrollView.addPushRefresh")
    func addPushRefresh(refreshControl: RefreshControlType = PushToRefreshControl(), refreshAction: (() -> ())? = nil) {
        pushRefreshControl = refreshControl
        pushRefreshControl?.refreshAction = refreshAction
    }

    @available(*, deprecated, message: "Use scrollView.pushRefreshControl instead of scrollView.removePushRefresh")
    func removePushRefresh() {
        pushRefreshControl = nil
    }
}

private extension UIScrollView {
    
    struct AssociatedObjectKey {
        static var pullRefresh = "pullRefreshKey"
        static var pushRefresh = "pushRefreshKey"
    }
    
    var pullRefreshableContainer: PullRefreshControlContainer? {
        get {
            return objc_getAssociatedObject(self, &AssociatedObjectKey.pullRefresh) as? PullRefreshControlContainer
        }
        set {
            objc_setAssociatedObject(self,
                                     &AssociatedObjectKey.pullRefresh,
                                     newValue,
                                     .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var pushRefreshableContainer: PushRefreshControlContainer? {
        get {
            return objc_getAssociatedObject(self, &AssociatedObjectKey.pushRefresh) as? PushRefreshControlContainer
        }
        set {
            objc_setAssociatedObject(self,
                                     &AssociatedObjectKey.pushRefresh,
                                     newValue,
                                     .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}



