//
//  ViewController.swift
//  StockTracker
//
//  Created by Zhaoyuan Deng on 4/16/19.
//  Copyright © 2019 Zhaoyuan Deng. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let barItem = UITabBarItem(tabBarSystemItem: .search, tag: 2)

        // Do any additional setup after loading the view, typically from a nib.
//        self.tabBarController?.tabBar.items?[0] = UITabBarItem.SystemItem.home
//        self.tabBarController?.tabBar.items?[2] = UITabBarItem.SystemItem.search
        getSesssionDataTask()
    }
    
    func getSesssionDataTask()  {
        let urlStr="https://www.alphavantage.co/query?function=TIME_SERIES_Daily&symbol=DJI&apikey=6C2PR5ZBG60H6490"
        let sess=URLSession.shared
        let urls:NSURL=NSURL.init(string: urlStr)!
        let request:URLRequest=NSURLRequest.init(url: urls as URL) as URLRequest
        let task = sess.dataTask(with: request){(data, res, error) in
            if(error==nil){
                do{
                    let dict = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as AnyObject
                    print(dict)
                    if let time = dict["Time Series (5min)"] as? NSDictionary  {
                        for (key, value) in time {
                            if let value = value as? Dictionary<String, String> {
                                if let close = value["4. close"] {
                                   print("\(key) CloseStock-> \(close)")
                                }
                            }
                        }
                    }
                }catch{
                    print(error.localizedDescription)

                }
            }
        }
        task.resume()
        print("StockTracker")
    }
    
    
}

