//
//  ViewController.swift
//  PullRefresh
//
//  Created by wangxiaotao on 12/19/2016.
//  Copyright (c) 2016 wangxiaotao. All rights reserved.
//

import UIKit
import PullRefresh

class ViewController: UITableViewController {

    private var onceToken = UUID().uuidString
    
    private var hadSet: Bool = false
    
    private var _count: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        tableView.tableFooterView = UIView()
        
        automaticallyAdjustsScrollViewInsets = false
        
        tableView.addPullRefresh {
            print("pull refreshing action!!!")
            
            let time = DispatchTime.now() + Double(Int64(1 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: time, execute: {
                self.tableView.stopPullRefresh()
                self._count = 20
                self.tableView.reloadData()
            })
        }
        
        tableView.addPushRefresh {
            print("push refreshing action!!!")
            
            let time = DispatchTime.now() + Double(Int64(2 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: time, execute: {
                self.tableView.stopPushRefresh()
                self._count += 20
                self.tableView.reloadData()
            })
        }
                
        UIView.animate(withDuration: 3, animations: {
            
        }) { _ in
            self.tableView.startPullRefresh()
        }
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if !hadSet {
            hadSet = true
            tableView.contentInset = UIEdgeInsets(top: topLayoutGuide.length, left: 0, bottom: bottomLayoutGuide.length, right: 0)
            tableView.scrollIndicatorInsets = tableView.contentInset
//            tableView.contentOffset.y = -topLayoutGuide.length
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return _count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = String(indexPath.row)
        return cell
    }
    
    @IBAction func clickLeftButton(sender: AnyObject) {
        
        //        tableView.startPullRefresh()
        //        var scrollViewInsets = tableView.contentInset
        //        scrollViewInsets.bottom += 50
        //        UIView.animate(withDuration: 0.5, animations: {
        //            self.tableView.contentInset = scrollViewInsets
        //            self.tableView.contentOffset.y = -14
        //
        //        }, completion: { _ in
        //
        //        })
        //        _count = 30
        //        tableView.reloadData()
        tableView.removePullRefresh()
    }
    
    @IBAction func clickRightButton(sender: AnyObject) {
        //        let contentInset = UIEdgeInsets(top: topLayoutGuide.length, left: 0, bottom: bottomLayoutGuide.length, right: 0)
        //        UIView.animate(withDuration: 0.5, animations: {
        //            self.tableView.contentInset = contentInset
        //        }, completion: { _ in
        //
        //        })
        //        tableView.stopPullRefresh()
        //        _count = 0
        //        tableView.reloadData()
        tableView.removePushRefresh()
    }
}

