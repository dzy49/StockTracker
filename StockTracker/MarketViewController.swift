//
//  MarketViewController.swift
//  StockTracker
//
//  Created by Zhaoyuan Deng on 5/14/19.
//  Copyright © 2019 Zhaoyuan Deng. All rights reserved.
//

import UIKit

class indexCellMk:UITableViewCell{
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var volume: UILabel!
    @IBOutlet weak var fullname: UILabel!
    @IBOutlet weak var price: UILabel!
}
class MarketViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    var dict=[String:Double]()
    var sorted=[String]()
    var upsorted=[String]()
    var downsorted=[String]()
    var sortFinish=false
    var finishedCount=0
    var firstSet=true
    
    override func viewWillAppear(_ animated: Bool) {
        if(SortButton.titleLabel?.text=="-"&&finishedCount==model.indexArr.count){
            sortFinish=true
            sorted=upsorted
            MarketTable.reloadData()
            SortButton.setTitle("↑", for: .normal)
        }
        MarketTable.reloadData()

        print("?!")
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.indexArr.count
    }
    
    func getMarketData(marketName:String)->(String,Double){
        var price=0.0
        var pchange=""
        if let p=(model.heatmapdict[marketName]?.price){
            if let change=(model.heatmapdict[marketName]?.pchange){
                price=p
                pchange=change
            }
        }
        print(pchange)
        let pChangeDouble=Double(String(pchange.dropLast()))
        dict[marketName]=pChangeDouble
        return (pchange,price)
        //TODO
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = MarketTable.dequeueReusableCell(withIdentifier: "IndexCellMk", for: indexPath)
        var marketName=""
        if(sortFinish&&sorted.count==model.indexArr.count){
            marketName=sorted[indexPath.row]
            if(firstSet){
                SortButton.setTitle("↑", for: .normal)
                firstSet=false
            }
        }else{
            marketName=model.indexArr[indexPath.row]
        }
        let price=getMarketData(marketName: marketName).0
        let volume=getMarketData(marketName: marketName).1
        if let myCell =  cell as? indexCellMk {
            myCell.name.adjustsFontSizeToFitWidth=true
            myCell.name.minimumScaleFactor=0.3
            myCell.fullname.adjustsFontSizeToFitWidth=true
            myCell.fullname.minimumScaleFactor=0.3
            myCell.name.text = marketName
            myCell.price.textColor=UIColor.white
            myCell.fullname.text=model.stockFullName[marketName]
            if(price.count==0){
                myCell.price.text = "loading"
                myCell.volume.text="loading"
                myCell.price.backgroundColor=UIColor.black
            }else{
                var text:String=String(price.dropLast())
                myCell.price.text =  String(format: "%.2f", Double(text)!)+"%"
                myCell.volume.text = String(format: "%.2f", volume)
                if(Double(price.dropLast())!>0.0){
                    myCell.price.backgroundColor = UIColor(red: 0, green: 0.7556203008, blue: 0.1655870676, alpha: 1)
                }else{
                    myCell.price.backgroundColor=UIColor.red
                }
            }
            myCell.selectionStyle = UITableViewCell.SelectionStyle.none
        }
        return cell
    }
    

    @IBOutlet weak var SortButton: UIButton!
    @IBAction func SortChange(_ sender: UIButton) {
        if(sorted.count==model.indexArr.count){
            if(SortButton.titleLabel?.text=="↓"){
                SortButton.setTitle("↑", for: .normal)
                sorted=upsorted
                MarketTable.reloadData()
            }else{
                SortButton.setTitle("↓", for: .normal)
                sorted=downsorted
                MarketTable.reloadData()
            }
        }else{
            SortButton.setTitle("-", for: .normal)
        }
    }
    @IBOutlet weak var MarketTable: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        MarketTable.dataSource=self
        MarketTable.delegate=self
        MarketTable.cornerRadius=7.5
        MarketTable.clipsToBounds = true
        //view.layer.cornerRadius = 10
        MarketTable.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        if(model.loaded==false){
            for symbol in model.indexArr{
                model.getStockIndexInfo(symbol: symbol){
                    _ in
                    _=self.getMarketData(marketName: symbol)
                    self.finishedCount+=1
                    if(self.finishedCount==model.indexArr.count){
                        var myArr = Array(self.dict.keys)
                        var sortedKeys = myArr.sorted() {
                            var obj1 = self.dict[$0] // get ob associated w/ key 1
                            var obj2 = self.dict[$1] // get ob associated w/ key 2
                            return obj1! > obj2!
                        }
                        self.upsorted=sortedKeys
                        var myArr2 = Array(self.dict.keys)
                        var sortedKeys2 = myArr2.sorted() {
                            var obj1 = self.dict[$0] // get ob associated w/ key 1
                            var obj2 = self.dict[$1] // get ob associated w/ key 2
                            return obj1! < obj2!
                        }
                        self.downsorted=sortedKeys2
                        self.sorted=self.upsorted
                        self.sortFinish=true
                    }
                    DispatchQueue.main.async {
                        self.MarketTable.reloadData()
                    }
                }
                model.loaded=true
            }
        }
            
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
