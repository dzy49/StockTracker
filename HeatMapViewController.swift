//
//  HeatMapViewController.swift
//  StockTracker
//
//  Created by Zhaoyuan Deng on 4/23/19.
//  Copyright © 2019 Zhaoyuan Deng. All rights reserved.
//

import UIKit
import Foundation
import FSInteractiveMap

class IndexCell: UITableViewCell{
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var volume: UILabel!
}
class HeatMapViewController: UIViewController,UIScrollViewDelegate,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var MarketName: UILabel!
    var spinner:UIActivityIndicatorView=UIActivityIndicatorView()
    var currIndex=[String]()
    @IBOutlet weak var WorldMapView: UIScrollView!
    @IBOutlet weak var MarketTableView: UITableView!
    let map: FSInteractiveMapView = FSInteractiveMapView()
    var marketCount:Int=0
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return map
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return marketCount
    }
    

    func getMarketData(marketName:String)->(Double,String){
       
        var price=0.0
        if let p=(model.heatmapdict[marketName]?.price){
            price=p
        }
        return (price,"1000")
        //TODO
    }
    
   
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = MarketTableView.dequeueReusableCell(withIdentifier: "IndexCell", for: indexPath)
        let price=getMarketData(marketName: currIndex[indexPath.row]).0
        let volume=getMarketData(marketName: currIndex[indexPath.row]).1
        if let myCell =  cell as? IndexCell {
            myCell.name.text = currIndex[indexPath.row]
            myCell.price.text = String(price)
            myCell.volume.text = volume
            if(price>0){
                myCell.price.backgroundColor = UIColor(red: 0, green: 0.7556203008, blue: 0.1655870676, alpha: 1)
            }else{
                myCell.price.backgroundColor=UIColor.red
            }
            myCell.selectionStyle = UITableViewCell.SelectionStyle.none
        }
        return cell
    }
    
    func computeColors()->[String:UIColor]{
        //TODO
        var mapColor = [String: UIColor]()
        if let p=model.heatmapdict["DJI"]?.price{
            if(p > 0.0){
                mapColor["US"]=UIColor.green
            }else{
                mapColor["US"]=UIColor.red
            }
        }
        
        if let p=model.heatmapdict["000001.SHH"]?.price{
            if(p > 0.0){
                mapColor["CN"]=UIColor.green
            }else{
                mapColor["CN"]=UIColor.red
            }
        }
        return mapColor
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if(model.loaded==false){
            model.LoadHeatMapData()
           // model.getSesssionDataTask()
            spinner.stopAnimating()
        
        weak var oldClickedLayer = CAShapeLayer()
        
        var mapData              = [String: Int]()
        mapData["US"]          = 12
        mapData["australia"]     = 2
        mapData["north_america"] = 5
        mapData["south_america"] = 14
        mapData["africa"]        = 5
        mapData["europe"]        = 20
        
        
        //var mapData2            = [String: UIColor]()
        //mapData2["US"]          = UIColor.red
        
        var mapColors = [UIColor]()
        mapColors.append(UIColor.lightGray)
        mapColors.append(UIColor.darkGray)
        map.frame = WorldMapView.frame
        map.clickHandler = {(identifier: String? , _ layer: CAShapeLayer?) -> Void in
            if(identifier=="CN"||identifier=="US"){
                if (oldClickedLayer != nil) {
                    oldClickedLayer?.zPosition = 0
                    oldClickedLayer?.shadowOpacity = 0
                    
                }
                oldClickedLayer = layer
                // We set a simple effect on the layer clicked to highlight it
                layer?.zPosition = 10
                layer?.shadowOpacity = 0.5
                layer?.shadowColor = UIColor.black.cgColor
                layer?.shadowRadius = 5
                layer?.shadowOffset = CGSize(width: 0, height: 0)
                //layer?.shadowColor = UIColor.blue.cgColor;
                //layer?.fillColor=UIColor.blue.cgColor;
                //print(identifier)
                if(identifier=="CN"){
                    self.MarketName.text="China"
                    self.currIndex=model.marketIndex["CN"]!
                    self.marketCount=1
                    self.MarketTableView.reloadData()
                }else if(identifier=="US"){
                    self.MarketName.text="United States"
                    self.currIndex=model.marketIndex["US"]!
                    self.marketCount=2
                    self.MarketTableView.reloadData()
                    
                }
                
            }
            
        }
        
        let mapName: String! = String("world-low")
        //map.color
        //map.loadMap(mapName, withData:mapData, colorAxis:mapColors)
        map.loadMap(mapName, withColors: computeColors())
        WorldMapView.addSubview(map)
        WorldMapView.setNeedsDisplay()
        WorldMapView.contentSize=CGSize(width: 1000, height: 1000)
        //WorldMapView.frame.size
        WorldMapView.maximumZoomScale=4
        WorldMapView.minimumZoomScale=0.5
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        WorldMapView.delegate=self
        MarketTableView.delegate=self
        MarketTableView.dataSource=self
//        model.LoadHeatMapData()
        //model.getSesssionDataTask()
        spinner.center=view.center
        spinner.style=UIActivityIndicatorView.Style.gray
        view.addSubview(spinner)
        spinner.startAnimating()
        spinner.hidesWhenStopped=true
        
        
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
