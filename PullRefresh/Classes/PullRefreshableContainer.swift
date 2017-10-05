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
    
    private let refreshView: RefreshViewType
    private var scrollViewInsets: UIEdgeInsets = .zero
    private let refreshAction: (() -> Void)?
    
    private var observation: NSKeyValueObservation?
    
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
    
    init(frame: CGRect, refreshView: RefreshViewType, refreshAction: (() -> Void)? = nil) {
        
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
        if let scrollView = newSuperview as? UIScrollView {
            scrollViewInsets = scrollView.contentInset
            scrollView.contentOffset.y = -scrollViewInsets.top

            observation = scrollView.observe(\.contentOffset) { [weak self] (scrollView, changed) in
                self?.observeChanged(scrollView: scrollView)
            }
        }
    }
    
    deinit {
        print("\(self) deinit")
    }
    
    private func observeChanged(scrollView: UIScrollView) {
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

extension PullRefreshableContainer {
    
    private func startAnimation() {
        
        guard let scrollView = superview as? UIScrollView else { return }
        
        isHidden = false
        
        refreshView.startRefreshAnimation()
        
        var insets = scrollViewInsets
        insets.top += frame.size.height
        
        UIView.animate(withDuration: 0.3, animations: {
            scrollView.contentInset = insets
        }, completion: { _ in
            self.refreshAction?()
        })
    }
    
    private func stopAnimation() {
        
        guard let scrollView = superview as? UIScrollView else { return }
        
        refreshView.stopRefreshAnimation()
        
        UIView.animate(withDuration: 0.3, animations: {
            scrollView.contentInset = self.scrollViewInsets
        }, completion: { _ in
            self.isHidden = true
        })
    }
}


