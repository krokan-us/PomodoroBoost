//
//  SettingsViewController.swift
//  PomodomoLight
//
//  Created by Asım Altınışık on 10.05.2023.
//

import UIKit
import Lottie

class SettingsViewController: UIViewController {
    
    var isAnimationPut = false
    @IBOutlet weak var animationView: UIView!
    
    @IBOutlet weak var pomodoroSlider: UISlider!
    @IBOutlet weak var shortBreakSlider: UISlider!
    @IBOutlet weak var longBreakSlider: UISlider!
    @IBOutlet weak var roundsSlider: UISlider!
    
    
    @IBOutlet weak var pomodoroDurationLabel: UILabel!
    @IBOutlet weak var shortBreakDurationLabel: UILabel!
    @IBOutlet weak var longBreakDurationLabel: UILabel!
    @IBOutlet weak var roundsLabel: UILabel!
    
    @IBOutlet weak var restoreToDefaultsButton: UIButton!
   
    override func viewDidLoad() {
        super.viewDidLoad()
        updateLabels()
    }
    

    override func viewWillAppear(_ animated: Bool) {
        setButton()
        
        if !isAnimationPut{
            putAnimation()
        }
        // Load the slider values from user defaults
        let defaults = UserDefaults.standard
        pomodoroSlider.value = defaults.float(forKey: "pomodoroDuration")
        shortBreakSlider.value = defaults.float(forKey: "shortBreakDuration")
        longBreakSlider.value = defaults.float(forKey: "longBreakDuration")
        roundsSlider.value = defaults.float(forKey: "rounds")
    }
    
    @IBAction func pomodoroSliderValueChanged(_ sender: Any) {
        updateLabels()
        saveSliderValuesToUserDefaults()
    }
    
    @IBAction func shortBreakSliderValueChanged(_ sender: Any) {
        updateLabels()
        saveSliderValuesToUserDefaults()
    }
    
    @IBAction func longBreakSliderValueChanged(_ sender: Any) {
        updateLabels()
        saveSliderValuesToUserDefaults()
    }
    
    @IBAction func roundsSliderValueChanged(_ sender: Any) {
        updateLabels()
        saveSliderValuesToUserDefaults()
    }
    
    @IBAction func restoreButtonTapped(_ sender: Any) {
        let defaults = UserDefaults.standard
        defaults.set(25, forKey: "pomodoroDuration")
        defaults.set(5, forKey: "shortBreakDuration")
        defaults.set(30, forKey: "longBreakDuration")
        defaults.set(4, forKey: "rounds")
        
        pomodoroSlider.value = defaults.float(forKey: "pomodoroDuration")
        shortBreakSlider.value = defaults.float(forKey: "shortBreakDuration")
        longBreakSlider.value = defaults.float(forKey: "longBreakDuration")
        roundsSlider.value = defaults.float(forKey: "rounds")
        
        updateLabels()
    }
    private func setButton() {
        restoreToDefaultsButton.backgroundColor = .red
        restoreToDefaultsButton.layer.cornerRadius = 20
        restoreToDefaultsButton.tintColor = .white
    }
    
    private func updateLabels() {
        let defaults = UserDefaults.standard
        let pomodoroDuration = Int(defaults.float(forKey: "pomodoroDuration"))
        let shortBreakDuration = Int(defaults.float(forKey: "shortBreakDuration"))
        let longBreakDuration = Int(defaults.float(forKey: "longBreakDuration"))
        let rounds = Int(roundsSlider.value)
        
        pomodoroDurationLabel.text = "\(pomodoroDuration)m"
        shortBreakDurationLabel.text = "\(shortBreakDuration)m"
        longBreakDurationLabel.text = "\(longBreakDuration)m"
        roundsLabel.text = "\(rounds)"
    }
    
    private func saveSliderValuesToUserDefaults() {
        let defaults = UserDefaults.standard
        defaults.set(pomodoroSlider.value, forKey: "pomodoroDuration")
        defaults.set(shortBreakSlider.value, forKey: "shortBreakDuration")
        defaults.set(longBreakSlider.value, forKey: "longBreakDuration")
        defaults.set(roundsSlider.value, forKey: "rounds")
        defaults.synchronize()
    }
    
    private func putAnimation(){
        isAnimationPut = true
        let settingsAnimation = LottieAnimationView(name: "rocketTransperentAnimation")
        settingsAnimation.frame = animationView.bounds
        settingsAnimation.contentMode = .scaleAspectFit
        animationView.addSubview(settingsAnimation)
        settingsAnimation.loopMode = .loop
        settingsAnimation.play()
    }
}
