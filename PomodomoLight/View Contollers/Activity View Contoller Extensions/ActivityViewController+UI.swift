//
//  ActivityViewController+UI.swift
//  PomodomoLight
//
//  Created by Asım Altınışık on 26.05.2023.
//

import Foundation
import UIKit

extension ActivityViewController{
    func setStartButton() {
        startButton.backgroundColor = .red
        startButton.layer.cornerRadius = 20
        startButton.tintColor = .white
    }
    
    func setResetButton() {
        resetButton.backgroundColor = .orange
        resetButton.layer.cornerRadius = 15
        resetButton.tintColor = .white
    }
    
    func updateTimeLabel() {
        let minutes = Int(isOnBreak ? remainingShortBreakTime : remainingSessionTime) / 60
        let seconds = Int(isOnBreak ? remainingShortBreakTime : remainingSessionTime) % 60
        timeLeftLabel.text = String(format: "%02d:%02d", minutes, seconds)
    }
    
    func updateIndicators() {
        let indicators: [UIImageView] = [
            firstPomodoroIndicator,
            secondPomodoroIndicator,
            thirdPomodoroIndicator,
            fourthPomodoroIndicator
        ]
        
        for i in 0..<completedSessions {
            indicators[i].image = indicators[i].image?.withRenderingMode(.alwaysTemplate)
            indicators[i].tintColor = .clear
            indicators[i].backgroundColor = .green
            indicators[i].layer.cornerRadius = indicators[i].bounds.width / 2
        }
        
        if completedSessions < 4 {
            for i in completedSessions..<4 {
                indicators[i].image = indicators[i].image?.withRenderingMode(.alwaysTemplate)
                indicators[i].tintColor = .label
                indicators[i].backgroundColor = .clear
                indicators[i].layer.cornerRadius = 0
            }
        } else {
            resetIndicators()
        }
    }
    
    func resetIndicators() {
        let indicators: [UIImageView] = [
            firstPomodoroIndicator,
            secondPomodoroIndicator,
            thirdPomodoroIndicator,
            fourthPomodoroIndicator
        ]
        
        for indicator in indicators {
            indicator.image = indicator.image?.withRenderingMode(.alwaysTemplate)
            indicator.tintColor = .label
            indicator.backgroundColor = .clear
            indicator.layer.cornerRadius = 0
        }
    }
    
    func updateSayingLabel(category: StatementCategory) {
        let statements: [String]
        switch category {
        case .session:
            statements = sessionStatements
        case .break:
            statements = breakStatements
        case .pause:
            statements = pauseStatements
        case .launch:
            statements = launchStatements
        }
        
        let randomIndex = Int.random(in: 0..<statements.count)
        sayingLabel.text = statements[randomIndex]
    }
}
