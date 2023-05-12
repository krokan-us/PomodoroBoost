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
    @IBOutlet weak var thisWeekButton: UIButton!
    @IBOutlet weak var sessionHistoryChart: BarChartView!
    var currentWeek = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(refreshHistoryChart), name: .sessionCompleted, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateChart()
        setButton()
        previousWeekButton.setTitle("", for: .normal)
        nextWeekButton.setTitle("", for: .normal)
        displayWeekLabel(for: currentWeek)
    }
    
    @objc func refreshHistoryChart() {
        updateChart()
    }
    
    func updateChart() {
        // Update the chart based on currentWeek
        let startOfWeek = Calendar.current.date(from: Calendar.current.dateComponents([.yearForWeekOfYear, .weekOfYear], from: currentWeek))!
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
        dataSet.colors = [UIColor.red]
        dataSet.valueFont = UIFont.systemFont(ofSize: 15)
        let data = BarChartData(dataSet: dataSet)
        sessionHistoryChart.data = data
        sessionHistoryChart.xAxis.valueFormatter = IndexAxisValueFormatter(values: dayNames)
        sessionHistoryChart.xAxis.granularity = 1
        sessionHistoryChart.xAxis.labelPosition = .bottom
        sessionHistoryChart.xAxis.drawGridLinesEnabled = false
        sessionHistoryChart.leftAxis.drawGridLinesEnabled = false
        sessionHistoryChart.xAxis.drawAxisLineEnabled = false
        sessionHistoryChart.leftAxis.drawAxisLineEnabled = false
        sessionHistoryChart.rightAxis.enabled = false
        sessionHistoryChart.legend.enabled = false
        sessionHistoryChart.chartDescription.enabled = false
        sessionHistoryChart.leftAxis.axisMinimum = 0
    }
    
    func displayWeekLabel(for date: Date) {
        let calendar = Calendar.current
        let weekOfYear = calendar.component(.weekOfYear, from: date)
        let year = calendar.component(.year, from: date)
        var startOfWeek = Date()
        var interval: TimeInterval = 0
        _ = calendar.dateInterval(of: .weekOfYear, start: &startOfWeek, interval: &interval, for: date)
        let endOfWeek = startOfWeek.addingTimeInterval(interval - 1)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d"
        let startOfWeekString = dateFormatter.string(from: startOfWeek)
        let endOfWeekString = dateFormatter.string(from: endOfWeek)
        DispatchQueue.main.async{
            self.weekLabel.text = "\(startOfWeekString) - \(endOfWeekString)"
            self.currentWeek = startOfWeek
            self.updateChart()
            self.checkIfCurrentWeek()
        }
    }

    @IBAction func previousWeekButtonTapped(_ sender: UIButton) {
        currentWeek = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: currentWeek)!
        displayWeekLabel(for: currentWeek)
    }
    
    @IBAction func nextWeekButtonTapped(_ sender: UIButton) {
        currentWeek = Calendar.current.date(byAdding: .weekOfYear, value: 1, to: currentWeek)!
        displayWeekLabel(for: currentWeek)
    }
    
    @IBAction func thisWeekButtonTapped(_ sender: Any) {
        currentWeek = Date() // Set currentWeek to today's date
        displayWeekLabel(for: currentWeek)
    }
    private func setButton() {
        thisWeekButton.backgroundColor = .red
        thisWeekButton.layer.cornerRadius = 15
        thisWeekButton.tintColor = .white
    }
    
    private func checkIfCurrentWeek() {
        let calendar = Calendar.current
        let currentWeekOfYear = calendar.component(.weekOfYear, from: Date())
        let displayingWeekOfYear = calendar.component(.weekOfYear, from: currentWeek)
        if currentWeekOfYear == displayingWeekOfYear {
            nextWeekButton.isEnabled = false
            thisWeekButton.isHidden = true
        } else {
            nextWeekButton.isEnabled = true
            thisWeekButton.isHidden = false
        }
    }
}

