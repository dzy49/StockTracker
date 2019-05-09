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
    func changezoom(){
        let point=CGRect(x: WorldMapView.frame.midX, y: WorldMapView.frame.midY, width: WorldMapView.frame.midX, height: WorldMapView.frame.midX)
        WorldMapView.zoom(to: point, animated: true)
        
    }
    @IBAction func ZoomChange(_ sender: UISegmentedControl) {
        switch ZoomControl.selectedSegmentIndex{
        case 0:
            changezoom()
        case 1:
            changezoom()
        case 2:
            changezoom()
        case 3:
            changezoom()
        case 4:
            changezoom()
        case 5:
            changezoom()
        default:
            break
        }
    }
    @IBOutlet weak var ZoomControl: UISegmentedControl!
    var mapColor = [String: UIColor]()
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
    

    func getMarketData(marketName:String)->(String,Double){
        var price=0.0
        var pchange=""
        if let p=(model.heatmapdict[marketName]?.price){
            if let change=(model.heatmapdict[marketName]?.pchange){
                price=p
                pchange=change
            }
        }
        return (pchange,price)
        //TODO
    }
    
   
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = MarketTableView.dequeueReusableCell(withIdentifier: "IndexCell", for: indexPath)
        let price=getMarketData(marketName: currIndex[indexPath.row]).0
        let volume=getMarketData(marketName: currIndex[indexPath.row]).1
        if let myCell =  cell as? IndexCell {
            myCell.name.text = currIndex[indexPath.row]
            myCell.price.text = price
            myCell.volume.text = String(volume)
            if(Double(price.dropLast())!>0.0){
                myCell.price.backgroundColor = UIColor(red: 0, green: 0.7556203008, blue: 0.1655870676, alpha: 1)
            }else{
                myCell.price.backgroundColor=UIColor.red
            }
            myCell.selectionStyle = UITableViewCell.SelectionStyle.none
        }
        return cell
    }
    
    func computeColors(){
        for country in model.marketIndex{
            for indexName in country.value{
                if let info=model.heatmapdict[indexName]{
                    if(info.change>0.0){
                        mapColor[country.key]=UIColor.green
                    }else{
                        mapColor[country.key]=UIColor.red
                    }
                }
            }
        }
   
    }
    
    override func viewDidAppear(_ animated: Bool) {
       
        if(model.loaded==false){
        
        for symbol in model.indexArr{
            model.getStockIndexInfo(symbol: symbol){
                _ in
                self.updateMapColor()
            }
            model.loaded=true
        }
        
           
           // model.getSesssionDataTask()
            spinner.stopAnimating()
        }
    }
        
       // updateMapColor()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ZoomControl.tintColor=#colorLiteral(red: 0.02414079942, green: 0.3943191767, blue: 0.429056108, alpha: 0.8470588235)
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
        weak var oldClickedLayer = CAShapeLayer()
        var mapColors = [UIColor]()
        mapColors.append(UIColor.lightGray)
        mapColors.append(UIColor.darkGray)
        map.frame = WorldMapView.frame
        map.clickHandler = {(identifier: String? , _ layer: CAShapeLayer?) -> Void in
            if(model.supportedCountry.contains(identifier!)){
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
                
                
                if(model.supportedCountry.contains(identifier!)){
                    self.MarketName.text=model.countryFullName[identifier!]
                    self.currIndex=model.marketIndex[identifier!]!
                    self.marketCount=model.marketIndex[identifier!]!.count
                    self.MarketTableView.reloadData()
                }
                
            }
            
        }
        
        let mapName: String! = String("world-low")
        //map.color
        //map.loadMap(mapName, withData:mapData, colorAxis:mapColors)
        computeColors()
        map.loadMap(mapName, withColors: mapColor)
        WorldMapView.addSubview(map)
        WorldMapView.setNeedsDisplay()
        WorldMapView.contentSize=CGSize(width: 1000, height: 1000)
        //WorldMapView.frame.size
        WorldMapView.maximumZoomScale=4
        WorldMapView.minimumZoomScale=0.5
        MarketTableView.cornerRadius=7.5
        
    }
    
    func updateMapColor(){
        //mapColor["US"]=UIColor.blue
        //map.setColors(mapColor)
        DispatchQueue.main.async {
                //Do UI Code here.
            self.computeColors()
            self.map.setColors(self.mapColor)
        }
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
