//
//  HistoryViewController.swift
//  PomodomoLight
//
//  Created by Asım Altınışık on 9.05.2023.
//

import UIKit
import Charts

class HistoryViewController: UIViewController {
        
    @IBOutlet weak var previousWeekButton: UIButton!
    @IBOutlet weak var nextWeekButton: UIButton!
    @IBOutlet weak var weekLabel: UILabel!
    @IBOutlet weak var sessionHistoryChart: BarChartView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateChart()
        previousWeekButton.setTitle("", for: .normal)
        nextWeekButton.setTitle("", for: .normal)
        weekLabel.text = "8 May - 14 May"
    }
    
    func updateChart() {
        let now = Date()
        let startOfWeek = Calendar.current.date(from: Calendar.current.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now))!
        var dataEntries: [BarChartDataEntry] = []
        let dayNames = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
        for i in 0..<7 {
            let date = Calendar.current.date(byAdding: .day, value: i, to: startOfWeek)!
            let sessions = SessionManager.shared.fetchSessions(forDate: date)
            var totalDuration = sessions.reduce(0) { (result, session) -> Int in
                result + (session.value(forKey: "duration") as! Int)
            }
            totalDuration = totalDuration / 60
            let dataEntry = BarChartDataEntry(x: Double(i), y: Double(totalDuration))
            dataEntries.append(dataEntry)
        }
        let dataSet = BarChartDataSet(entries: dataEntries, label: "Study Time")
        
        // Set the color of the bars.
        dataSet.colors = [UIColor.red]
        
        // Set the font size of the value labels
        dataSet.valueFont = UIFont.systemFont(ofSize: 15)
        
        let data = BarChartData(dataSet: dataSet)
        sessionHistoryChart.data = data
        
        // Customize x-axis to display day names
        sessionHistoryChart.xAxis.valueFormatter = IndexAxisValueFormatter(values: dayNames)
        sessionHistoryChart.xAxis.granularity = 1
        
        // Move x-axis labels to the bottom
        sessionHistoryChart.xAxis.labelPosition = .bottom
        
        // Remove grid lines
        sessionHistoryChart.xAxis.drawGridLinesEnabled = false
        sessionHistoryChart.leftAxis.drawGridLinesEnabled = false
        
        // Remove axis lines
        sessionHistoryChart.xAxis.drawAxisLineEnabled = false
        sessionHistoryChart.leftAxis.drawAxisLineEnabled = false
        
        // Remove right y-axis
        sessionHistoryChart.rightAxis.enabled = false
        
        // Remove legend
        sessionHistoryChart.legend.enabled = false
        
        // Remove description
        sessionHistoryChart.chartDescription.enabled = false
    }


}
