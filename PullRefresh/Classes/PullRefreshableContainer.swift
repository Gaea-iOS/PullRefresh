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
    private var originScrollViewInsetsTop: CGFloat = 0.0
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
        super.willMove(toSuperview: newSuperview)
        if let scrollView = newSuperview as? UIScrollView {
            originScrollViewInsetsTop = scrollView.contentInset.top
            scrollView.contentOffset.y = -scrollView.contentInset.top

//            scrollView.addObserver(self, forKeyPath: "contentOffset", options: .new, context: nil)
            observation = scrollView.observe(\UIScrollView.contentOffset) { [weak self] _,_ in
                self?.observeChanged()
            }
        }
    }
	
//    private func unregist() {
//        superview?.removeObserver(self, forKeyPath: "contentOffset")
//    }

//    override func removeFromSuperview() {
//        unregist()
//        super.removeFromSuperview()
//    }

    deinit {
//        unregist()
        print("\(self) deinit")
    }
	
//    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
//        if keyPath == "contentOffset" {
//            observeChanged()
//        }
//    }
    
    private func observeChanged() {
        guard state != .refreshing else { return }
		guard let scrollView = superview as? UIScrollView else { return }

        let progress: CGFloat = {
            if #available(iOS 11, *) {
                return (scrollView.contentOffset.y + scrollView.adjustedContentInset.top) / frame.size.height
            } else {
                return (scrollView.contentOffset.y + scrollView.contentInset.top) / frame.size.height
            }
        }()

        
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
    
    fileprivate func startAnimation() {
        
        guard let scrollView = superview as? UIScrollView else { return }
        
        isHidden = false
        
        refreshView.startRefreshAnimation()

        UIView.animate(withDuration: 0.3, animations: {
            scrollView.contentInset.top = self.originScrollViewInsetsTop + self.frame.size.height
        }, completion: { _ in
            self.refreshAction?()
        })
    }
    
    fileprivate func stopAnimation() {
        
        guard let scrollView = superview as? UIScrollView else { return }
        
        refreshView.stopRefreshAnimation()
        
        UIView.animate(withDuration: 0.3, animations: {
            scrollView.contentInset.top = self.originScrollViewInsetsTop
        }, completion: { _ in
            self.isHidden = true
        })
    }
}
