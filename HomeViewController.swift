//
//  HomeViewController.swift
//  StockTracker
//
//  Created by Zhaoyuan Deng on 4/21/19.
//  Copyright © 2019 Zhaoyuan Deng. All rights reserved.
//

import UIKit

class StockCell: UITableViewCell{
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var change: UILabel!
    

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
    @IBOutlet weak var EditbuttonOutlet: UIButton!
    
    @IBAction func EditAction(_ sender: UIButton) {
        SavedTableViewOutlet.setEditing(!SavedTableViewOutlet.isEditing, animated: true)
        HeatMapViewController().updateMapColor()
    }
    var saved:[(String,Double,Double)]=[("AAPL",11.1,3),("AAPL2",11.1,-3)]
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return saved.count

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
        self.navigationController?.navigationBar.isHidden = true
        self.tabBarController?.tabBar.isHidden = false
        tabBarController?.tabBar.barTintColor = #colorLiteral(red: 0.111971654, green: 0.2306475043, blue: 0.445986867, alpha: 1)
        tabBarController?.tabBar.tintColor = UIColor.white
        SavedTableViewOutlet.cornerRadius=7.5

    }
    @IBOutlet weak var SavedTableViewOutlet: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        SavedTableViewOutlet.delegate=self
        SavedTableViewOutlet.dataSource=self
        //self.navigationItem.rightBarButtonItem = self.editButtonItem

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
