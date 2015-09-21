//
//  AppInfoViewController.swift
//  SyncPlanet
//
//  Created by Kensuke Hoshikawa on 2015/07/20.
//  Copyright (c) 2015年 star__hoshi. All rights reserved.
//

import UIKit
import HealthKit

class AppInfoViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var appTableView: UITableView!
    let healthList = ["体重","体脂肪率"]
    let sectionList = ["ヘルスケア連携"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nib  = UINib(nibName: "HealthTableViewCell", bundle:nil)
        appTableView.registerNib(nib, forCellReuseIdentifier:"HealthTableViewCell")
        appTableView.dataSource = self
        appTableView.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func close(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sectionList.count
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionList[section]
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return healthList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("HealthTableViewCell", forIndexPath: indexPath) as! HealthTableViewCell
        cell.textLabel?.text = "\(healthList[indexPath.row])"
        cell.detailTextLabel?.text = "detail"
        
        return cell
    }

}
