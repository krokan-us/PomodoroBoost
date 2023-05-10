//
//  SettingsViewController.swift
//  PomodomoLight
//
//  Created by Asım Altınışık on 10.05.2023.
//

import UIKit

class SettingsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.selectedIndex = 1
    }
}
