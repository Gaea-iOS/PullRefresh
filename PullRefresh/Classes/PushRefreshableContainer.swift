//
//  PushRefreshableContainer.swift
//  Gaea-Example
//
//  Created by 王小涛 on 2016/12/18.
//  Copyright © 2016年 王小涛. All rights reserved.
//

import UIKit

class PushRefreshableContainer: UIView {
    
    enum PullToRefreshState {
        case pulling
        case triggered
        case refreshing
        case stoped
    }
    
    fileprivate let refreshView: RefreshViewType
    fileprivate var scrollViewInsets: UIEdgeInsets = .zero
	fileprivate var originalScrollViewInsets: UIEdgeInsets = .zero
    fileprivate let refreshAction: (() -> Void)?
    
//    private var observation1: NSKeyValueObservation?
//    private var observation2: NSKeyValueObservation?
	
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
    var forceHidden: Bool = false {
        didSet {
            guard let scrollView = superview as? UIScrollView else { return }
            UIView.animate(withDuration: 0.30) {
                if self.forceHidden {
                    scrollView.contentInset = self.originalScrollViewInsets
                } else {
                    scrollView.contentInset = self.scrollViewInsets
                }
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
            
			originalScrollViewInsets = scrollView.contentInset
            scrollViewInsets = scrollView.contentInset
            scrollViewInsets.bottom += bounds.height
            scrollView.contentInset = scrollViewInsets
            scrollView.contentOffset.y = -scrollViewInsets.top
            
//            observation1 = scrollView.observe(\.contentOffset, changeHandler: { [weak self] (scrollView, changed) in
//                self?.observeChanged(scrollView: scrollView)
//            })
//            observation2 = scrollView.observe(\.contentSize, changeHandler: { [weak self] (scrollView, changed) in
//                self?.observeChanged(scrollView: scrollView)
//            })
			
			scrollView.addObserver(self, forKeyPath: "contentOffset", options: .new, context: nil)
			scrollView.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
			
        }
    }
	
	private func unregist() {
		superview?.removeObserver(self, forKeyPath: "contentOffset")
		superview?.removeObserver(self, forKeyPath: "contentSize")
	}
    
    open override func removeFromSuperview() {
		unregist()
        if let scrollView = superview as? UIScrollView {
            var contentInset = scrollView.contentInset
            contentInset.bottom -= bounds.height
            scrollView.contentInset = contentInset
        }
        super.removeFromSuperview()
    }
    
    deinit {
		unregist()
        print("\(self) deinit")
    }
	
	override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
		if keyPath == "contentOffset" || keyPath == "contentSize" {
			observeChanged()
		}
	}
    
    private func observeChanged() {
        
        guard state != .refreshing else { return }
		guard let scrollView = superview as? UIScrollView else { return }
		
        guard scrollView.contentOffset.y + scrollViewInsets.top > 0 else { return }
        
        frame.origin.y = max(scrollView.contentSize.height, scrollView.bounds.size.height - scrollView.contentInset.top - scrollView.contentInset.bottom)
        
        let progress = (scrollView.contentOffset.y + scrollView.frame.size.height - scrollView.contentInset.bottom - frame.origin.y + bounds.height) / frame.size.height
        
        //        print("push progress = \(progress)")
        
        guard progress > 0 else {
            
            isHidden =  true
            return
        }
//        if self.forceHidden {
//            isHidden = true
//        } else {
//            isHidden = false
//        }
        isHidden = self.forceHidden
        
        if scrollView.isDragging {
            refreshView.pulling(progress: progress)
            state = .pulling
        }
        
        guard [.pulling, .triggered].contains(state) else { return }
        
        if progress >= 1 {
            state = scrollView.isDragging ? .triggered : .refreshing
        }else {
            state = .pulling
        }
    }
}

extension PushRefreshableContainer {
    
    fileprivate func startAnimation() {
        
        guard let scrollView = superview as? UIScrollView else { return }
        
        isHidden = self.forceHidden
        
        refreshView.startRefreshAnimation()
        
        let insets = scrollViewInsets
        if !self.forceHidden {
            UIView.animate(withDuration: 0.3, animations: {
                scrollView.contentInset = insets
            }, completion: { _ in
                self.refreshAction?()
            })
        } else {
            scrollView.contentInset = .zero
        }
        
    }
    
    fileprivate func stopAnimation() {
        
        guard let scrollView = superview as? UIScrollView else { return }
        
        refreshView.stopRefreshAnimation()
        if !self.forceHidden {
            UIView.animate(withDuration: 0.3, animations: {
                scrollView.contentInset = self.scrollViewInsets
            }, completion: { _ in
                self.isHidden = true
            })
        } else {
            scrollView.contentInset = .zero
        }
        
    }
}


