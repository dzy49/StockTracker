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
    override func awakeFromNib() {
        self.backgroundColor=#colorLiteral(red: 0.02414079942, green: 0.3943191767, blue: 0.429056108, alpha: 0.8470588235)
    }
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var volume: UILabel!
}

class HeatMapViewController: UIViewController,UIScrollViewDelegate,UITableViewDelegate,UITableViewDataSource {
    @IBOutlet weak var MapHeightCons: NSLayoutConstraint!
    func changezoom(area:Int){
        if(UIDevice.current.orientation==UIDeviceOrientation.portrait){
            let ASpoint=CGRect(x: WorldMapView.frame.midX*1.32, y: WorldMapView.frame.midY*0.2, width: WorldMapView.frame.width*0.23, height: WorldMapView.frame.height*0.23)
            let EUpoint=CGRect(x: WorldMapView.frame.midX*1, y: WorldMapView.frame.midY*0.3, width: WorldMapView.frame.width*0.0005, height: WorldMapView.frame.height*0.0005)
            let Worldpoint=CGRect(x: WorldMapView.frame.midX, y: WorldMapView.frame.midY, width: WorldMapView.frame.width, height: WorldMapView.frame.height)
            let NApoint=CGRect(x: WorldMapView.frame.minX, y: WorldMapView.frame.midY*0.11, width: WorldMapView.frame.width*0.33, height: WorldMapView.frame.height*0.33)
            let SApoint=CGRect(x: WorldMapView.frame.midX*0.35, y: WorldMapView.frame.midY*0.4, width: WorldMapView.frame.width*0.23, height: WorldMapView.frame.height*0.23)
            let OCpoint=CGRect(x: WorldMapView.frame.midX*1.55, y: WorldMapView.frame.midY*0.45, width: WorldMapView.frame.width*0.2, height: WorldMapView.frame.height*0.2)
            switch area{
            case 0:
                WorldMapView.zoom(to: Worldpoint, animated: true)
            case 1:
                WorldMapView.zoom(to: ASpoint, animated: true)
            case 2:
                WorldMapView.zoom(to: EUpoint, animated: true)
            case 3:
                WorldMapView.zoom(to: NApoint, animated: true)
            case 4:
                WorldMapView.zoom(to: SApoint, animated: true)
            case 5:
                WorldMapView.zoom(to: OCpoint, animated: true)
            default:
                break
            }
        }
    }
    @IBAction func ZoomChange(_ sender: UISegmentedControl) {
        switch ZoomControl.selectedSegmentIndex{
        case 0:
            changezoom(area: 0)
        case 1:
            changezoom(area: 1)
        case 2:
            changezoom(area: 2)
        case 3:
            changezoom(area: 3)
        case 4:
            changezoom(area: 4)
        case 5:
            changezoom(area: 5)
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
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85
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
            print(identifier)
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
        WorldMapView.contentSize=CGSize(width: 200, height: 200)
        WorldMapView.addSubview(map)
        WorldMapView.setNeedsDisplay()
        //WorldMapView.frame.size
        WorldMapView.maximumZoomScale=6
        WorldMapView.minimumZoomScale=0.0001
        MarketTableView.cornerRadius=7.5
        MarketTableView.clipsToBounds = true
        //view.layer.cornerRadius = 10
        MarketTableView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
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
