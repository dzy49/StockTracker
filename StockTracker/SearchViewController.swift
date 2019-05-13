//
//  SearchViewController.swift
//  StockTracker
//
//  Created by Zhaoyuan Deng on 5/12/19.
//  Copyright © 2019 Zhaoyuan Deng. All rights reserved.
//

import Foundation
import UIKit

class SearchCell: UITableViewCell{
    @IBOutlet weak var SymbolName: UILabel!
    @IBOutlet weak var FullName: UILabel!
}

class SearchViewController:UIViewController,UITableViewDataSource,UITableViewDelegate{
    var resultArr=[(String,String)]()
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resultArr.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = SearchResultTable.dequeueReusableCell(withIdentifier: "SearchCell", for: indexPath)
        if let myCell =  cell as? SearchCell {
            myCell.SymbolName.text=resultArr[indexPath.row].0
            myCell.FullName.text=resultArr[indexPath.row].1
        }
        return cell
    }
    
    @IBOutlet weak var SearchBar: UITextField!
    @IBOutlet weak var SearchResultTable: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        SearchResultTable.delegate=self
        SearchResultTable.dataSource=self
        SearchBar.becomeFirstResponder()
        SearchBar.addTarget(self, action: #selector(textFieldDidChange),for: UIControl.Event.editingChanged)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "back") {
            let barViewControllers = segue.destination as! UITabBarController
            //let targetController = destinationTabController[0] as! HomeViewController
            //targetController.shouldGotoDetailView=true
            
            let nav = barViewControllers.viewControllers![0] as! UINavigationController
            let targetController = nav.topViewController as! HomeViewController
            if let stockCell = sender as? SearchCell{
                targetController.shouldGotoDetailView=true
                targetController.searchedSymbolName=stockCell.SymbolName.text!
                targetController.searchedFullName=stockCell.FullName.text!
            }
        }
    }
    
    @objc func textFieldDidChange(textField: UITextField) {
        let searchText=SearchBar.text
        //let delay=DispatchTime(uptimeNanoseconds: 1000000000)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
            if(searchText==self.SearchBar.text){
                if(model.searchResultDict[searchText!]==nil){
                    model.getSearchResult(symbol:searchText!){
                        _ in
                        DispatchQueue.main.async{
                            if(searchText==self.SearchBar.text){
                            self.resultArr=model.searchResultDict[searchText!]!
                                self.SearchResultTable.reloadData()
                            }
                        }
                    }
                }else{
                    self.resultArr=model.searchResultDict[searchText!]!
                    self.SearchResultTable.reloadData()
                }
                
            }else{
                print("ignored")
            }
        })
    }
}
