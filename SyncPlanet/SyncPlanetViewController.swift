//
//  SyncPlanetViewController.swift
//  SyncPlanet
//
//  Created by Kensuke Hoshikawa on 2015/07/04.
//  Copyright (c) 2015年 star__hoshi. All rights reserved.
//

import UIKit

class SyncPlanetViewController: UIViewController {
    
    @IBOutlet weak var loginWebView: UIWebView!
    @IBOutlet weak var loading: UIActivityIndicatorView!
    
    let LOGIN_URL = "https://www.healthplanet.jp/oauth/auth?client_id=117.RuHEus8H6m.apps.healthplanet.jp&redirect_uri=https://www.healthplanet.jp/success.html&scope=innerscan,pedometer,sphygmomanometer&response_type=code"
    let LOGIN_ERROR_URL = "https://www.healthplanet.jp/login_oauth.do"
    let REDIRECT_URL = "https://www.healthplanet.jp/success.html"
    let APPOROVAL_URL = "https://www.healthplanet.jp/oauth/approval.do"
    var errorOccured = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let url: NSURL = NSURL(string: LOGIN_URL)!
        let request: NSURLRequest = NSURLRequest(URL: url)
        loginWebView.loadRequest(request)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func webViewDidStartLoad(webView: UIWebView) {
        loading.startAnimating()
        if let currentUrl = webView.request?.URL!.absoluteString {
            print("pre:"+currentUrl)
            if !checkUrl(currentUrl){
                invalidOperationMessage()
            }
        }
    }
    
    
    // Pageがすべて読み込み終わった時呼ばれる
    func webViewDidFinishLoad(webView: UIWebView) {
        // 読み込み中の場合は処理を行わない
        if(webView.loading){
            return
        }
        loading.stopAnimating()
        if let currentUrl = webView.request?.URL!.absoluteString {
            if currentUrl == APPOROVAL_URL {
                Tanita(webView: webView).isFetchToken(){ (error) in
                    if error == nil {
                        print("true")
                        self.moveNextWindow()
                    } else {
                        self.showNotCompleteAlert()
                    }
                }
            }
        }
    }
    
    func checkUrl(url:String) -> Bool{
        switch(url){
        case "":
            return true
        case LOGIN_URL:
            return true
        case LOGIN_ERROR_URL:
            return true
        case REDIRECT_URL:
            return true
        case APPOROVAL_URL:
            return true
        default:
            return false
        }
        
    }
    
    func moveNextWindow(){
        showCompleteAlert()
    }
    
    /**
    認証完了してtokenを取得した後にAlertを表示し、画面遷移する。
    */
    func showCompleteAlert(){
        let myAlert: UIAlertController = UIAlertController(title: "ログイン完了", message: "SyncPlanetの登録が完了しました。\n\n Syncボタンを押すと、初回のみヘルスケアアプリとの連携に必要な許可を求められますので、必要に応じて許可をお願いします。", preferredStyle: .Alert)
        let myOkAction = UIAlertAction(title: "OK", style: .Default) { action in
            print("Action OK!!")
            let targetView: AnyObject = self.storyboard!.instantiateViewControllerWithIdentifier( "Sync2HealthKit" )
            self.presentViewController( targetView as! UIViewController, animated: true, completion: nil)
        }
        myAlert.addAction(myOkAction)
        presentViewController(myAlert, animated: true, completion: nil)
    }
    
    /**
    認証中にエラーが発生した場合のAlertを出し、再度ロードする
    */
    func showNotCompleteAlert(){
        let myAlert: UIAlertController = UIAlertController(title: "エラー", message: "エラーが発生しました。\nもう一度認証をお願いします。", preferredStyle: .Alert)
        let myOkAction = UIAlertAction(title: "OK", style: .Default) { action in
            let url: NSURL = NSURL(string: self.LOGIN_URL)!
            let request: NSURLRequest = NSURLRequest(URL: url)
            self.loginWebView.loadRequest(request)
        }
        myAlert.addAction(myOkAction)
        presentViewController(myAlert, animated: true, completion: nil)
    }
    
    func invalidOperationMessage(){
        print(errorOccured)
        if(errorOccured){
            errorOccured = !errorOccured
            return
        }else{
            errorOccured = !errorOccured
        }
        let myAlert: UIAlertController = UIAlertController(title: "ログインエラー", message: "HealthPlanetへ登録していない方、ID/PASSWORDをお忘れの方はHealthPlanetでお手続き下さい。\n\nHealthPlanetを開きますか？", preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "OK", style: .Default) {
            action in NSLog("OK！")
            let loginUrl: NSURL = NSURL(string: self.LOGIN_URL)!
            let request: NSURLRequest = NSURLRequest(URL: loginUrl)
            self.loginWebView.loadRequest(request)
            
            let url = NSURL(string: "https://www.healthplanet.jp")
            if UIApplication.sharedApplication().canOpenURL(url!){
                UIApplication.sharedApplication().openURL(url!)
            }
        }
        
        let cancelAction = UIAlertAction(title: "いいえ", style: .Cancel) {
            action in NSLog("Cancel！")
            let loginUrl: NSURL = NSURL(string: self.LOGIN_URL)!
            let request: NSURLRequest = NSURLRequest(URL: loginUrl)
            self.loginWebView.loadRequest(request)
        }
        
        myAlert.addAction(okAction)
        myAlert.addAction(cancelAction)
        presentViewController(myAlert, animated: true, completion: nil)
        
    }
    
}
