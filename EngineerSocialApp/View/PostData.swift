//
//  PostDataView.swift
//  EngineerSocialApp
//
//  Created by Yoki on 2017/12/30.
//

import UIKit
import Charts

protocol PostDataViewDelegate: class {
    func didScrollToBottom(y: CGFloat) -> Void
    func didScrollToTop(y: CGFloat) -> Void
}

class PostDataView: UIView {
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    // アクション数を表示するラベル
    @IBOutlet weak var smileCountLabel: UILabel!
    @IBOutlet weak var heartCountLabel: UILabel!
    @IBOutlet weak var cryCountLabel: UILabel!
    @IBOutlet weak var clapCountLabel: UILabel!
    @IBOutlet weak var okCountLabel: UILabel!

    // 円グラフのview
    @IBOutlet weak var useLanguageChart: PieChartView!
    @IBOutlet weak var developThingsChart: PieChartView!
    
    weak var delegate: PostDataViewDelegate?
    
    enum ChartContents {
        case devLanguage
        case devThings
    }
    
    // PostDataのViewを最初に生成する際に、ここにユーザーの開発データを入れて円グラフで表示する
    //var devLanguageDataArray = [DevelopData]()
    
    override init(frame: CGRect){
        super.init(frame: frame)
        loadNib()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        loadNib()
    }
    
    func loadNib(){
        let view = Bundle.main.loadNibNamed("PostDataView", owner: self, options: nil)?.first as! UIView
        view.frame = self.bounds
        self.scrollView.delegate = self
        self.addSubview(view)
    }
    
    func setGetActionsCountLabel(smileCount: String, heartCount: String, cryCount: String, clapCount: String, okCount: String)
    {
        smileCountLabel.text = smileCount
        heartCountLabel.text = heartCount
        cryCountLabel.text = cryCount
        clapCountLabel.text = clapCount
        okCountLabel.text = okCount
    }
    
    /// 開発言語の円グラフをセットアップする
    func setupDevLangsPieChartView(developDataArray: [DevelopData]) {
        // 円グラフに表示するデータを設定する
        var dataEntries = [PieChartDataEntry]()
        if developDataArray.count != 0 {
            // ユーザーが投稿しており、取得データがある場合
            let countSum = dataCountSum(developDataArray: developDataArray, chartContent: ChartContents.devLanguage)
            for data in developDataArray {
                dataEntries.append(PieChartDataEntry(value: Double(data.languageCount!)/countSum * 100.0,
                                                     label: data.devLanguage,
                                                     icon: nil))
                
            }
        } else {
            // FIXME: 上にブラーをかけたい（あと、開発言語・項目どちらの場合でも言語要素を表示しているので余裕あれば修正）。ユーザーが投稿していない場合はサンプルデータを表示する
            let sampleLanguageArray = ["Ruby","Swift","Kotlin","Phython"]
            for index in (1...4).reversed() {
                dataEntries.append(PieChartDataEntry(value: Double(index) * 10.0,
                                                     label: sampleLanguageArray[index-1],
                                                     icon: nil))
            }
        }
        
        let set = PieChartDataSet(values: dataEntries, label: "")
        set.drawIconsEnabled = false
        set.sliceSpace = 2
        
        // FIXME: 色修正
        set.colors = ChartColorTemplates.vordiplom()
            + ChartColorTemplates.joyful()
            + ChartColorTemplates.colorful()
            + ChartColorTemplates.liberty()
            + ChartColorTemplates.pastel()
            + [UIColor(red: 51/255, green: 181/255, blue: 229/255, alpha: 1)]
        
        let data = PieChartData(dataSet: set)
        
        let pFormatter = NumberFormatter()
        pFormatter.numberStyle = .percent
        // 小数点第一位までを使用
        pFormatter.maximumFractionDigits = 1
        pFormatter.multiplier = 1
        pFormatter.percentSymbol = " %"
        data.setValueFormatter(DefaultValueFormatter(formatter: pFormatter))
        
        data.setValueFont(.systemFont(ofSize: 15, weight: .heavy))
        data.setValueTextColor(.white)
        
        useLanguageChart.centerText = "Use Language"
        useLanguageChart.legend.enabled = false
        useLanguageChart.chartDescription?.enabled = false
        useLanguageChart.rotationEnabled = false
        useLanguageChart.data = data
        useLanguageChart.highlightValues(nil)
    }
    
