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
        self.selectionStyle = .none
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
    }
    var saved:[(String,Double,Double)]=[("AAPL",0.0,-0.0),("MSFT",0.0,-0.0)]
    var actsaved:[String:String]=["AAPL":"Apple lnc","MSFT":"Microsoft"]
    var orderedsaved=[Int: [String: String]]()
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            var dict=UserDefaults.standard.dictionary(forKey: "saved")
            dict?.removeValue(forKey: (orderedsaved[indexPath.row]?.first?.key)!)
            UserDefaults.standard.set(dict,forKey:"saved")
            actsaved.removeValue(forKey: (orderedsaved[indexPath.row]?.first?.key)!)
            var myDictionary = [Int: [String: String]]()
            var i=0
            for saved in actsaved{
                let newDic=[saved.key:saved.value]
                myDictionary[i]=newDic
                i=i+1
            }
            orderedsaved=myDictionary
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return actsaved.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120.0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = SavedTableViewOutlet.dequeueReusableCell(withIdentifier: "StockCell", for: indexPath)
        if let myCell =  cell as? StockCell {
            //print(orderedsaved)
            myCell.name.text = orderedsaved[indexPath.row]?.first?.key
            //myCell.price.text = String(saved[indexPath.row].1)
            let name=myCell.name.text!
            if(model.stockdict[name] != nil){
                let currprice=(model.stockdict[name]?[model.stockdict[name]!.count-1])!
                let prevprice=(model.stockdict[name]?[model.stockdict[name]!.count-2])!
                let change=currprice-prevprice
                let pchange=(currprice-prevprice)/prevprice*100
                let str = NSString(format: "%.2f", currprice)
                myCell.price.text = str as String
                print(change)
               
                myCell.change.text = String(format: "%.2f",change)+"("+String(format: "%.2f", pchange)+"%)"
                if(pchange>=0){
                    myCell.change.backgroundColor = UIColor(red: 0, green: 0.7556203008, blue: 0.1655870676, alpha: 1)
                }else{
                    myCell.change.backgroundColor=UIColor.red
                }
                
            }
            myCell.fullName.text=orderedsaved[indexPath.row]?.first?.value
            myCell.fullName.adjustsFontSizeToFitWidth = true
            myCell.fullName.minimumScaleFactor = 0.2
//            var percentString = String(saved[indexPath.row].2)
//            percentString.append("%")
           /*myCell.change.text = percentString
            if(saved[indexPath.row].2>0){
                myCell.change.backgroundColor = UIColor(red: 0, green: 0.7556203008, blue: 0.1655870676, alpha: 1)
            }else{
                myCell.change.backgroundColor=UIColor.red
            }
            myCell.selectionStyle = UITableViewCell.SelectionStyle.none
            myCell.change.layer.masksToBounds = true
            myCell.change.layer.cornerRadius = 4
 */
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
        let defaults = UserDefaults.standard
        // let arr=[(String,String)]()
        if (defaults.dictionary(forKey: "saved")==nil){
            defaults.set(actsaved,forKey: "saved")
        }else{
            actsaved=defaults.dictionary(forKey: "saved") as! [String : String]
            var myDictionary = [Int: [String: String]]()
            var i=0
            for saved in actsaved{
                let newDic=[saved.key:saved.value]
                myDictionary[i]=newDic
                i=i+1
            }
            orderedsaved=myDictionary
        }
        SavedTableViewOutlet.reloadData()

        for  stock in actsaved {
            if(model.stockdict[stock.key]==nil){
                model.getStockJson2WCH(symbol:stock.key,range: 3){
                    _ in
                    print("reloaded")
                    DispatchQueue.main.async {
                        self.SavedTableViewOutlet.reloadData()
                    }
                }
            }
        }
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
        let defaults = UserDefaults.standard
       // let arr=[(String,String)]()
        if (defaults.dictionary(forKey: "saved")==nil){
            defaults.set(actsaved,forKey: "saved")
        }else{
            actsaved=defaults.dictionary(forKey: "saved") as! [String : String]
            var myDictionary = [Int: [String: String]]()
            var i=0
            for saved in actsaved{
                let newDic=[saved.key:saved.value]
                myDictionary[i]=newDic
                i=i+1
            }
            orderedsaved=myDictionary
        }
        
        for  stock in actsaved {
            if(model.stockdict[stock.key]==nil){
                model.getStockJson2WCH(symbol:stock.key,range: 1){
                    _ in
                        print("reloaded")
                        DispatchQueue.main.async {
                            self.SavedTableViewOutlet.reloadData()
                        }
                }
            }
        }
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
