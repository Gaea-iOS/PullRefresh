//
//  PullRefreshableContainer.swift
//  Refresh
//
//  Created by 王小涛 on 2016/12/17.
//  Copyright © 2016年 王小涛. All rights reserved.
//

import UIKit

class PullRefreshControlContainer: UIView {

    enum PullToRefreshState {
        case pulling
        case triggered
        case refreshing
        case stoped
    }

    private var originScrollViewInsetsTop: CGFloat = 0.0

    private var observation: NSKeyValueObservation?

    var refreshControl: RefreshControlType? {
        didSet {
            oldValue?.removeFromSuperview()
            if let newValue = refreshControl {
                addSubview(newValue.refreshView)
            }
            setNeedsLayout()
            layoutIfNeeded()
        }
    }

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

    override init(frame: CGRect) {
        super.init(frame: frame)
        isHidden = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        refreshControl?.refreshView.frame = bounds
    }

    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        if let scrollView = newSuperview as? UIScrollView {
            originScrollViewInsetsTop = scrollView.contentInset.top
            scrollView.contentOffset.y = -scrollView.contentInset.top

            observation = scrollView.observe(\UIScrollView.contentOffset) { [weak self] _,_ in
                self?.observeChanged()
            }
        }
    }

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

        guard progress < 0 else {
            if state == .pulling {
                isHidden = true
            }
            return
        }

        isHidden = false

        if scrollView.isDragging {
            refreshControl?.pulling(progress: -progress)
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

private extension PullRefreshControlContainer {

    func startAnimation() {

        guard let scrollView = superview as? UIScrollView else { return }

        isHidden = false

        refreshControl?.startRefreshAnimation()

        UIView.animate(withDuration: 0.3, animations: {
            scrollView.contentInset.top = self.originScrollViewInsetsTop + self.frame.size.height
        }, completion: { _ in
            self.refreshControl?.refreshAction?()
        })
    }

    func stopAnimation() {

        guard let scrollView = superview as? UIScrollView else { return }

        refreshControl?.stopRefreshAnimation()

        UIView.animate(withDuration: 0.3, animations: {
            scrollView.contentInset.top = self.originScrollViewInsetsTop
        }, completion: { _ in
            self.isHidden = true
        })
    }
}

