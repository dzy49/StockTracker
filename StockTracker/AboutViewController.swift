//
//  AboutViewController.swift
//  StockTracker
//
//  Created by Zhaoyuan Deng on 5/14/19.
//  Copyright © 2019 Zhaoyuan Deng. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController {

    @IBAction func ResetAction(_ sender: UIButton) {
        let alert = UIAlertController(title: "Warning", message: "Do you want to reset watchlist? All data will be deleted", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
            var actsaved:[String:String]=["AAPL":"Apple lnc","MSFT":"Microsoft"]
            UserDefaults.standard.set(actsaved,forKey: "saved")
        }))
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)

    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
