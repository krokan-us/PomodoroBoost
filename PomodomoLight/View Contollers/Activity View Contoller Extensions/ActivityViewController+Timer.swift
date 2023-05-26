//
//  ActivityViewController+Timer.swift
//  PomodomoLight
//
//  Created by Asım Altınışık on 26.05.2023.
//

import AVFoundation
import Foundation
import UIKit

extension ActivityViewController{
    func startTimer() {
        // Invalidate and set timer to nil before starting a new timer
        hasTimerStarted = true
        timer?.invalidate()
        timer = nil
        
        resetButton.isHidden = false
        
        // Update session and break durations from UserDefaults
        sessionTime = TimeInterval(defaults.float(forKey: "pomodoroDuration")) * 1
        shortBreakTime = TimeInterval(defaults.float(forKey: "shortBreakDuration")) * 1
        longBreakTime = TimeInterval(defaults.float(forKey: "longBreakDuration")) * 1
        
        if isOnBreak {
            SessionManager.shared.updateBreaksStarted(count: 1)
        } else {
            SessionManager.shared.updatePomodorosStarted(count: 1)
            NotificationCenter.default.post(name: .sessionCompleted, object: nil)
        }
        
        // Schedule notification for the remaining time
        let timeInterval = isOnBreak ? remainingShortBreakTime : remainingSessionTime
        NotificationManager.shared.scheduleTimerNotification(timeInterval: timeInterval, isBreak: isOnBreak)

        progressBar.putAnimation(animationName: isOnBreak ? "astronautInMug" : "astronautOnARocket")
        progressBar.barColor = isOnBreak ? .green : .red // update the bar color
        
        startButton.setTitle("Pause", for: .normal)
        timerState = isOnBreak ? .shortBreak : .session
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateCountdown), userInfo: nil, repeats: true)
        updateSayingLabel(category: isOnBreak ? .break : .session)
    }
    
    func pauseTimer() {
        startButton.setTitle("Continue", for: .normal)
        progressBar.putAnimation(animationName: "astronautHoldingAStar")
        timerState = .paused
        timer?.invalidate()
        timer = nil
        wasOnBreak = isOnBreak // Remember whether we were on break or not
        updateSayingLabel(category: .pause)
        
        // Remove the pending timer notification
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["timerEndedNotification"])

        // Invalidate the scheduled notification
        let identifier = isOnBreak ? "breakEndedNotification" : "sessionEndedNotification"
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    }
    
    func continueTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateCountdown), userInfo: nil, repeats: true)
        startButton.setTitle("Pause", for: .normal)
        
        // Reschedule the timer notification for the remaining time
        let timeInterval = wasOnBreak ? remainingShortBreakTime : remainingSessionTime
        NotificationManager.shared.scheduleTimerNotification(timeInterval: timeInterval, isBreak: wasOnBreak)

        progressBar.putAnimation(animationName: wasOnBreak ? "astronautInMug" : "astronautOnARocket")
        timerState = wasOnBreak ? .shortBreak : .session // Restore the state we had before pausing
        updateSayingLabel(category: wasOnBreak ? .break : .session)
    }
    
    func resetTimer() {
        // Invalidate and set timer to nil before resetting the timer
        timer?.invalidate()
        timer = nil

        isOnBreak = false
        remainingSessionTime = sessionTime
        updateTimeLabel()
        startButton.setTitle("Pause", for: .normal)
        startTimer()
        isTimerRunning = false

        if completedSessions == 4 {
            updateIndicators() // Update the indicators
            completedSessions = 0 // Reset the completed sessions count
        }
        
        // Remove the pending timer notification
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["timerEndedNotification"])
        
        // Invalidate the scheduled notification
        let identifier = isOnBreak ? "breakEndedNotification" : "sessionEndedNotification"
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    }
    
    func updateTime(_ time: inout TimeInterval) {
        time -= 1
    }
    
    @objc func updateCountdown() {
        DispatchQueue.main.async {
            if self.isOnBreak {
                self.updateTime(&self.remainingShortBreakTime)
            } else {
                self.updateTime(&self.remainingSessionTime)
            }
            
            self.updateTimeLabel()
            
            let progress = CGFloat(1 - (self.isOnBreak ? self.remainingShortBreakTime : self.remainingSessionTime) / (self.isOnBreak ? self.shortBreakTime : self.sessionTime))
            self.progressBar.progress = progress
            
            if self.isOnBreak {
                if self.remainingShortBreakTime <= 0 {
                    self.timer?.invalidate()
                    self.resetTimer()
                    self.playTimerEndedSound()
                    SessionManager.shared.updateBreaksCompleted(count: 1)
                    SessionManager.shared.updateBreaksMinutes(duration: self.shortBreakTime)
                    NotificationCenter.default.post(name: .breakCompleted, object: nil)
                    let defaults = UserDefaults.standard
                    let internalNotificationsEnabled = defaults.bool(forKey: "internalNotificationsEnabled")
                    if internalNotificationsEnabled{
                        NotificationManager.shared.sendBreakEndedNotification() // Send "breakEnded" notification
                    }
                }
            } else {
                if self.remainingSessionTime <= 0 {
                    self.timer?.invalidate()
                    self.startBreak()
                    self.playTimerEndedSound()
                    SessionManager.shared.updatePomodorosCompleted(count: 1)
                    SessionManager.shared.updatePomodorosMinutes(duration: self.sessionTime)
                    NotificationCenter.default.post(name: .sessionCompleted, object: nil)
                    let defaults = UserDefaults.standard
                    let internalNotificationsEnabled = defaults.bool(forKey: "internalNotificationsEnabled")
                    if internalNotificationsEnabled{
                        NotificationManager.shared.sendSessionEndedNotification() // Send "sessionEnded" notification
                    }
                }
            }
        }
    }
    
    func playTimerEndedSound() {
        let defaults = UserDefaults.standard
        let soundOnCompletion = defaults.bool(forKey: "soundOnCompletion")
        
        if soundOnCompletion && UIApplication.shared.applicationState == .active {
            AudioServicesPlaySystemSound(timerEndedSoundID)
        }
    }
}
