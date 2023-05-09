//
//  HistoryViewController.swift
//  PomodomoLight
//
//  Created by Asım Altınışık on 9.05.2023.
//

import UIKit

class HistoryViewController: UIViewController {

    @IBOutlet weak var totalSession: UILabel!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the initial value for the label
        totalSession.text = UserDefaults.standard.string(forKey: "totalWorkTime")
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateTotalWorkTime), name: NSNotification.Name(rawValue: "TotalWorkTimeUpdated"), object: nil)
    }
    
    @objc func updateTotalWorkTime() {
        // Update the label with the new totalWorkTime value from UserDefaults
        totalSession.text = "\(UserDefaults.standard.integer(forKey: "totalWorkTime"))"
    }
    
}
