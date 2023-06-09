//
//  SettingsViewController.swift
//  PomodomoLight
//
//  Created by Asım Altınışık on 10.05.2023.
//

import UserNotifications
import UIKit
import Lottie

class SettingsViewController: UIViewController {
    
    var isAnimationPut = false
    @IBOutlet weak var animationView: UIView!
    
    @IBOutlet weak var pomodoroSlider: UISlider!
    @IBOutlet weak var shortBreakSlider: UISlider!
    @IBOutlet weak var longBreakSlider: UISlider!
    
    
    @IBOutlet weak var pomodoroDurationLabel: UILabel!
    @IBOutlet weak var shortBreakDurationLabel: UILabel!
    @IBOutlet weak var longBreakDurationLabel: UILabel!
    
    @IBOutlet weak var notificationsSwitch: UISwitch!
    @IBOutlet weak var restoreToDefaultsButton: UIButton!
    @IBOutlet weak var soundOnCompletionSwitch: UISwitch!
    
    private let notificationCenter = UNUserNotificationCenter.current()

    override func viewDidLoad() {
        super.viewDidLoad()
        updateLabels()
    }
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setButton()
        
        if !isAnimationPut {
            putAnimation()
        }
        
        // Load the values from UserDefaults
        let defaults = UserDefaults.standard
        pomodoroSlider.value = defaults.float(forKey: "pomodoroDuration")
        shortBreakSlider.value = defaults.float(forKey: "shortBreakDuration")
        longBreakSlider.value = defaults.float(forKey: "longBreakDuration")
        soundOnCompletionSwitch.isOn = defaults.bool(forKey: "soundOnCompletion")

        // Update the switch value based on the internal variable stored in UserDefaults
        let internalNotificationsEnabled = defaults.bool(forKey: "internalNotificationsEnabled")
        notificationsSwitch.isOn = internalNotificationsEnabled
        
        // Register for UIApplicationWillEnterForeground notification
        NotificationCenter.default.addObserver(self, selector: #selector(appWillEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        
        // Check the notifications status when the view appears
        if defaults.bool(forKey: "isFirstLaunch") {
            notificationCenter.getNotificationSettings { settings in
                if settings.authorizationStatus == .authorized {
                    DispatchQueue.main.async {
                        self.notificationsSwitch.isOn = true
                    }
                } else {
                    DispatchQueue.main.async {
                        self.notificationsSwitch.isOn = false
                    }
                }
            }
        } else {
            defaults.set(false, forKey: "isFirstLaunch")
            checkNotificationsStatus()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Unregister the notification observer
        NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
    }

    @objc private func appWillEnterForeground() {
        // Check the notifications status when the app becomes active again
        checkNotificationsStatus()
    }

    private func checkNotificationsStatus() {
        // Check if notifications are enabled on the system level
        NotificationManager.shared.isNotificationsEnabled { isEnabled in
            DispatchQueue.main.async {
                // Load the values from UserDefaults
                let defaults = UserDefaults.standard
                let internalNotificationsEnabled = defaults.bool(forKey: "internalNotificationsEnabled")
                
                // Update the switch value based on the system-level notification settings
                if isEnabled {
                    // Notifications are enabled, check the internal variable
                    if internalNotificationsEnabled {
                        self.notificationsSwitch.isOn = true
                    } else {
                        self.notificationsSwitch.isOn = false
                    }
                } else {
                    // Notifications are disabled, set the switch to false
                    self.notificationsSwitch.isOn = false
                }
            }
        }
    }
    
    @IBAction func pomodoroSliderValueChanged(_ sender: Any) {
        let roundedValue = round(pomodoroSlider.value / 5) * 5
        pomodoroSlider.value = roundedValue
        updateLabels()
        saveSliderValuesToUserDefaults()
        NotificationCenter.default.post(name: .sessionDurationChanged, object: nil)
    }
    
    @IBAction func shortBreakSliderValueChanged(_ sender: Any) {
        let roundedValue = round(shortBreakSlider.value / 5) * 5
        shortBreakSlider.value = roundedValue
        updateLabels()
        saveSliderValuesToUserDefaults()
    }

    @IBAction func longBreakSliderValueChanged(_ sender: Any) {
        let roundedValue = round(longBreakSlider.value / 5) * 5
        longBreakSlider.value = roundedValue
        updateLabels()
        saveSliderValuesToUserDefaults()
    }
    
    @IBAction func notificationsSwitchValueChanged(_ sender: Any) {
        if notificationsSwitch.isOn {
            // Check if notifications are already enabled
            NotificationManager.shared.isNotificationsEnabled { isEnabled in
                if !isEnabled {
                    // Notifications are not enabled, open settings to enable them
                    guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else {
                        return
                    }
                    DispatchQueue.main.async {
                        UIApplication.shared.open(settingsURL)
                    }
                } else {
                    // Notifications are already enabled, enable notifications in your app and set the internal variable
                    // Add your code here to enable notifications and update the internal variable accordingly
                    
                    // Set the internal variable to true in UserDefaults
                    UserDefaults.standard.set(true, forKey: "internalNotificationsEnabled")
                }
            }
        } else {
            // Disable notifications in your app and set the internal variable
            // Add your code here to disable notifications and update the internal variable accordingly
            
            // Set the internal variable to false in UserDefaults
            UserDefaults.standard.set(false, forKey: "internalNotificationsEnabled")
        }
    }


    @IBAction func soundOnCompletionValueChanged(_ sender: Any) {
        let defaults = UserDefaults.standard
            defaults.set(soundOnCompletionSwitch.isOn, forKey: "soundOnCompletion")
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
        
        updateLabels()
        NotificationCenter.default.post(name: .sessionDurationChanged, object: nil)
    }
    private func setButton() {
        restoreToDefaultsButton.backgroundColor = .red
        restoreToDefaultsButton.layer.cornerRadius = 20
        restoreToDefaultsButton.tintColor = .white
        
        notificationsSwitch.onTintColor = UIColor.red
        soundOnCompletionSwitch.onTintColor = UIColor.red
    }
    
    private func updateLabels() {
        let defaults = UserDefaults.standard
        let pomodoroDuration = Int(defaults.float(forKey: "pomodoroDuration"))
        let shortBreakDuration = Int(defaults.float(forKey: "shortBreakDuration"))
        let longBreakDuration = Int(defaults.float(forKey: "longBreakDuration"))
        
        pomodoroDurationLabel.text = "\(pomodoroDuration)m"
        shortBreakDurationLabel.text = "\(shortBreakDuration)m"
        longBreakDurationLabel.text = "\(longBreakDuration)m"
    }
    
    private func saveSliderValuesToUserDefaults() {
        let defaults = UserDefaults.standard
        defaults.set(Int(round(pomodoroSlider.value)), forKey: "pomodoroDuration")
        defaults.set(Int(round(shortBreakSlider.value)), forKey: "shortBreakDuration")
        defaults.set(Int(round(longBreakSlider.value)), forKey: "longBreakDuration")
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

extension Notification.Name {
    static let sessionDurationChanged = Notification.Name("sessionDurationChanged")
}