    /// 開発項目の円グラフをセットアップする
    func setupDevThingsPieChartView(developDataArray: [DevelopData]) {
        // 円グラフに表示するデータを設定する
        var dataEntries = [PieChartDataEntry]()
        if developDataArray.count != 0 {
            // ユーザーが投稿しており、取得データがある場合
            let countSum = dataCountSum(developDataArray: developDataArray, chartContent: ChartContents.devThings)
            for data in developDataArray {
                dataEntries.append(PieChartDataEntry(value: Double(data.doCount!)/countSum * 100.0,
                                                     label: data.toDo,
                                                     icon: nil))
            }
        } else {
            // FIXME: 上にブラーをかけたい（あと、開発言語・項目どちらの場合でも言語要素を表示しているので余裕あれば修正）。ユーザーが投稿していない場合はサンプルデータを表示する
            let sampleLanguageArray = ["アプリ","サーバー","インフラ","FIX"]
            for index in (1...4).reversed() {
                dataEntries.append(PieChartDataEntry(value: Double(index) * 10.0,
                                                     label: sampleLanguageArray[index-1],
                                                     icon: nil))
            }
        }
        
        let set = PieChartDataSet(values: dataEntries, label: "")
        set.drawIconsEnabled = false
        set.sliceSpace = 2
        
        set.colors = ChartColorTemplates.vordiplom()
            + ChartColorTemplates.joyful()
            + ChartColorTemplates.colorful()
            + ChartColorTemplates.liberty()
            + ChartColorTemplates.pastel()
            + [UIColor(red: 51/255, green: 181/255, blue: 229/255, alpha: 1)]
        
        let data = PieChartData(dataSet: set)
        
        let pFormatter = NumberFormatter()
        pFormatter.numberStyle = .percent
        // 小数点第一位までを使用
        pFormatter.maximumFractionDigits = 1
        pFormatter.multiplier = 1
        pFormatter.percentSymbol = " %"
        data.setValueFormatter(DefaultValueFormatter(formatter: pFormatter))
        
        data.setValueFont(.systemFont(ofSize: 15, weight: .heavy))
        data.setValueTextColor(.white)
        
        developThingsChart.centerText = "Do"
        developThingsChart.legend.enabled = false
        developThingsChart.chartDescription?.enabled = false
        developThingsChart.rotationEnabled = false
        developThingsChart.data = data
        developThingsChart.highlightValues(nil)
    }
    
    /// ユーザーが使用した開発言語データを円グラフで「%」表示にしたいので、割合計算時の分母を作る
    ///
    /// - Parameter developDataArray: dbから取得した投稿データ
    /// - Returns: 分母として使う数字
    func dataCountSum(developDataArray: [DevelopData], chartContent: ChartContents) -> Double {
        var countSum = 0.0
        
        switch chartContent {
        case ChartContents.devLanguage:
            for data in developDataArray {
                countSum += Double(data.languageCount!)
            }
        case ChartContents.devThings:
            for data in developDataArray {
                countSum += Double(data.doCount!)
            }
        }
        return countSum
    }
    
    func animationDevLangsChart() {
        useLanguageChart.animate(xAxisDuration: 1.4, easingOption: .easeOutBack)
    }
    
    func animationDevThingsChart() {
        developThingsChart.animate(xAxisDuration: 1.4, easingOption: .easeOutBack)
    }
}

extension PostDataView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y > 0{
            self.delegate?.didScrollToBottom(y: scrollView.contentOffset.y)
        }else if scrollView.contentOffset.y < 0 {
            // cellの0番目以前はみせないようにする
            //            scrollView.contentOffset = CGPoint(x: 0, y: 0)
            self.delegate?.didScrollToTop(y: scrollView.contentOffset.y)
        }
    }
}
