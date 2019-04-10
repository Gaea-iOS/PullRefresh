//
//  PushRefreshControlContainer.swift
//  Gaea-Example
//
//  Created by 王小涛 on 2016/12/18.
//  Copyright © 2016年 王小涛. All rights reserved.
//

import UIKit

class PushRefreshControlContainer: UIView {

    enum PullToRefreshState {
        case pulling
        case triggered
        case refreshing
        case stoped
    }

    private var scrollViewInsetsBottom: CGFloat = 0.0

    private var observation1: NSKeyValueObservation?
    private var observation2: NSKeyValueObservation?

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

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        isHidden = true
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        refreshControl?.refreshView.frame = bounds
    }

    override func willMove(toSuperview newSuperview: UIView?) {

        if let scrollView = newSuperview as? UIScrollView {

            scrollViewInsetsBottom = scrollView.contentInset.bottom + bounds.height
            scrollView.contentInset.bottom = scrollViewInsetsBottom
            scrollView.contentOffset.y = -scrollView.contentInset.top

            observation1 = scrollView.observe(\UIScrollView.contentOffset) { [weak self] _,_ in
                self?.observeChanged()
            }
            observation2 = scrollView.observe(\UIScrollView.contentOffset) { [weak self] _,_ in
                self?.observeChanged()
            }
        }
    }

    open override func removeFromSuperview() {
        if let scrollView = superview as? UIScrollView {
            var contentInset = scrollView.contentInset
            contentInset.bottom -= bounds.height
            scrollView.contentInset = contentInset
        }
        super.removeFromSuperview()
    }

    private func observeChanged() {

        guard state != .refreshing else { return }
        guard let scrollView = superview as? UIScrollView else { return }


        let scrollViewContentInset: UIEdgeInsets = {
            if #available(iOS 11, *) {
                return scrollView.adjustedContentInset
            } else {
                return scrollView.contentInset
            }
        }()

        guard scrollView.contentOffset.y + scrollViewContentInset.top > 0 else { return }

        frame.origin.y = max(scrollView.contentSize.height, scrollView.bounds.height - scrollViewContentInset.top - scrollViewContentInset.bottom)

        let progress = (scrollView.contentOffset.y + scrollView.bounds.height - scrollViewContentInset.bottom - frame.origin.y + bounds.height) / bounds.height

        guard progress > 0 else {
            isHidden =  true
            return
        }

        isHidden = false

        if scrollView.isDragging {
            refreshControl?.pulling(progress: progress)
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

private extension PushRefreshControlContainer {

    func startAnimation() {

        guard let scrollView = superview as? UIScrollView else { return }

        refreshControl?.startRefreshAnimation()

        UIView.animate(withDuration: 0.3, animations: {
            scrollView.contentInset.bottom = self.scrollViewInsetsBottom
        }, completion: { _ in
            self.refreshControl?.refreshAction?()
        })
    }

    func stopAnimation() {

        guard let scrollView = superview as? UIScrollView else { return }


        refreshControl?.stopRefreshAnimation()

        UIView.animate(withDuration: 0.3, animations: {
            scrollView.contentInset.bottom = self.scrollViewInsetsBottom
        }, completion: { _ in
            self.isHidden = true
        })
    }
}
