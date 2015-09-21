//
//  Tanita.swift
//  SyncPlanet
//
//  Created by Kensuke Hoshikawa on 2015/07/04.
//  Copyright (c) 2015年 star__hoshi. All rights reserved.
//

import Foundation
import HTMLReader
import Alamofire
import SwiftyJSON

class Tanita{
    
    let html:HTMLDocument
    let CLIENT_ID = "117.RuHEus8H6m.apps.healthplanet.jp"
    let CLIENT_SECRET = "1436080917528-4Mua9ZBm8arsP5XN7ExXansvYMEluaPxzr5yLaWf"
    let REDIRECT_URL = "https://www.healthplanet.jp/success.html"
    let GRANT_TYPE = "authorization_code"
    let TOKEN_URL = "https://www.healthplanet.jp/oauth/token"
    let us = NSUserDefaults()
    
    init(webView:UIWebView){
        let js = "document.body.innerHTML"
        let body = webView.stringByEvaluatingJavaScriptFromString(js)
        html = HTMLDocument(string: body!)
    }
    
    func isFetchToken(completionHandler: (ErrorType?) -> ()) -> () {
        if let code = html.firstNodeMatchingSelector("#code") {
            print(code.textContent)
            let param = [
                "code": code.textContent ,
                "client_id": CLIENT_ID,
                "client_secret": CLIENT_SECRET,
                "redirect_uri": REDIRECT_URL,
                "grant_type": GRANT_TYPE
            ]
            
            Alamofire.request(.POST, TOKEN_URL,  parameters: param)
                .responseJSON { _, _, result in
                    switch result {
                    case .Success(let data):
                        var json = JSON(data)
                        print(json)
                        if let refreshToken = json["refresh_token"].string {
                            self.us.setObject(refreshToken, forKey: "refresh_token")
                        }
                        if let expiresIn = json["expires_in"].string {
                            self.us.setObject(expiresIn, forKey: "expires_in")
                        }
                        if let accessToken = json["access_token"].string {
                            self.us.setObject(accessToken, forKey: "access_token")
                        }
                        completionHandler(nil)
                    case .Failure(_, let error):
                        print("Request failed with error: \(error)")
                        completionHandler(error)
                    }
            }
        }
    }
    
}

