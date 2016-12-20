//
//  PullRefreshableContainer.swift
//  Refresh
//
//  Created by 王小涛 on 2016/12/17.
//  Copyright © 2016年 王小涛. All rights reserved.
//

import UIKit

class PullRefreshableContainer: UIView {
    
    enum PullToRefreshState {
        case pulling
        case triggered
        case refreshing
        case stoped
    }
    
    fileprivate let contentOffsetKeyPath = "contentOffset"
    fileprivate var kvoContext = "pullToRefreshViewKVOContext"
    
    let refreshView: RefreshViewType
    fileprivate var scrollViewInsets: UIEdgeInsets = .zero
    fileprivate let refreshAction: ((Void) -> Void)?
    
    var state: PullToRefreshState = .stoped {
        didSet {
            guard state != oldValue else { return }
            switch state {
            case .pulling:
                break;
            case .triggered:
                break;
            case .refreshing:
                startAnimation()
            case .stoped:
                stopAnimation()
            }
        }
    }
        
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(frame: CGRect, refreshView: RefreshViewType, refreshAction: ((Void) -> Void)? = nil) {
        
        self.refreshView = refreshView
        self.refreshAction = refreshAction
        
        super.init(frame: frame)
        addSubview(refreshView.refreshView)
        isHidden = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        refreshView.refreshView.frame = bounds
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        unregister()
        if let scrollView = newSuperview as? UIScrollView {
            scrollView.addObserver(self, forKeyPath: contentOffsetKeyPath, options: [.initial, .new], context: &kvoContext)
        }
    }
    
    deinit {
        print("\(self) deinit")
        unregister()
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        guard context == &kvoContext,
            keyPath == contentOffsetKeyPath,
            let scrollView = object as? UIScrollView else {
                super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
                return
        }
        
        guard state != .refreshing else { return }
        
        let progress = (scrollView.contentOffset.y + scrollView.contentInset.top) / frame.size.height
        
//        print("pull progress = \(progress)")
        
        guard progress < 0 else {
            if state == .pulling {
                isHidden = true
            }
            return
        }
        
        isHidden = false
                
        if scrollView.isDragging {
            refreshView.pulling(progress: -progress)
            state = .pulling
        }
        
        guard [.pulling, .triggered].contains(state) else { return }
        
        if -progress >= 1 {
            state = scrollView.isDragging ? .triggered : .refreshing
        }else {
            state = .pulling
        }
    }
}

private extension PullRefreshableContainer {
    
    func unregister() {
        if let scrollView = superview as? UIScrollView {
            scrollView.removeObserver(self, forKeyPath: contentOffsetKeyPath, context: &kvoContext)
        }
    }
    
    func startAnimation() {
        
        guard let scrollView = superview as? UIScrollView else { return }
        
        isHidden = false
        
        refreshView.startRefreshAnimation()
        
        scrollViewInsets = scrollView.contentInset
        var insets = scrollViewInsets
        insets.top += frame.size.height
        
        var contentOffset = scrollView.contentOffset
        contentOffset.y = -scrollViewInsets.top - frame.size.height
        
        UIView.animate(withDuration: 0.5, animations: {
            scrollView.contentInset = insets
            scrollView.setContentOffset(contentOffset, animated: true)
        }, completion: { _ in
            self.refreshAction?()
        })
    }
    
    func stopAnimation() {
        
        guard let scrollView = superview as? UIScrollView else { return }
        
        refreshView.stopRefreshAnimation()
        
        UIView.animate(withDuration: 0.5, animations: {
            scrollView.contentInset = self.scrollViewInsets
        }, completion: { _ in
            self.isHidden = true
        })
    }
}


