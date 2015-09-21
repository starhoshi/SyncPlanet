//
//  DateFormatter.swift
//  SyncPlanet
//
//  Created by Kensuke Hoshikawa on 2015/07/12.
//  Copyright (c) 2015年 star__hoshi. All rights reserved.
//

import Foundation

class DateFormatter{

    func format(date : NSDate, style : String) -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "ja_JP")
        dateFormatter.dateFormat = style
        return  dateFormatter.stringFromDate(date)
    }

    func string2date(date:String) -> NSDate{
        let date_formatter: NSDateFormatter = NSDateFormatter()
        date_formatter.locale     = NSLocale(localeIdentifier: "ja")
        date_formatter.dateFormat = "yyyyMMddHHmm"
        return date_formatter.dateFromString(date)!
    }

}