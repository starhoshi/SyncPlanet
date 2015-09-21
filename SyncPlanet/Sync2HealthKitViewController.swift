//
//  Sync2HealthKitViewController.swift
//  SyncPlanet
//
//  Created by Kensuke Hoshikawa on 2015/07/05.
//  Copyright (c) 2015年 star__hoshi. All rights reserved.
//

import UIKit

class Sync2HealthKitViewController: UIViewController {
    
    @IBOutlet weak var innerscan: UILabel!
    @IBOutlet weak var sphygmomanometer: UILabel!
    @IBOutlet weak var pedometer: UILabel!
    @IBOutlet weak var syncplanet: UIImageView!
    @IBOutlet weak var update: UILabel!
    @IBOutlet weak var progressBar: UIProgressView!
    var flg = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let date: AnyObject = NSUserDefaults.standardUserDefaults().objectForKey("updated_at") {
            update.text = "Last Update: " + DateFormatter().format(date as! NSDate,style: "yyyy/MM/dd HH:mm:ss")
        }else {
            update.text = "No Sync Info."
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func clickSync(sender: UIButton) {
        self.update.text = "情報取得中…"
        self.innerscan.text = "体組成測定情報: -"
        self.sphygmomanometer.text = "血圧測定情報: -"
        self.pedometer.text = "歩数測定情報: -"
        self.progressBar.hidden = false
        self.progressBar.progress = 0.0
        SyncHealth().requestAuthorization() { (status) in
            if status {
                self.startInnerscan()
            } else {
                self.fetchError("ヘルスケア連携が許可されていません")
            }
        }
    }
    
    func startInnerscan(){
        SyncHealth().fetchInnerscan(){ (error) in
            if error == nil {
                self.completeFetch(TANITA_STATUS.INNER_SCAN)
            } else {
                self.fetchError("エラーが発生しました。もう一度Syncして下さい")
            }
        }
    }
    
    func startSphygmomanometer(){
        SyncHealth().fetchSphygmomanometer(){ (error) in
            if error == nil {
                self.completeFetch(TANITA_STATUS.SPHYGMOMANOMETER)
            } else {
                self.fetchError("エラーが発生しました。もう一度Syncして下さい")
            }
        }
    }
    
    
    func startPedometer(){
        SyncHealth().fetchPedometer(){ (error) in
            if error == nil {
                self.completeFetch(TANITA_STATUS.PEDOMETER)
            } else {
                self.fetchError("エラーが発生しました。もう一度Syncして下さい")
            }
        }
    }
    
    func fetchError(text:String){
        print("false")
        progressBar.hidden = true
        update.text = text
    }
    
    func completeFetch(status: TANITA_STATUS){
        print("complete Fetch")
        switch status{
        case .INNER_SCAN:
            self.innerscan.text = "体組成測定情報: ✔"
            self.progressBar.progress = 1/3
            startSphygmomanometer()
        case .SPHYGMOMANOMETER:
            self.sphygmomanometer.text = "血圧測定情報: ✔"
            self.progressBar.progress = 2/3
            startPedometer()
        case .PEDOMETER:
            self.pedometer.text = "歩数測定情報: ✔"
            self.progressBar.progress = 3/3
            NSUserDefaults.standardUserDefaults().setObject(NSDate(), forKey:"updated_at")
            if let date: AnyObject = NSUserDefaults.standardUserDefaults().objectForKey("updated_at") {
                self.update.text = "Last Update: " + DateFormatter().format(date as! NSDate,style: "yyyy/MM/dd HH:mm:ss")
            }
            self.progressBar.hidden = true
        }
    }
    
    @IBAction func clickSupport(sender: AnyObject) {
        let url = NSURL(string: "https://dl.dropboxusercontent.com/u/43623483/syncplanet/privacypolicy.html")
        if UIApplication.sharedApplication().canOpenURL(url!){
            UIApplication.sharedApplication().openURL(url!)
        }
    }
    
}

enum TANITA_STATUS {
    case INNER_SCAN
    case SPHYGMOMANOMETER
    case PEDOMETER
}