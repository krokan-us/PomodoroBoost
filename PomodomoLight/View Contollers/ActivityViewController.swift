//
//  ActivityViewController.swift
//  PomodomoLight
//
//  Created by Asım Altınışık on 8.05.2023.
//

import UIKit
import AVFoundation

class ActivityViewController: UIViewController {
    
    @IBOutlet weak var progressBar: CircularProgressBar!
    @IBOutlet weak var timeLeftLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var sayingLabel: UILabel!
    @IBOutlet weak var firstPomodoroIndicator: UIImageView!
    @IBOutlet weak var secondPomodoroIndicator: UIImageView!
    @IBOutlet weak var thirdPomodoroIndicator: UIImageView!
    @IBOutlet weak var fourthPomodoroIndicator: UIImageView!
    
    var completedSessions: Int = 0
    var timer: Timer?
    var isOnBreak = false
    var hasTimerStarted = false
    var isTimerRunning = false
    var hasViewDisappeared: Bool = false
    var wasOnBreak = false
    let timerEndedSoundID: SystemSoundID = 1005
    private var backgroundTask: UIBackgroundTaskIdentifier = .invalid
    var backgroundTime: Date?
    let backgroundQueue = DispatchQueue(label: "com.pomodoroLight.backgroundQueue", qos: .background)

    let defaults = UserDefaults.standard

    var timerState: TimerState = .notStarted
    
    enum TimerState {
        case notStarted
        case session
        case shortBreak
        case longBreak
        case paused
    }
    
    enum StatementCategory {
        case session, `break`, pause, launch
    }

    var sessionTime: TimeInterval = 0
    var shortBreakTime: TimeInterval = 0
    var longBreakTime: TimeInterval = 0
    
    var remainingSessionTime: TimeInterval = 0
    var remainingShortBreakTime: TimeInterval = 0
    var remainingLongBreakTime: TimeInterval = 0

    
    let sessionStatements: [String] = [
    "🚀 Let's work!",
    "💪 Hustle time!",
    "🎯 Focus on goals!",
    "🔥 Ignite passion!",
    "🌟 You've got this!",
    "🏆 Keep winning!",
    "💼 Game face on!",
    "📈 Exceed expectations!",
    "👩‍💻 Create magic!",
    "🧠 Use our brains!",
    "💥 Make an impact!",
    "🔍 Pay attention!",
    "🙌 Embrace challenges!",
    "🎬 Take action!",
    "🎨 Creativity is key!",
    "🚧 Keep building!",
    "💪 Persevere through!"
]
    
    let breakStatements: [String] = [
    "☕️ Time for a break!",
    "😌 Relax a bit!",
    "🏖️ Take it easy!",
    "🧘‍♀️ Clear your mind!",
    "🌴 Rest and recharge!",
    "👣 Take a walk!",
    "🌞 Get some fresh air!",
    "🎶 Listen to some music!",
    "📖 Read a book!",
    "💤 Take a power nap!",
    "🧁 Treat yourself!",
    "🤗 Connect with a friend!"
]
    
    let pauseStatements: [String] = [
    "⏸️ Paused!",
    "🛑 Take a moment!",
    "⏹️ Hold on!",
    "🕰️ Time out!"
]
    
    let launchStatements: [String] = [
        "👋 Welcome!",
        "🚀 Get ready!",
        "💻 Ready to work!",
        "👨‍💻 Let's do this!",
        "🧑‍🤝‍🧑 Let's collaborate!",
        "📊 Track your progress!",
        "🎯 Aim for success!",
        "🔥 Unleash your potential!",
        "🚀 Pomodoro Boost",
        "🎯 Aim high!",
        "🔥 Ignite your fire!",
        "🚀 Boost your productivity!",
        "💪 Power up your work!",
        "🧠 Train your brain!",
        "📈 Reach new heights!",
        "🎉 Celebrate success!",
        "🎨 Unlock your creativity!",
        "🤝 Connect and thrive!"
    ]
    
    @objc func refreshLabelIfSessionNotStarted() {
        if timerState == .notStarted{
            resetButtonTapped(resetButton as Any)
        }
    }
    
    @IBAction func startButtonTapped(_ sender: Any) {
        switch timerState {
        case .notStarted:
            startTimer()
        case .session, .shortBreak, .longBreak:
            pauseTimer()
        case .paused:
            continueTimer()
        }
    }

    @IBAction func resetButtonTapped(_ sender: Any) {
        // Invalidate and set timer to nil
        timer?.invalidate()
        timer = nil
        
        // Reset timer start status
        hasTimerStarted = false

        // Reset the state of the session
        isOnBreak = false
        timerState = .notStarted
        
        remainingSessionTime = TimeInterval(defaults.float(forKey: "pomodoroDuration")) * 1
        remainingShortBreakTime = TimeInterval(defaults.float(forKey: "shortBreakDuration")) * 1

        // Hide the reset button
        resetButton.isHidden = true

        // Set the start button title to "Start"
        startButton.setTitle("Start", for: .normal)

        // Set the animation to the initial one
        progressBar.putAnimation(animationName: "astronautOperatingLaptop")

        // Reset progress bar
        progressBar.progress = 0

        // Update the time label and saying label
        updateTimeLabel()
        updateSayingLabel(category: .launch)
    }
}

extension Notification.Name {
    static let sessionCompleted = Notification.Name("sessionCompleted")
    static let breakCompleted = Notification.Name("breakCompleted")
}
