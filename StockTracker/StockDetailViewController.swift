//
//  StockDetailViewController.swift
//  StockTracker
//
//  Created by Zhaoyuan Deng on 4/22/19.
//  Copyright © 2019 Zhaoyuan Deng. All rights reserved.
//

import UIKit
import SwiftChart

extension UISegmentedControl {
    func removeBorders() {
        setBackgroundImage(imageWithColor(color: UIColor.white), for: .normal, barMetrics: .default)
        setBackgroundImage(imageWithColor(color: tintColor!), for: .selected, barMetrics: .default)
        setDividerImage(imageWithColor(color: UIColor.clear), forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)
    }
    
    private func imageWithColor(color: UIColor) -> UIImage {
        let rect = CGRect(x: 0.0, y: 0.0, width:  1.0, height: 1.0)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context!.setFillColor(color.cgColor);
        context!.fill(rect);
        let image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return image!
    }
}

class StockDetailViewController:UIViewController,ChartDelegate{
    
    @IBOutlet weak var PriceOutlet: UILabel!
    @IBOutlet weak var ChangeOutlet: UILabel!
    func didFinishTouchingChart(_ chart: Chart) {
        label.text = " "
    }
    
    func didEndTouchingChart(_ chart: Chart) {
        
    }
    
    //@IBOutlet weak var AreaLineGraph: XAreaLineContainerView!
    @IBOutlet weak var RangeControl: UISegmentedControl!
    @IBOutlet weak var StockChart: Chart!
    //@IBOutlet weak var labelLeadingMarginConstraint: NSLayoutConstraint!
    @IBOutlet weak var label: UILabel!
   // fileprivate var labelLeadingMarginInitialConstant: CGFloat!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        StockChart.delegate=self
        //labelLeadingMarginInitialConstant = labelLeadingMarginConstraint.constant
        var followbutton=UIBarButtonItem(title:"+ Follow", style: .plain, target: self, action: nil)
        self.navigationItem.rightBarButtonItem=followbutton
        followbutton.tintColor=UIColor.white
        self.tabBarController?.tabBar.isHidden = true
        navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.02414079942, green: 0.3943191767, blue: 0.429056108, alpha: 0.8470588235)
        RangeControl.tintColor=#colorLiteral(red: 0.02414079942, green: 0.3943191767, blue: 0.429056108, alpha: 0.8470588235)
        self.title = "AAPL";
        self.navigationController?.navigationBar.tintColor = UIColor.white;
        self.navigationController?.navigationBar.titleTextAttributes=[NSAttributedString.Key.foregroundColor: UIColor.white]
        RangeControl.removeBorders()
        model.LoadHeatMapData()
        let lastthrity=(model.stockdict["AAPL"]?.count)!-30
        let last=(model.stockdict["AAPL"]?.count)!-1
        let series1 = ChartSeries(Array(model.valueArr[lastthrity..<last]))
        series1.color = ChartColors.darkGreenColor()
        series1.area = true
        print(model.valueArr)
        StockChart.add([series1])
        //StockChart.xLabels = [0, 3, 6, 9, 12, 15, 18, 21, 24]
        //StockChart.xLabelsFormatter = { if($1<10){return String(Int(round($1))) }else {return ""}}
        //StockChart.showXLabelsAndGrid=false
        var labels=[0.0,10,20]
        var labelsAsString=["a","b","c"]
        StockChart.xLabels=labels
        StockChart.xLabelsFormatter = { (labelIndex: Int, labelValue: Double) -> String in
            return labelsAsString[labelIndex]
        }
        let currprice=(model.stockdict["AAPL"]?[model.stockdict["AAPL"]!.count-1])!
        let prevprice=(model.stockdict["AAPL"]?[model.stockdict["AAPL"]!.count-2])!
        let change=currprice-prevprice
        let pchange=(currprice-prevprice)/prevprice*100
        PriceOutlet.text=String(currprice)
        
        ChangeOutlet.text=String(format: "%.2f",change)+"("+String(format: "%.2f", pchange)+"%)"
        ChangeOutlet.layer.cornerRadius=5
        ChangeOutlet.textColor=UIColor.white
        if(change>=0){
            ChangeOutlet.backgroundColor=UIColor.green
        }else{
            ChangeOutlet.backgroundColor=UIColor.red
        }
        //print(model.stockdict.count)

        // Do any additional setup after loading the view.
    }
    

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
    }
    
    @IBOutlet weak var SummaryHistorySwitch: UISegmentedControl!
    func didTouchChart(_ chart: Chart, indexes: Array<Int?>, x: Double, left: CGFloat) {
        if let value = chart.valueForSeries(0, atIndex: indexes[0]) {
            let numberFormatter = NumberFormatter()
            numberFormatter.minimumFractionDigits = 2
            numberFormatter.maximumFractionDigits = 2
            let lastthrity=(model.stockdict["AAPL"]?.count)!-30
            let last=(model.stockdict["AAPL"]?.count)!-1
            let corrsArr=Array(model.stockdatedict["AAPL"]![lastthrity..<last])
            let date_string = corrsArr[indexes[0]!]
            let main_string = numberFormatter.string(from: NSNumber(value: value))!+" "+date_string
            let range = (main_string as NSString).range(of: date_string)
            let attribute = NSMutableAttributedString.init(string: main_string)
            attribute.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.lightGray , range: range)
            //label.text = model.stockdatedict["AAPL"]![indexes[0]!]+" "+numberFormatter.string(from: NSNumber(value: value))!
            label.attributedText=attribute

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
