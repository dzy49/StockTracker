//
//  SearchViewController.swift
//  StockTracker
//
//  Created by Dana on 5/11/19.
//  Copyright © 2019 Zhaoyuan Deng. All rights reserved.
//

import UIKit


class SearchViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar! {
        didSet {
            searchBar.delegate = self
        }
    }
    @IBOutlet weak var searchTable: UITableView! {
        didSet {
            searchTable.delegate = self
            searchTable.dataSource = self
        }
    }
    
    var stocks: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        searchTable.dataSource = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stocks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = searchTable.dequeueReusableCell(withIdentifier: "searched", for: indexPath) as UITableViewCell
        let stock = stocks[indexPath.row]
        cell.textLabel?.text = stock
        return cell
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let urlString = "https://www.alphavantage.co/query?function=SYMBOL_SEARCH&keywords=\(searchText)&apikey=6C2PR5ZBG60H6490"
        
        if(searchText != "") {
            guard let url = URL(string: urlString) else {
                return
            }
            let task = URLSession.shared.dataTask(with: url) {
                (data, response, error) in
                //check for erros
                guard error == nil else {
                    print(error!)
                    return
                }
                //make sure we have data
                guard let data = data else {
                    print("no data")
                    return
                }
                self.stocks.removeAll()
                guard let response = try? JSONSerialization.jsonObject(with: data, options: []) as! [String: Any] else {
                    return
                }
        
                if let matches = response["bestMatches"] as? [Dictionary<String, Any>] {
                    for stock in matches {
                        let symbol = stock["1. symbol"] as! String
//                        let name = stock["2. name"] as! String
                        self.stocks.append(symbol)
                    }
                }
                print(self.stocks)
                DispatchQueue.main.async {
                    self.searchTable.reloadData()
                }
            }
            task.resume()
        } else {
            searchBarCancelButtonClicked(searchBar)
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        stocks = []
        searchTable.reloadData()
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
