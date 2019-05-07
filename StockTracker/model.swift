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
    static var valueArr=[Double]()
    static var failed=false
    static var loaded=false
    static var price = 0.0
    static var stockdict=[String:[Double]]()
    static var stockdatedict=[String:[String]]()
    static var heatmapdict:[String:(price:Double,change:Double,pchange:String,volume:Double)] =
        [String:(price:Double,change:Double,pchange:String,volume:Double)]()
    static var marketIndex:[String:[String]]=["US":["^DJI","NASDAQ:^IXIC"],"CN":["000001.SHH","399001.SHZ"],"IN":["^BSESN"],"JP":["^N225"],"GB":["^FTSE"],"BR":["^BVSP"],"AU":["^XJO"],"CA":["^GSPTSE"],"DE":["^DAX"]]
    static var indexArr=["^DJI","NASDAQ:^IXIC","000001.SHH","399001.SHZ","^BSESN","^N225","^FTSE","^BVSP","^XJO","^GSPTSE","^DAX"]
    static var supportedCountry=["US","CN","IN","JP","GB","BR","AU","CA","DE"]
    static var countryFullName=["US":"United States","CN":"China","IN":"India","JP":"Japan","GB":"United Kingdom","BR":"Brazil","AU":"Autralia","CA":"Candana","DE":"German"]
    static var stockFullName=["^DJI":"Dow 30"]
    static func LoadHeatMapData(){
       getStockJson(symbol: "AAPL")
       // getStockJson(symbol: "NASDAQ:^IXIC")
       // getStockJson(symbol: "000001.SHH")
        
    }
    static func getSesssionDataTask(){
        let semaphore = DispatchSemaphore(value: 0)
        //->Double  {
        isLoading=true
        var dateprice=[String:String]()
        let urlStr="https://www.alphavantage.co/query?function=TIME_SERIES_Daily&symbol=DJI&apikey=2VBS7C3YUNCMDA0M"
        let sess=URLSession.shared
        let urls:NSURL=NSURL.init(string: urlStr)!
        let request:URLRequest=NSURLRequest.init(url: urls as URL) as URLRequest
        let group = DispatchGroup()
        group.enter()
        let task = sess.dataTask(with: request){(data, res, error) in
            
            if(error==nil){
                do{
                    let dict = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as AnyObject
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
        let apiKey="&apikey=2VBS7C3YUNCMDA0M"
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
        valueArr.removeAll()
    let lastdayprice=sortedArray[sortedArray.count-1].1.first?.value
    let lastwodayprice=sortedArray[sortedArray.count-2].1.first?.value
    let change=Double(lastdayprice!)!-Double(lastwodayprice!)!
        let percentage=change/Double(lastdayprice!)!*100
   
        var dateArr=[String]()
        for data in sortedArray{
            if let date=data.1.first?.key{
                if let value=data.1.first?.value{
                    valueArr.append(Double(value)!)
                    dateArr.append(date)
                }
            }
        }
        stockdict[marketName]=valueArr
        stockdatedict[marketName]=dateArr
        print(dateArr)
        


    price=change
    //heatmapdict[marketName]=(0.0,change,String(percentage),0.0)
    //print(heatmapdict)
   // var change=Double(sortedArray[sortedArray.count].1.values.lazy())-Double(sortedArray[sortedArray.count-1].1.values[0])
        //return sortedArrayOfDicts.last
    }
    
    static func getStockJson2WCH(symbol:String,completionHandler:@escaping (_ success:Bool) -> Void){
        let semaphore = DispatchSemaphore(value: 0)
        var baseUrl="https://www.alphavantage.co/query?function=TIME_SERIES_Daily&symbol="
        let apiKey="&apikey=2VBS7C3YUNCMDA0M"
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
                    callback(marketName: symbol, dateprice: dateprice)
                    completionHandler(true)
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
           // callback(marketName:symbol,dateprice: dateprice)
        }
        
        //TODO
        //print("p:"+String(price))
        
    }
    
    
    static func getStockIndexInfo(symbol:String,completionHandler:@escaping (_ success:Bool) -> Void){
        let semaphore = DispatchSemaphore(value: 0)
        var baseUrl="https://www.alphavantage.co/query?function=GLOBAL_QUOTE&symbol="
        let apiKey="&apikey=2VBS7C3YUNCMDA0M"
        var dateprice=[String:String]()
        let url = baseUrl+symbol+apiKey
        let urlStr : NSString = url.addingPercentEncoding(withAllowedCharacters:.urlQueryAllowed) as! NSString
        let sess=URLSession.shared
        let urls:NSURL=NSURL.init(string: urlStr as String)!
        let request:URLRequest=NSURLRequest.init(url: urls as URL) as URLRequest
        let group = DispatchGroup()
        group.enter()
        let task = sess.dataTask(with: request){(data, res, error) in
            if(error==nil){
                do{
                    let dict = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as AnyObject
                    if let info = dict["Global Quote"] as? Dictionary<String, String>  {
                        print(info)
                                if let price = info["05. price"] {
                                    if let change = info["09. change"] {
                                        if let pchange = info["10. change percent"]{
                                            heatmapdict[symbol]=(Double(price),Double(change),pchange,0.0) as? (price: Double, change: Double, pchange: String, volume: Double)
                                            print(price)
                                        }
                                    }
                                }
                               
                               
                                
                                    //("\(key) CloseStock-> \(close)")
                                    //price = callback(dateprice: dateprice)
                                
                            }
                        
                        // price=callback(dateprice: dateprice)
                        semaphore.signal()
                        group.leave()
                        
                    
                    //callback(marketName: symbol, dateprice: dateprice)
                    completionHandler(true)
                }catch{
                    print(error.localizedDescription)
                    
                }
            }
        }
        task.resume()
        //var price=0.0
        
        let timeout = DispatchTime.now() + .seconds(5)
        
        //if semaphore.wait(timeout: timeout) == .timedOut {
            //failed=true
          //  print("failed")
        //}else{
            // callback(marketName:symbol,dateprice: dateprice)
        //}
        
        //TODO
        //print("p:"+String(price))
        
    }
}
