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
    static var stockdictFiveMin=[String:[Double]]()
    static var stockdatedictFiveMin=[String:[String]]()
    static var marketDataLoaded=false
    static var stockdictThirtyMin=[String:[Double]]()
    static var stockdatedictThirtyMin=[String:[String]]()
    
    static var stockdict=[String:[Double]]()
    static var stockdatedict=[String:[String]]()
    
    static var stockdictSevenD=[String:[Double]]()
    static var stockdatedictSevenD=[String:[String]]()
    
    static var heatmapdict:[String:(price:Double,change:Double,pchange:String,volume:Double)] =
        [String:(price:Double,change:Double,pchange:String,volume:Double)]()
    static var marketIndex:[String:[String]]=["US":["^DJI","NASDAQ:^IXIC"],"CN":["000001.SHH"],"IN":["^BSESN"],"JP":["^N225"],"GB":["^FTSE"],"BR":["^BVSP"],"AU":["^XJO"],"CA":["^GSPTSE"],"DE":["^DAX"]]
    static var indexArr=["^DJI","NASDAQ:^IXIC","000001.SHH","^BSESN","^N225","^FTSE","^BVSP","^XJO","^GSPTSE","^DAX"]
    static var supportedCountry=["US","CN","IN","JP","GB","BR","AU","CA","DE"]
    static var countryFullName=["US":"United States","CN":"China","IN":"India","JP":"Japan","GB":"United Kingdom","BR":"Brazil","AU":"Autralia","CA":"Canada","DE":"Germany"]
    static var stockFullName=["^DJI":"Dow 30","000001.SHH":"SSE Composite Index","^BSESN":"BSE SENSEX","NASDAQ:^IXIC":"Nasdaq Composite","^N225":"Nikkei 225","^FTSE":"FTSE 100 Index","^XJO":"S&P/ASX 200","^GSPTSE":"S&P/TSX Composite index","^BVSP":"IBOVESPA","^DAX":"DAX PERFORMANCE-INDEX"]
    static var newsDict=[String:[(title:String,date:String,source:String,url:String,sentiment:String)]]()
    static var searchResultDict=[String:[(symName:String,fulName:String)]]()
    static func LoadHeatMapData(){
    
       //etStockJson(symbol: "AAPL")
       // getStockJson(symbol: "NASDAQ:^IXIC")
       // getStockJson(symbol: "000001.SHH")
    }
    static func callback(marketName:String,dateprice:[String:String],range:Int){
        //->Double{
        let df = DateFormatter()
        var sortedArray:[(Date,[String:String])]
        if(range==1||range==2){
            df.dateFormat = "yyyy-MM-dd"
        }else{
            df.dateFormat = "yyyy-MM-dd HH:mm:ss"
        }
        sortedArray = dateprice
            //First map to an array tuples: [(Date, [String:Int]]
            .map{(df.date(from: $0.key)!, [$0.key:$0.value])}
            //Now sort by the dates, using `<` since dates are Comparable.
            .sorted{$0.0 < $1.0}
        //And re-map to discard the Date objects
        //.map{$1}
        //print(sortedArray)
        valueArr.removeAll()
        if(sortedArray.isEmpty){
            return
        }
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
        if(range != 3){
            stockdict[marketName]=valueArr
            stockdatedict[marketName]=dateArr
            
            
        }else{
            stockdictFiveMin[marketName]=valueArr
            stockdatedictFiveMin[marketName]=dateArr
            stockdictThirtyMin[marketName]=[]
            stockdatedictThirtyMin[marketName]=[]
            for i in 0..<stockdatedictFiveMin[marketName]!.count{
                if (i%6==0){
                    stockdictThirtyMin[marketName]?.append(stockdictFiveMin[marketName]![i])
                    stockdatedictThirtyMin[marketName]?.append(stockdatedictFiveMin[marketName]![i])
                }
            }
            //print("xxxxx")
            //print(stockdatedictThirtyMin[marketName]?.count)
        }
    
        //print(dateArr)
        


    price=change
    //heatmapdict[marketName]=(0.0,change,String(percentage),0.0)
    //print(heatmapdict)
   // var change=Double(sortedArray[sortedArray.count].1.values.lazy())-Double(sortedArray[sortedArray.count-1].1.values[0])
        //return sortedArrayOfDicts.last
    }
    
    static func getStockJson2WCH(symbol:String,range:Int,completionHandler:@escaping (_ success:Bool) -> Void){
        print("APICall")
        var baseUrl=""
        if(range==1){
            //get datapoints(byday)
            baseUrl="https://www.alphavantage.co/query?function=TIME_SERIES_Daily&symbol="
        }else if(range==3){
            //get datapoints(by 5min)
            baseUrl="https://www.alphavantage.co/query?function=TIME_SERIES_INTRADAY&symbol="
        }
        
        let apiKey="&apikey=2VBS7C3YUNCMDA0M"
        var dateprice=[String:String]()
        var url=""
        if(range==2||range==1){
             //get max datapoints(day/5mins)
            url=baseUrl+symbol+"&outputsize=full"+apiKey
        }else{
           url=baseUrl+symbol+"&interval=5min&outputsize=full"+apiKey
        }
        print(url)
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
                    var timeRange=""
                    if(range != 3){
                        timeRange="Time Series (Daily)"
                    }else{
                        timeRange="Time Series (5min)"
                    }
                    if let time = dict[timeRange] as? NSDictionary  {
                        for (key, value) in time {
                            if let value = value as? Dictionary<String, String> {
                                if let close = value["4. close"] {
                                    let i = key as! String
                                    dateprice[i]=close
                                }
                            }
                        }
                        
                    }
                    if(range==3){
                       // print(dateprice)
                    }
                    callback(marketName: symbol, dateprice: dateprice, range:range)
                    completionHandler(true)
                }catch{
                    print(error.localizedDescription)
                    
                }
            }
        }
        task.resume()
        //var price=0.0
        
       
        
        //TODO
        //print("p:"+String(price))
        
    }
    
    
    static func getStockIndexInfo(symbol:String,completionHandler:@escaping (_ success:Bool) -> Void){
        print("APICall")
        let baseUrl="https://www.alphavantage.co/query?function=GLOBAL_QUOTE&symbol="
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
                     //   print(info)
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
    
    static func getStockNews(symbol:String,completionHandler:@escaping (_ success:Bool) -> Void){
        let baseUrl="https://stocknewsapi.com/api/v1?tickers="
        let apiKey="&items=10&fallback=true&token=9rsoblans5vmzllpw0vubcqlmmwttxabmalsdnxs"
        var dateprice=[String:String]()
        let url = baseUrl+symbol+apiKey
        let urlStr : NSString = url.addingPercentEncoding(withAllowedCharacters:.urlQueryAllowed) as! NSString
        let sess=URLSession.shared
        let urls:NSURL=NSURL.init(string: urlStr as String)!
        let request:URLRequest=NSURLRequest.init(url: urls as URL) as URLRequest

        let task = sess.dataTask(with: request){(data, res, error) in
            if(error==nil){
                do{
                    let dict = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as AnyObject
                    print(dict)
                    if let info = dict["data"] as? [NSDictionary] {
                       // print(info)
                        newsDict[symbol]=[(String,String,String,String,String)]()
                        for news in info{
                            if let title = news["title"] {
                                if let sentiment = news["sentiment"] {
                                    if let url = news["news_url"]{
                                        if let source = news["source_name"]{
                                            if let date = news["date"]{
                                                    newsDict[symbol]?.append((title:title as! String,date:date as! String,source as! String,url:url as! String,sentiment: sentiment as! String))
                                             
                        
                                              // print(newsDict)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        
                        
                        
                        
                        //("\(key) CloseStock-> \(close)")
                        //price = callback(dateprice: dateprice)
                        
                    }
                    
                    // price=callback(dateprice: dateprice)
                    
                    
                    //callback(marketName: symbol, dateprice: dateprice)
                    completionHandler(true)
                }catch{
                    print(error.localizedDescription)
                    
                }
            }
        }
        task.resume()
        //var price=0.0
        
        
    }
    static func getSearchResult(symbol:String,completionHandler:@escaping (_ success:Bool) -> Void){
        print("APICall")
        let baseUrl="https://www.alphavantage.co/query?function=SYMBOL_SEARCH&keywords="
        let apiKey="&apikey=2VBS7C3YUNCMDA0M"
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
                    var resultArr=[(String,String)]()
                    let dict = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as AnyObject
                    if let matches = dict["bestMatches"] as? [Dictionary<String, Any>] {
                        for stock in matches {
                            let result = stock["1. symbol"] as! String
                            let name = stock["2. name"] as! String
                            resultArr.append((result,name))
                        }
                    }
                    print("called")
                    searchResultDict[symbol]=resultArr
                    completionHandler(true)
                }catch{
                    print(error.localizedDescription)
                    
                }
            }
        }
        task.resume()
    }
}
