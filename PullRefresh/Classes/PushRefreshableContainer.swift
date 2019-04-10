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

    private let refreshView: RefreshViewType
    private var scrollViewInsetsBottom: CGFloat = 0.0
    private let refreshAction: (() -> Void)?

        private var observation1: NSKeyValueObservation?
        private var observation2: NSKeyValueObservation?

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

            scrollViewInsetsBottom = scrollView.contentInset.bottom + bounds.height
            scrollView.contentInset.bottom = scrollViewInsetsBottom
            scrollView.contentOffset.y = -scrollView.contentInset.top

//            scrollView.addObserver(self, forKeyPath: "contentOffset", options: .new, context: nil)
            observation1 = scrollView.observe(\UIScrollView.contentOffset) { [weak self] _,_ in
                self?.observeChanged()
            }
//            scrollView.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
            observation2 = scrollView.observe(\UIScrollView.contentOffset) { [weak self] _,_ in
                self?.observeChanged()
            }
        }
    }

//    private func unregist() {
//        superview?.removeObserver(self, forKeyPath: "contentOffset")
//        superview?.removeObserver(self, forKeyPath: "contentSize")
//    }

    open override func removeFromSuperview() {
//        unregist()
        if let scrollView = superview as? UIScrollView {
            var contentInset = scrollView.contentInset
            contentInset.bottom -= bounds.height
            scrollView.contentInset = contentInset
        }
        super.removeFromSuperview()
    }

    deinit {
//        unregist()
        print("\(self) deinit")
    }

//    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
//        if keyPath == "contentOffset" || keyPath == "contentSize" {
//            observeChanged()
//        }
//    }

    private func observeChanged() {

        guard state != .refreshing else { return }
        guard let scrollView = superview as? UIScrollView else { return }

        guard scrollView.contentOffset.y + scrollView.contentInset.top > 0 else { return }

        let progress: CGFloat = {
            if #available(iOS 11, *) {
                frame.origin.y = max(scrollView.contentSize.height, scrollView.bounds.size.height - scrollView.adjustedContentInset.top - scrollView.adjustedContentInset.bottom)
                return (scrollView.contentOffset.y + scrollView.frame.size.height - scrollView.adjustedContentInset.bottom - frame.origin.y + bounds.height) / frame.size.height
            } else {
                frame.origin.y = max(scrollView.contentSize.height, scrollView.bounds.size.height - scrollView.contentInset.top - scrollView.contentInset.bottom)
                return (scrollView.contentOffset.y + scrollView.frame.size.height - scrollView.contentInset.bottom - frame.origin.y + bounds.height) / frame.size.height
            }
        }()

        //        print("push progress = \(progress)")

        guard progress > 0 else {

            isHidden =  true
            return
        }

        isHidden = false

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

        refreshView.startRefreshAnimation()

        UIView.animate(withDuration: 0.3, animations: {
            scrollView.contentInset.bottom = self.scrollViewInsetsBottom
        }, completion: { _ in
            self.refreshAction?()
        })
    }

    fileprivate func stopAnimation() {

        guard let scrollView = superview as? UIScrollView else { return }


        refreshView.stopRefreshAnimation()

        UIView.animate(withDuration: 0.3, animations: {
            scrollView.contentInset.bottom = self.scrollViewInsetsBottom
        }, completion: { _ in
            self.isHidden = true
        })
    }
}

