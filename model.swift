//
//  model.swift
//  StockTracker
//
//  Created by Zhaoyuan Deng on 4/16/19.
//  Copyright © 2019 Zhaoyuan Deng. All rights reserved.
//

import Foundation

class model{
    static var isLoading : Bool = false
    static var failed=false
    static var loaded=false
    static var price = 0.0
    static var heatmapdict:[String:(price:Double,change:Double,volume:Double)] =
    [String:(price:Double,change:Double,volume:Double)]()
    static var marketIndex:[String:[String]]=["US":["DJI","NASDAQ:^IXIC"],"CN":["000001.SHH"]]
    static func LoadHeatMapData(){
        getStockJson(symbol: "DJI")
        getStockJson(symbol: "NASDAQ:^IXIC")
        getStockJson(symbol: "000001.SHH")
    }
    static func getSesssionDataTask(){
        let semaphore = DispatchSemaphore(value: 0)
        //->Double  {
        isLoading=true
        var dateprice=[String:String]()
        let urlStr="https://www.alphavantage.co/query?function=TIME_SERIES_Daily&symbol=DJI&apikey=6C2PR5ZBG60H6490"
        let sess=URLSession.shared
        let urls:NSURL=NSURL.init(string: urlStr)!
        let request:URLRequest=NSURLRequest.init(url: urls as URL) as URLRequest
        let group = DispatchGroup()
        group.enter()
        let task = sess.dataTask(with: request){(data, res, error) in
            
            if(error==nil){
                do{
                    let dict = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as AnyObject
                    //print(dict)
                    if let time = dict["Time Series (Daily)"] as? NSDictionary  {
                        for (key, value) in time {
                            if let value = value as? Dictionary<String, String> {
                                if let close = value["4. close"] {
                                    let i = key as! String
                                    dateprice[i]=close
                                    //("\(key) CloseStock-> \(close)")
                                    //price = callback(dateprice: dateprice)
                                }
                            }
                        }
                        
                       // price=callback(dateprice: dateprice)
                        semaphore.signal()
                        group.leave()

                    }
                }catch{
                    print(error.localizedDescription)
                    
                }
            }
        }
        task.resume()
        //_ = semaphore.wait(timeout: DispatchTime.distantFuture)
        let timeout = DispatchTime.now() + .seconds(5)
        
        if semaphore.wait(timeout: timeout) == .timedOut {
            failed=true
            print("failed")
        }else{
            callback(marketName: "DJI",dateprice: dateprice)
        }
        //TODO
        //print("p:"+String(price))
       
    }
    
    static func getStockJson(symbol:String){
        let semaphore = DispatchSemaphore(value: 0)
        var baseUrl="https://www.alphavantage.co/query?function=TIME_SERIES_Daily&symbol="
        let apiKey="&apikey=6C2PR5ZBG60H6490"
        var dateprice=[String:String]()
        
        
        let url = baseUrl+symbol+apiKey
        let urlStr : NSString = url.addingPercentEncoding(withAllowedCharacters:.urlQueryAllowed) as! NSString
       // let searchURL : NSURL = NSURL(string: urlStr as String)!
        //print(searchURL)
        
        
        let sess=URLSession.shared
        let urls:NSURL=NSURL.init(string: urlStr as String)!
        let request:URLRequest=NSURLRequest.init(url: urls as URL) as URLRequest
        let group = DispatchGroup()
        group.enter()
        let task = sess.dataTask(with: request){(data, res, error) in
            
            if(error==nil){
                do{
                    let dict = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as AnyObject
                    //print(dict)
                    if let time = dict["Time Series (Daily)"] as? NSDictionary  {
                        for (key, value) in time {
                            if let value = value as? Dictionary<String, String> {
                                if let close = value["4. close"] {
                                    let i = key as! String
                                    dateprice[i]=close
                                    //("\(key) CloseStock-> \(close)")
                                    //price = callback(dateprice: dateprice)
                                }
                            }
                        }
                        
                        // price=callback(dateprice: dateprice)
                        semaphore.signal()
                        group.leave()
                        
                    }
                }catch{
                    print(error.localizedDescription)
                    
                }
            }
        }
        task.resume()
        //var price=0.0
        
        let timeout = DispatchTime.now() + .seconds(5)
        
        if semaphore.wait(timeout: timeout) == .timedOut {
            failed=true
            print("failed")
        }else{
            callback(marketName:symbol,dateprice: dateprice)
        }
        
        //TODO
        //print("p:"+String(price))
        
    }
   
    static func callback(marketName:String,dateprice:[String:String]){
        //->Double{
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        
        let sortedArray = dateprice
            //First map to an array tuples: [(Date, [String:Int]]
            .map{(df.date(from: $0.key)!, [$0.key:$0.value])}
            
            //Now sort by the dates, using `<` since dates are Comparable.
            .sorted{$0.0 < $1.0}
            
            //And re-map to discard the Date objects
            //.map{$1}
        //print(sortedArray)
    let lastdayprice=sortedArray[sortedArray.count-1].1.first?.value
    let lastwodayprice=sortedArray[sortedArray.count-2].1.first?.value
    let change=Double(lastdayprice!)!-Double(lastwodayprice!)!
        let percentage=change/Double(lastdayprice!)!*100
    print("cb:"+String(change))
    isLoading=false
        if(marketName=="NASDAQ:^IXIC"){
            loaded=true
        }
    price=change
    heatmapdict[marketName]=(change,percentage,0.0)
    print(heatmapdict)
   // var change=Double(sortedArray[sortedArray.count].1.values.lazy())-Double(sortedArray[sortedArray.count-1].1.values[0])
        //return sortedArrayOfDicts.last
    }
}
