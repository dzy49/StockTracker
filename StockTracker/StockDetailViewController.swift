//
//  StockDetailViewController.swift
//  StockTracker
//
//  Created by Zhaoyuan Deng on 4/22/19.
//  Copyright © 2019 Zhaoyuan Deng. All rights reserved.
//

import UIKit
import SwiftChart

class NewsCell: UITableViewCell{
    override func awakeFromNib() {
        self.backgroundColor=#colorLiteral(red: 0.9374194741, green: 0.936938107, blue: 0.9586750865, alpha: 1)
    }
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var publisher: UILabel!
    
}
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

class StockDetailViewController:UIViewController,ChartDelegate,UITableViewDelegate,UITableViewDataSource{
    @IBOutlet weak var PriceOutlet: UILabel!
    @IBOutlet weak var ChangeOutlet: UILabel!
    @IBOutlet weak var RangeControl: UISegmentedControl!
    @IBOutlet weak var StockChart: Chart!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var NewsTableView: UITableView!

    var newsArr=[(title:String,date:String,pulisher:String)]()
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newsArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = NewsTableView.dequeueReusableCell(withIdentifier: "NewsCell", for: indexPath)
        if let myCell =  cell as? NewsCell {
            myCell.date.text = newsArr[indexPath.row].date
            myCell.title.text = newsArr[indexPath.row].title
            myCell.publisher.text = newsArr[indexPath.row].pulisher
            myCell.selectionStyle = UITableViewCell.SelectionStyle.none
        }
        print("??loaded")
        return cell
    }
    
    
   
    func didFinishTouchingChart(_ chart: Chart) {
        label.text = " "
    }
    
    func didEndTouchingChart(_ chart: Chart) {
        
    }
    
    //@IBOutlet weak var AreaLineGraph: XAreaLineContainerView!
   
    var newView:UIView=UIView(frame: CGRect(x: 1, y:1, width: 1, height: 1))
    var button=UIButton(frame: CGRect(x: 1, y:1, width: 1, height: 1))
    var blackView=UIView(frame: CGRect(x: 1, y:1, width: 1, height: 1))
    var settingOpen=false
    @IBAction func SettingButton(_ sender: UIButton) {
        newView.isHidden = !newView.isHidden
        blackView.isHidden = !blackView.isHidden

    }
    func updateView(){
        let windowSize=CGSize(width: self.view.frame.width*0.7, height: self.view.frame.height/2)
        let windowPoint=CGPoint(x: self.view.frame.maxX*0.15, y: self.view.frame.maxY*0.2)
        let windowRect=CGRect(origin: windowPoint, size: windowSize)
        newView.frame=windowRect
        let buttonRect=CGRect(origin: CGPoint(x: newView.frame.minX*0.7, y:newView.frame.minY) , size: CGSize(width: newView.frame.width*0.7, height: newView.frame.height/2))
        button.frame=buttonRect
        
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    override func viewDidLayoutSubviews() {
        updateView()
        super.viewDidLayoutSubviews()
        
    }
    @objc func buttonAction(sender: UIButton!) {
        let btnsendtag: UIButton = sender
        if btnsendtag.tag == 1 {
            newView.isHidden = !newView.isHidden
            blackView.isHidden = !blackView.isHidden
        }
        print("?????")
    }
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        newView.isHidden = !newView.isHidden
        blackView.isHidden = !blackView.isHidden
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        newsArr.append((title: "this is a news about apple", date: "2077-01-06", pulisher: "me?"))
        newsArr.append((title: "this is another news about apple", date: "2077-01-06", pulisher: "me again"))
        NewsTableView.delegate=self
        NewsTableView.dataSource=self
        let windowSize=CGSize(width: self.view.frame.width*0.7, height: self.view.frame.height/2)
        let windowPoint=CGPoint(x: self.view.frame.maxX*0.15, y: self.view.frame.maxY*0.2)
        let windowRect=CGRect(origin: windowPoint, size: windowSize)
        newView=UIView(frame: windowRect)
        newView.backgroundColor=UIColor.white
        blackView=UIView(frame:self.view.frame)
        blackView.backgroundColor=UIColor.black
        blackView.alpha=0.35
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        blackView.addGestureRecognizer(tap)
        UIApplication.shared.keyWindow?.addSubview(blackView)

        UIApplication.shared.keyWindow?.addSubview(newView)

        button=UIButton(frame: CGRect(origin: CGPoint(x: newView.frame.minX, y:newView.frame.minY) , size: CGSize(width: newView.frame.width*0.7, height: newView.frame.height/2)))
        button.titleLabel?.text="??"
        button.tag=1
        button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        button.backgroundColor=UIColor.red
        newView.layer.cornerRadius=6
        newView.addSubview(button)
        newView.isHidden=true
        blackView.isHidden=true
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
