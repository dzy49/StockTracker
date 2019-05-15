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
    @IBOutlet weak var SentimentMark: UILabel!
    
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
    @IBOutlet weak var FullNameOutlet: UILabel!
    @IBOutlet weak var SymbolNameOuelet: UILabel!
    @IBOutlet weak var PriceOutlet: UILabel!
    @IBOutlet weak var ChangeOutlet: UILabel!
    @IBOutlet weak var RangeControl: UISegmentedControl!
    @IBOutlet weak var StockChart: Chart!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var NewsTableView: UITableView!
    var settingLabel=UILabel(frame: CGRect(x: 1, y:1, width: 1, height: 1))
    var symbolName:String=""
    var fullName=""
    var followbutton=UIBarButtonItem()
    var newsArr=[(title:String,date:String,pulisher:String,sentiment:String)]()
    var dataReady=false
    var newView:UIView=UIView(frame: CGRect(x: 1, y:1, width: 1, height: 1))
    var button=UIButton(frame: CGRect(x: 1, y:1, width: 1, height: 1))
    var emojiControl:UISegmentedControl?
    var blackView=UIView(frame: CGRect(x: 1, y:1, width: 1, height: 1))
    var settingOpen=false
    
    @IBAction func RangeChange(_ sender: UISegmentedControl) {
        if(dataReady){
        switch RangeControl.selectedSegmentIndex{
        case 0:
           //1d
            updateChart(range: 1)
        case 1:
            //5d
            updateChart(range: 2)
        case 2:
          //1m
            updateChart(range: 3)
        case 3:
           //6m
            updateChart(range: 4)
        case 4:
            //1Y
            updateChart(range: 5)
        case 5:
           //5Y
            updateChart(range: 6)
        default:
            break
        }
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(model.newsDict[symbolName]==nil){
            return 0
        }else{
            return (model.newsDict[symbolName]?.count)!
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = NewsTableView.dequeueReusableCell(withIdentifier: "NewsCell", for: indexPath)
        if let myCell =  cell as? NewsCell {
           
            myCell.selectionStyle = UITableViewCell.SelectionStyle.none
            let datetext=model.newsDict[symbolName]?[indexPath.row].date
            myCell.date.text = String((datetext?.dropLast(5))!)
            myCell.date.minimumScaleFactor=0.2
            myCell.date.adjustsFontSizeToFitWidth=true
            myCell.title.text = model.newsDict[symbolName]?[indexPath.row].title
            myCell.publisher.text = model.newsDict[symbolName]?[indexPath.row].source
            myCell.title.adjustsFontSizeToFitWidth = true
            myCell.title.minimumScaleFactor = 0.2
            let defaults=UserDefaults.standard
            var postiveText=""
            var negativeText=""
            var neaturalText=""
            if(defaults.bool(forKey: "emoji")){
                postiveText="😀"
                negativeText="😔"
                neaturalText="😐"
            }else{
                postiveText="▲"
                negativeText="▼"
                neaturalText="-"
            }
            if(model.newsDict[symbolName]?[indexPath.row].sentiment=="Positive"){
                myCell.SentimentMark.text=postiveText
                myCell.SentimentMark.textColor=UIColor(red: 0, green: 0.7556203008, blue: 0.1655870676, alpha: 1)
            }else if(model.newsDict[symbolName]?[indexPath.row].sentiment=="Negative"){
                myCell.SentimentMark.text=negativeText
                myCell.SentimentMark.textColor=UIColor.red
            }else{
                myCell.SentimentMark.text=neaturalText
                myCell.SentimentMark.textColor=#colorLiteral(red: 0.9475597739, green: 0.7683563828, blue: 0, alpha: 1)
            }
        }
        //print("??loaded")
        return cell
    }
    
    
   
    func didFinishTouchingChart(_ chart: Chart) {
        label.text = " "
    }
    
    func didEndTouchingChart(_ chart: Chart) {
        
    }
    
    //@IBOutlet weak var AreaLineGraph: XAreaLineContainerView!
   
    
    @IBAction func SettingButton(_ sender: UIButton) {
        newView.isHidden = !newView.isHidden
        blackView.isHidden = !blackView.isHidden
    }
    func updateView(){
        let windowSize=CGSize(width: self.view.frame.width*0.7, height: self.view.frame.height/4)
        let windowPoint=CGPoint(x: self.view.frame.maxX*0.15, y: self.view.frame.maxY*0.2)
        let windowRect=CGRect(origin: windowPoint, size: windowSize)
        newView.frame=windowRect
        let buttonRect=CGRect(origin: CGPoint(x: newView.frame.minX*0.7, y:newView.frame.minY*0.7) , size: CGSize(width: newView.frame.width*0.7, height: newView.frame.height/8))
        let emojiRect=CGRect(origin: CGPoint(x: newView.frame.minX*0.7, y:newView.frame.minY*0.5) , size: CGSize(width: newView.frame.width*0.7, height: newView.frame.height/8))
        let labelRect=CGRect(origin: CGPoint(x: newView.frame.minX*0.7, y:newView.frame.minY*0.2) , size: CGSize(width: newView.frame.width*0.7, height: newView.frame.height/5))
        button.frame=buttonRect
        blackView.frame=self.view.frame
        emojiControl?.frame=emojiRect
        settingLabel.frame=labelRect
       // emojiControl=UISegmentedControl(frame: buttonRect)
       
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    override func viewDidLayoutSubviews() {
        updateView()
        super.viewDidLayoutSubviews()
        
    }
    @objc func followPressed(sender: UIButton!) {
        let defaults = UserDefaults.standard
        // let arr=[(String,String)]()
        var dict:[String:String]=defaults.dictionary(forKey: "saved") as! [String: String]
        
        if(followbutton.title=="+ Follow"){
            dict[symbolName]=fullName
            defaults.set(dict,forKey: "saved")
            followbutton.title="Following"
        }else{
            dict.removeValue(forKey: symbolName)
            defaults.set(dict,forKey: "saved")
            followbutton.title="+ Follow"
        }
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            let fetchurl=model.newsDict[symbolName]![indexPath.row].url
            if let url = URL(string: fetchurl),
            UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:])
            }
    }
    @objc func changeEmoji(){
        print(emojiControl!.selectedSegmentIndex)

        switch emojiControl!.selectedSegmentIndex {
        case 0:
            UserDefaults.standard.set(false, forKey:"emoji")
            NewsTableView.reloadData()
        case 1:
            UserDefaults.standard.set(true, forKey:"emoji")
            NewsTableView.reloadData()
        default:
            break
        }
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let defaults = UserDefaults.standard
       
        SymbolNameOuelet.text=symbolName
        FullNameOutlet.text=fullName;
        FullNameOutlet.adjustsFontSizeToFitWidth = true
        FullNameOutlet.minimumScaleFactor=0.3
        PriceOutlet.adjustsFontSizeToFitWidth = true
        PriceOutlet.minimumScaleFactor=0.3
        ChangeOutlet.adjustsFontSizeToFitWidth = true
        ChangeOutlet.minimumScaleFactor=0.3
        //newsArr.append((title: "this is a news about apple", date: "2077-01-06", pulisher: "me?"))
        //newsArr.append((title: "this is another news about apple", date: "2077-01-06", pulisher: "me again"))
        NewsTableView.delegate=self
        NewsTableView.dataSource=self
        model.getStockNews(symbol:symbolName){
            _ in
            DispatchQueue.main.async {
                self.NewsTableView.reloadData()
                
            }
        }
        
        let windowSize=CGSize(width: self.view.frame.width*0.7, height: self.view.frame.height/2)
        let windowPoint=CGPoint(x: self.view.frame.maxX*0.15, y: self.view.frame.maxY*0.2)
        let windowRect=CGRect(origin: windowPoint, size: windowSize)
        newView=UIView(frame: windowRect)
        newView.backgroundColor=UIColor.white
        blackView=UIView(frame:self.view.frame)
        blackView.backgroundColor=UIColor.black
        blackView.alpha=0.35
        let items = ["Arrows", "Emoji"]
        emojiControl = UISegmentedControl(items: items)
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        blackView.addGestureRecognizer(tap)
        UIApplication.shared.keyWindow?.addSubview(blackView)
        UIApplication.shared.keyWindow?.addSubview(newView)
        emojiControl!.frame=CGRect(origin: CGPoint(x: newView.frame.minX, y:newView.frame.minY) , size: CGSize(width: newView.frame.width*0.7, height: newView.frame.height/5))
        emojiControl!.backgroundColor = UIColor.white
        emojiControl!.tintColor = #colorLiteral(red: 0.03657037765, green: 0.4095795453, blue: 0.4451715946, alpha: 1)
        
        emojiControl!.addTarget(self, action: #selector(changeEmoji), for: .valueChanged)
        if(defaults.bool(forKey: "emoji")==nil){
            defaults.set(true, forKey: "emoji")
        }else{
            if(defaults.bool(forKey: "emoji")){
                emojiControl!.selectedSegmentIndex=1
            }else{
                emojiControl?.selectedSegmentIndex=0
            }
        }
        newView.addSubview(emojiControl!)
        newView.addSubview(settingLabel)
        settingLabel.text="Dispaly sentiment marks as:"
        settingLabel.adjustsFontSizeToFitWidth=true
        settingLabel.minimumScaleFactor=0.2
        settingLabel.textColor=UIColor.black
        button=UIButton(frame: CGRect(origin: CGPoint(x: newView.frame.minX*0.7, y:newView.frame.minY) , size: CGSize(width: newView.frame.width*0.7, height: newView.frame.height/2)))
        button.setTitle("Done", for: .normal)
        button.tintColor=UIColor.white
        button.tag=1
        button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        button.backgroundColor=UIColor.red
        newView.layer.cornerRadius=6
        newView.addSubview(button)
        newView.isHidden=true
        blackView.isHidden=true
        StockChart.delegate=self
        //labelLeadingMarginInitialConstant = labelLeadingMarginConstraint.constant
        followbutton=UIBarButtonItem(title:"+ Follow", style: .plain, target: self, action: nil)
        var dict:[String:String]=defaults.dictionary(forKey: "saved") as! [String: String]
        if(dict.keys.contains(symbolName)){
            //defaults.set(dict,forKey: "saved")
            followbutton.title="Following"
        }
        followbutton.target = self;
        followbutton.action = #selector(followPressed);
        self.navigationItem.rightBarButtonItem=followbutton
        followbutton.tintColor=UIColor.white
        self.tabBarController?.tabBar.isHidden = true
        navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.02414079942, green: 0.3943191767, blue: 0.429056108, alpha: 0.8470588235)
        RangeControl.tintColor=#colorLiteral(red: 0.02414079942, green: 0.3943191767, blue: 0.429056108, alpha: 0.8470588235)
        //self.title = "AAPL";
        self.navigationController?.navigationBar.tintColor = UIColor.white;
        self.navigationController?.navigationBar.titleTextAttributes=[NSAttributedString.Key.foregroundColor: UIColor.white]
        RangeControl.removeBorders()
        //if(model.stockdictFiveMin[symbolName]==nil&&model.stockdict[symbolName]==nil){
            model.getStockJson2WCH(symbol:symbolName,range: 3){
                _ in
                model.getStockJson2WCH(symbol:self.symbolName,range: 1){
                    _ in
                    if(model.stockdict[self.symbolName]==nil||model.stockdict[self.symbolName]!.count<10){
                        DispatchQueue.main.async {
                            self.PriceOutlet.text="Error"
                            self.PriceOutlet.textColor=UIColor.red
                            self.ChangeOutlet.text="Error loading"
                            self.ChangeOutlet.layer.cornerRadius=5
                            self.ChangeOutlet.textColor=UIColor.red
                        }
                    }else{
                        DispatchQueue.main.async {
                            print("xxx")
                            print(model.stockdictFiveMin[self.symbolName])
                            self.dataReady=true
                            self.updateChart(range: self.RangeControl.selectedSegmentIndex+1)
                            
                        }
                    }
                }
            }
        
    }

        
        //print(model.stockdict.count)

        // Do any additional setup after loading the view.
   // }
    func updateChart(range:Int){
        var datapointNum=0
        var showMin=true
        switch range{
        case 1:
            datapointNum=80
        case 2:
            datapointNum=70
        case 3:
            datapointNum=23
            showMin=false
        case 4:
            datapointNum=125
            showMin=false
        case 5:
            datapointNum=250
            showMin=false
        case 6:
            datapointNum=1200
            showMin=false
        default:
            break
        }
        var series1:ChartSeries?=nil
        var last=(model.stockdictFiveMin[self.symbolName]?.count)!-1
        if(showMin){
            if((model.stockdictFiveMin[self.symbolName]?.count)!<datapointNum){
                
            }else{
                if(range==1){
                    
                    let lastthrity=(model.stockdictFiveMin[self.symbolName]?.count)!-datapointNum
                     if(last>lastthrity&&lastthrity>1){
                        series1 = ChartSeries(Array((model.stockdictFiveMin[self.symbolName]?[lastthrity..<last])!))
                     }else{
                        series1 = ChartSeries(Array((model.stockdict[self.symbolName]!)))
                    }
                }else{
                    last=(model.stockdictThirtyMin[self.symbolName]?.count)!-1
                    let lastthrity=(model.stockdictThirtyMin[self.symbolName]?.count)!-datapointNum
                         if(last>lastthrity&&lastthrity>1){
                            series1 = ChartSeries(Array((model.stockdictThirtyMin[self.symbolName]?[lastthrity..<last])!))
                         }else{
                            series1 = ChartSeries(Array((model.stockdict[self.symbolName]!)))
                    }
                }
            }
        }else{
            
                last=(model.stockdict[self.symbolName]?.count)!-1
                let lastthrity=(model.stockdict[self.symbolName]?.count)!-datapointNum
            if(last>lastthrity&&lastthrity>1){
                series1 = ChartSeries(Array((model.stockdict[self.symbolName]?[lastthrity..<last])!))
            }else{
                 series1 = ChartSeries(Array((model.stockdict[self.symbolName]!)))
            }
        }
        //let lastthrity=(model.stockdictFiveMin[self.symbolName]?.count)!-30
        //let last=(model.stockdictFiveMin[self.symbolName]?.count)!-1
        //let series1 = ChartSeries(Array(model.valueArr[lastthrity..<last]))
        //bug error handle required
        series1!.color = ChartColors.darkGreenColor()
        series1!.area = true
        // print(model.valueArr)
        DispatchQueue.main.async {
            self.StockChart.removeAllSeries()
            self.StockChart.add([series1!])
        }
        //StockChart.xLabels = [0, 3, 6, 9, 12, 15, 18, 21, 24]
        //StockChart.xLabelsFormatter = { if($1<10){return String(Int(round($1))) }else {return ""}}
        //StockChart.showXLabelsAndGrid=false
       /* let totalCount=model.stockdictFiveMin[self.symbolName]?.count
        let firstD=(Double(datapointNum)*0.2)
        let secondD=(Double(datapointNum)*0.4)
        let thirdD=(Double(datapointNum)*0.6)
        var labels:[Double]=[firstD,secondD,thirdD]
        let firtDD=model.stockdatedictFiveMin[self.symbolName]![Int(firstD)]
        var labelsAsString=[firtDD,"b","c"]
        self.StockChart.xLabels=labels
        self.StockChart.xLabelsFormatter = { (labelIndex: Int, labelValue: Double) -> String in
            return labelsAsString[labelIndex]
        }
 */
        var labelsAsString:[String]=[]
        var labels:[Double]=[]
        self.StockChart.xLabels=labels
        self.StockChart.xLabelsFormatter = { (labelIndex: Int, labelValue: Double) -> String in
            return labelsAsString[labelIndex]
        }
        let currprice=(model.stockdict[self.symbolName]?[model.stockdict[self.symbolName]!.count-1])!
        let prevprice=(model.stockdict[self.symbolName]?[model.stockdict[self.symbolName]!.count-2])!
        let change=currprice-prevprice
        let pchange=(currprice-prevprice)/prevprice*100
        DispatchQueue.main.async {
            self.PriceOutlet.text=String(format: "%.2f",currprice)
            self.ChangeOutlet.text=String(format: "%.2f",change)+"("+String(format: "%.2f", pchange)+"%)"
            self.ChangeOutlet.layer.cornerRadius=5
            self.ChangeOutlet.textColor=UIColor.white
            if(change>=0){
                self.ChangeOutlet.backgroundColor=UIColor(red: 0, green: 0.7556203008, blue: 0.1655870676, alpha: 1)
            }else{
                self.ChangeOutlet.backgroundColor=UIColor.red
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.selectedIndex = 0
        self.tabBarController?.tabBar.isHidden=false
    }

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
    }
    
    //@IBOutlet weak var SummaryHistorySwitch: UISegmentedControl!
    func didTouchChart(_ chart: Chart, indexes: Array<Int?>, x: Double, left: CGFloat) {
        if(PriceOutlet.text=="Error"||PriceOutlet.text=="Loading"){
            return
        }
        var datapointNum=0
        var showMin=true
        switch RangeControl.selectedSegmentIndex+1{
        case 1:
            datapointNum=80
        case 2:
            datapointNum=70
        case 3:
            datapointNum=23
            showMin=false
        case 4:
            datapointNum=125
            showMin=false
        case 5:
            datapointNum=250
            showMin=false
        case 6:
            datapointNum=1200
            showMin=false
        default:
            break
        }
        if let value = chart.valueForSeries(0, atIndex: indexes[0]) {
            let numberFormatter = NumberFormatter()
            numberFormatter.minimumFractionDigits = 2
            numberFormatter.maximumFractionDigits = 2
            var lastthrity=(model.stockdictFiveMin[self.symbolName]?.count)!-datapointNum
            var last=(model.stockdictFiveMin[self.symbolName]?.count)!-1
            var corrsArr=[String]()
            let myRange=RangeControl.selectedSegmentIndex+1
            if(showMin){
                if((model.stockdictFiveMin[self.symbolName]?.count)!<datapointNum){
                    
                }else{
                    if(myRange==1){
                        lastthrity=(model.stockdictFiveMin[self.symbolName]?.count)!-datapointNum
                        if(last>lastthrity&&lastthrity>1){
                            corrsArr=Array((model.stockdatedictFiveMin[self.symbolName]?[lastthrity..<last])!)
                        }else{
                            corrsArr = Array((model.stockdatedict[self.symbolName]!))
                        }
                    }else{
                        last=(model.stockdictThirtyMin[self.symbolName]?.count)!-1
                        lastthrity=(model.stockdictThirtyMin[self.symbolName]?.count)!-datapointNum
                        if(last>lastthrity&&lastthrity>1){
                            corrsArr = Array((model.stockdatedictThirtyMin[self.symbolName]?[lastthrity..<last])!)
                        }else{
                            corrsArr = Array((model.stockdatedict[self.symbolName]!))
                        }
                    }
                }
            }else{
                last=(model.stockdict[self.symbolName]?.count)!-1
                lastthrity=(model.stockdict[self.symbolName]?.count)!-datapointNum
                if(last>lastthrity&&lastthrity>1){
                    corrsArr = Array((model.stockdatedict[self.symbolName]?[lastthrity..<last])!)
                }else{
                    corrsArr = Array((model.stockdatedict[self.symbolName]!))
                }
            }
            
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
