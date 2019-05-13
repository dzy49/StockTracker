//
//  HomeViewController.swift
//  StockTracker
//
//  Created by Zhaoyuan Deng on 4/21/19.
//  Copyright © 2019 Zhaoyuan Deng. All rights reserved.
//

import UIKit

class StockCell: UITableViewCell{
    override func awakeFromNib() {
        self.backgroundColor=UIColor.lightGray
    }
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var change: UILabel!
    @IBOutlet weak var fullName: UILabel!
}

extension UITableView {
    public var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = true
        }
    }
}

class HomeViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {
    var shouldGotoDetailView=false
    var searchedSymbolName=""
    var searchedFullName=""
    @IBOutlet weak var EditbuttonOutlet: UIButton!
    
    @IBAction func EditAction(_ sender: UIButton) {
        SavedTableViewOutlet.setEditing(!SavedTableViewOutlet.isEditing, animated: true)
        HeatMapViewController().updateMapColor()
    }
    var saved:[(String,Double,Double)]=[("AAPL",200.72,-2.18),("MSFT",110.11,3.11)]
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return saved.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120.0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = SavedTableViewOutlet.dequeueReusableCell(withIdentifier: "StockCell", for: indexPath)
        if let myCell =  cell as? StockCell {
            myCell.name.text = saved[indexPath.row].0
            myCell.price.text = String(saved[indexPath.row].1)
            var percentString = String(saved[indexPath.row].2)
            percentString.append("%")
            myCell.change.text = percentString
            if(saved[indexPath.row].2>0){
                myCell.change.backgroundColor = UIColor(red: 0, green: 0.7556203008, blue: 0.1655870676, alpha: 1)
            }else{
                myCell.change.backgroundColor=UIColor.red
            }
            myCell.selectionStyle = UITableViewCell.SelectionStyle.none
            myCell.change.layer.masksToBounds = true
            myCell.change.layer.cornerRadius = 4
        }
        return cell
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
        if(shouldGotoDetailView){
            shouldGotoDetailView=false
            performSegue(withIdentifier: "Detail", sender: nil)
        }
        self.navigationController?.navigationBar.isHidden = true
        tabBarController?.tabBar.barTintColor = UIColor.black
        tabBarController?.tabBar.tintColor = UIColor.white
        SavedTableViewOutlet.cornerRadius=7.5
        
    }
    override func viewDidAppear(_ animated: Bool) {
        if(shouldGotoDetailView){
            shouldGotoDetailView=false
            performSegue(withIdentifier: "Detail", sender: nil)
        }
        self.tabBarController?.tabBar.isHidden = false
    }
    @IBOutlet weak var SavedTableViewOutlet: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SavedTableViewOutlet.delegate=self
        SavedTableViewOutlet.dataSource=self
        //self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        // Do any additional setup after loading the view.
    }
    
   
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier=="Detail"){
            let VC=segue.destination as! StockDetailViewController
            if let stockCell = sender as? StockCell{
                
                VC.symbolName=stockCell.name.text!
                VC.fullName=stockCell.fullName.text!
                VC.title=stockCell.name.text!
            } else {
                VC.symbolName=searchedSymbolName
                VC.title=searchedSymbolName
                VC.fullName=searchedFullName
            }
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
