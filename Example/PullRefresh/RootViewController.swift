//
//  RootViewController.swift
//  PullRefresh_Example
//
//  Created by Garen on 2017/11/20.
//  Copyright © 2017年 CocoaPods. All rights reserved.
//

import UIKit

class RootViewController: UIViewController {
	
	@IBAction func push(_ sender: Any) {
		
		let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
		let ctr = storyboard.instantiateViewController(withIdentifier: "ViewController") as! ViewController
		navigationController?.pushViewController(ctr, animated: true)
		
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
