//
//  SyncHealth.swift
//  SyncPlanet
//
//  Created by Kensuke Hoshikawa on 2015/07/05.
//  Copyright (c) 2015年 star__hoshi. All rights reserved.
//

import Foundation
import HealthKit
import Alamofire
import SwiftyJSON

class SyncHealth {
    
    let INNERSCAN_URL = "https://www.healthplanet.jp/status/innerscan.json"
    let SPHYGMOMANOMETER_URL = "https://www.healthplanet.jp/status/sphygmomanometer.json"
    let PEDOMETER_URL = "https://www.healthplanet.jp/status/pedometer.json"
    let myHealthStore:HKHealthStore = HKHealthStore()
    let us = NSUserDefaults()
    
    //    func requestAuthorization() -> Bool{
    func requestAuthorization(completionHandler: (Bool) -> ()) -> () {
        let healthKitTypesToWrite : Set = [
            //            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBodyMassIndex),
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBodyFatPercentage)!,
            //            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeight),
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBodyMass)!,
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)!,
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBasalEnergyBurned)!,
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierActiveEnergyBurned)!,
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeartRate)!,
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBloodPressureSystolic)!,
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBloodPressureDiastolic)!,
        ]
        
        // HealthStoreへのアクセス承認をおこなう.
        // readはなし、writeだけ
        myHealthStore.requestAuthorizationToShareTypes(healthKitTypesToWrite, readTypes: nil, completion: {
            (success: Bool, error: NSError?) in
            if success {
                print("Success!")
                completionHandler(true)
            } else {
                print("Error!")
                completionHandler(false)
            }
        })
    }
    
    func fetchInnerscan(completionHandler: (ErrorType?) -> ()) -> () {
        let param = [
            "access_token": NSUserDefaults.standardUserDefaults().stringForKey("access_token")!,
            "date": "0",
            "tag": "6021,6022,6023,6024,6025,6026,6027,6028,6029,6030"
        ]
        fetch(completionHandler, param: param, URL: INNERSCAN_URL)
    }
    
    func fetchSphygmomanometer(completionHandler: (ErrorType?) -> ()) -> () {
        let param = [
            "access_token": NSUserDefaults.standardUserDefaults().stringForKey("access_token")!,
            "date": "0",
            "tag": "622E,622F,6230"
        ]
        fetch(completionHandler, param: param, URL: SPHYGMOMANOMETER_URL)
    }
    
    func fetchPedometer(completionHandler: (ErrorType?) -> ()) -> () {
        let param = [
            "access_token": NSUserDefaults.standardUserDefaults().stringForKey("access_token")!,
            "date": "0",
            "tag": "6331,6335,6336"
        ]
        fetch(completionHandler, param: param, URL: PEDOMETER_URL)
    }

    private func fetch(completionHandler: (ErrorType?) -> (), var param:[String : String], URL:String){
        if let date: AnyObject = NSUserDefaults.standardUserDefaults().objectForKey("updated_at") {
            param["from"] = DateFormatter().format(date as! NSDate,style: "yyyyMMddHHmmss")
        }
        print(param)
        Alamofire.request(.GET, URL, parameters: param)
            .responseJSON { _, _, result in
                switch result {
                case .Success(let data):
                    print(data)
                    var json = JSON(data)
                    for (index, _): (String, JSON) in json["data"] {
                        self.writeData(json["data"][Int(index)!])
                    }
                    completionHandler(nil)
                case .Failure(_, let error):
                    print("Request failed with error: \(error)")
                    completionHandler(error)
                }
        }

    }
    
    private func writeData(json:JSON){
        let keydata = json["keydata"].string!
        let tag = json["tag"].string!
        let date = json["date"].string!
        let double = atof(keydata)
        print(double)
        print(tag)
        
        let type = getQuantityData(tag,keyData: keydata)
        print(type.0)
        
        if let quantity = type.0 {
            
            // 体重のタイプ.
            let typeOfWeight = HKObjectType.quantityTypeForIdentifier(quantity)
            
            // StoreKit保存用データを作成.
            let myWeightData = HKQuantitySample(type: typeOfWeight!, quantity: type.1, startDate: DateFormatter().string2date(date), endDate: DateFormatter().string2date(date))
            
            // データの保存.
            myHealthStore.saveObject(myWeightData, withCompletion: {
                (success: Bool, error: NSError?) in
                if success {
                    NSLog("Success!")
                } else {
                    print("Error!")
                }
            })
        }
        
    }
    
    
    private func getQuantityData(tag:String,keyData:AnyObject) -> (String?,HKQuantity!){
        switch tag{
        case DATA_LISTS.BODY_MASS.rawValue:
            let myWeight = HKQuantity(unit: HKUnit.gramUnit(), doubleValue: keyData.doubleValue * 1000)
            return (HKQuantityTypeIdentifierBodyMass,myWeight)
        case DATA_LISTS.BODY_FAT.rawValue:
            let myFat = HKQuantity(unit: HKUnit.percentUnit(), doubleValue: keyData.doubleValue / 100)
            return (HKQuantityTypeIdentifierBodyFatPercentage,myFat)
            //    case DATA_LISTS.HEIGHT.rawValue:
            //        return HKQuantityTypeIdentifierHeight
        case DATA_LISTS.STEP_COUNT.rawValue:
            let myStep = HKQuantity(unit: HKUnit.countUnit(), doubleValue: keyData.doubleValue)
            return (HKQuantityTypeIdentifierStepCount,myStep)
        case DATA_LISTS.BASE_ENERGY.rawValue:
            let myEnergy = HKQuantity(unit: HKUnit.kilocalorieUnit(), doubleValue: keyData.doubleValue)
            return (HKQuantityTypeIdentifierBasalEnergyBurned,myEnergy)
        case DATA_LISTS.ACTIVE_ENERGY.rawValue:
            let myEnergy = HKQuantity(unit: HKUnit.kilocalorieUnit(), doubleValue: keyData.doubleValue)
            return (HKQuantityTypeIdentifierActiveEnergyBurned,myEnergy)
        case DATA_LISTS.HEAER_RATE.rawValue:
            let myHeartRate = HKQuantity(unit:HKUnit.countUnit().unitMultipliedByUnit(HKUnit.minuteUnit().reciprocalUnit()), doubleValue: keyData.doubleValue)
            return (HKQuantityTypeIdentifierHeartRate,myHeartRate)
            //    case DATA_LISTS.BLOOD_PRESSURE_S.rawValue:
            //        return (HKQuantityTypeIdentifierBloodPressureSystolic
            //    case DATA_LISTS.BLOOD_PRESSURE_D.rawValue:
            //        return (HKQuantityTypeIdentifierBloodPressureDiastolic
        default:
            return (nil,nil)
        }
        
    }
    
}

private enum DATA_LISTS: String {
    case BODY_MASS = "6021"
    case BODY_FAT = "6022"
    case STEP_COUNT = "6331"
    case BASE_ENERGY = "6027"
    case ACTIVE_ENERGY = "6336"
    case HEAER_RATE = "6230"
    case BLOOD_PRESSURE_S = "622E"
    case BLOOD_PRESSURE_D = "622F"
}


