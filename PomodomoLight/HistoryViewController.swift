//
//  HistoryViewController.swift
//  PomodomoLight
//
//  Created by Asım Altınışık on 9.05.2023.
//

import UIKit
import Charts


class HistoryViewController: UIViewController {
        
    @IBOutlet weak var sessionHistoryChart: LineChartView!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateChart()
    }
    
    func updateChart() {
        let now = Date()
        let startOfWeek = Calendar.current.date(from: Calendar.current.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now))!
        var dataEntries: [ChartDataEntry] = []
        for i in 0..<7 {
            let date = Calendar.current.date(byAdding: .day, value: i, to: startOfWeek)!
            let sessions = SessionManager.shared.fetchSessions(forDate: date)
            let totalDuration = sessions.reduce(0) { (result, session) -> Int in
                result + (session.value(forKey: "duration") as! Int)
            }
            let dataEntry = ChartDataEntry(x: Double(i), y: Double(totalDuration))
            dataEntries.append(dataEntry)
        }
        let dataSet = LineChartDataSet(entries: dataEntries, label: "Study Time")
        let data = LineChartData(dataSet: dataSet)
        sessionHistoryChart.data = data
    }

}
