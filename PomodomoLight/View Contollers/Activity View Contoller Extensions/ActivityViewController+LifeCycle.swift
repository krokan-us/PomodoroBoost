//
//  ActivityViewController+LifeCycle.swift
//  PomodomoLight
//
//  Created by Asım Altınışık on 26.05.2023.
//

import Foundation
import UIKit

extension ActivityViewController{
    
    override func viewDidLoad() {
        super.viewDidLoad()

        sessionTime = TimeInterval(defaults.float(forKey: "pomodoroDuration")) * 1
        shortBreakTime = TimeInterval(defaults.float(forKey: "shortBreakDuration")) * 1
        longBreakTime = TimeInterval(defaults.float(forKey: "longBreakDuration")) * 1

        remainingSessionTime = sessionTime
        remainingShortBreakTime = shortBreakTime
        remainingLongBreakTime = longBreakTime
        
        NotificationCenter.default.addObserver(self, selector: #selector(refreshLabelIfSessionNotStarted), name: .sessionDurationChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    @objc func applicationDidEnterBackground() {
        // Store the current time when the app enters the background
        backgroundTime = Date()
    }
    
    @objc func applicationWillEnterForeground() {
        backgroundQueue.async {
            if let backgroundTime = self.backgroundTime {
                let elapsedBackgroundTime = Date().timeIntervalSince(backgroundTime)
                
                DispatchQueue.main.async {
                    if self.isOnBreak {
                        self.remainingShortBreakTime -= elapsedBackgroundTime
                        if self.remainingShortBreakTime <= 0 {
                            // The break time has elapsed
                            self.resetTimer()
                            self.playTimerEndedSound()
                            SessionManager.shared.updateBreaksCompleted(count: 1)
                            SessionManager.shared.updateBreaksMinutes(duration: self.shortBreakTime)
                            NotificationCenter.default.post(name: .breakCompleted, object: nil)
                            let defaults = UserDefaults.standard
                            let internalNotificationsEnabled = defaults.bool(forKey: "internalNotificationsEnabled")
                            if internalNotificationsEnabled {
                                NotificationManager.shared.sendBreakEndedNotification()
                            }
                        }
                    } else {
                        self.remainingSessionTime -= elapsedBackgroundTime
                        if self.remainingSessionTime <= 0 {
                            // The session time has elapsed
                            self.startBreak()
                            self.playTimerEndedSound()
                            SessionManager.shared.updatePomodorosCompleted(count: 1)
                            SessionManager.shared.updatePomodorosMinutes(duration: self.sessionTime)
                            NotificationCenter.default.post(name: .sessionCompleted, object: nil)
                            let defaults = UserDefaults.standard
                            let internalNotificationsEnabled = defaults.bool(forKey: "internalNotificationsEnabled")
                            if internalNotificationsEnabled {
                                NotificationManager.shared.sendSessionEndedNotification()
                            }
                        }
                    }
                    
                    // Reset the stored background time
                    self.backgroundTime = nil
                    
                    // Restart the timer if it was previously running
                    if self.timerState == .session || self.timerState == .shortBreak {
                        self.startTimer()
                    }
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !hasTimerStarted {
            startButton.setTitle("Start", for: .normal)
            progressBar.putAnimation(animationName: "astronautOperatingLaptop")
            setStartButton()
            setResetButton()
            resetButton.isHidden = true
            updateTimeLabel()
            updateSayingLabel(category: .launch)
        }else{
            if !isOnBreak{
                resetButton.isHidden = false
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        hasViewDisappeared = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        hasViewDisappeared = false
    }
}
