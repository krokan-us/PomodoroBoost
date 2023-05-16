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
    
    private var completedSessions: Int = 0
    private var timer: Timer?
    private var isOnBreak = false
    private var hasTimerStarted = false
    private var isTimerRunning = false
    private var hasViewDisappeared: Bool = false
    private var wasOnBreak = false
    private let timerEndedSoundID: SystemSoundID = 1005

    
    var timerState: TimerState = .notStarted
    
    enum TimerState {
        case notStarted
        case session
        case shortBreak
        case longBreak
        case paused
    }

    private var sessionTime: TimeInterval = 10
    private var breakTime: TimeInterval = 10
    private var longBreakTime: TimeInterval = 20
    
    private var remainingSessionTime: TimeInterval = 10
    private var remainingShortBreakTime: TimeInterval = 10
    
    private let sessionStatements: [String] = [
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
    
    private let breakStatements: [String] = [
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
        "🤗 Connect with a friend!",
    ]
    
    private let pauseStatements: [String] = [
        "⏸️ Paused!",
        "🛑 Take a moment!",
        "⏹️ Hold on!",
        "🕰️ Time out!"
    ]
    
    private let launchStatements: [String] = [
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
    
    @IBAction func startButtonTapped(_ sender: Any) {
        switch timerState {
        case .notStarted:
            startTimer()
            timerState = .session
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
        remainingSessionTime = sessionTime
        remainingShortBreakTime = breakTime

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

    
    private func setStartButton() {
        startButton.backgroundColor = .red
        startButton.layer.cornerRadius = 20
        startButton.tintColor = .white
    }
    
    private func setResetButton() {
        resetButton.backgroundColor = .orange
        resetButton.layer.cornerRadius = 15
        resetButton.tintColor = .white
    }
    
    private func startTimer() {
        // Invalidate and set timer to nil before starting a new timer
        hasTimerStarted = true
        timer?.invalidate()
        timer = nil
        
        resetButton.isHidden = false
        
        if isOnBreak {
            SessionManager.shared.updateBreaksStarted(count: 1)
        } else {
            SessionManager.shared.updatePomodorosStarted(count: 1)
            NotificationCenter.default.post(name: .sessionCompleted, object: nil)
        }
        
        progressBar.putAnimation(animationName: isOnBreak ? "astronautInMug" : "astronautOnARocket")
        progressBar.barColor = isOnBreak ? .green : .red // update the bar color
        
        startButton.setTitle("Pause", for: .normal)
        timerState = isOnBreak ? .shortBreak : .session
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateCountdown), userInfo: nil, repeats: true)
        updateSayingLabel(category: isOnBreak ? .break : .session)
    }
    
    
    private func pauseTimer() {
        startButton.setTitle("Continue", for: .normal)
        progressBar.putAnimation(animationName: "astronautHoldingAStar")
        timerState = .paused
        timer?.invalidate()
        timer = nil
        wasOnBreak = isOnBreak // Remember whether we were on break or not
        updateSayingLabel(category: .pause)
    }
    
    private func continueTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateCountdown), userInfo: nil, repeats: true)
        startButton.setTitle("Pause", for: .normal)
        progressBar.putAnimation(animationName: wasOnBreak ? "astronautInMug" : "astronautOnARocket")
        timerState = wasOnBreak ? .shortBreak : .session // Restore the state we had before pausing
        updateSayingLabel(category: wasOnBreak ? .break : .session)
    }
    
    private func updateTime(_ time: inout TimeInterval) {
        time -= 1
    }
    
    @objc private func updateCountdown() {
        if isOnBreak {
            updateTime(&remainingShortBreakTime)
        } else {
            updateTime(&remainingSessionTime)
        }
        
        updateTimeLabel()
        
        let progress = CGFloat(1 - (isOnBreak ? remainingShortBreakTime : remainingSessionTime) / (isOnBreak ? breakTime : sessionTime))
        progressBar.progress = progress
        
        if isOnBreak {
            if remainingShortBreakTime <= 0 {
                timer?.invalidate()
                resetTimer()
                playTimerEndedSound()
                SessionManager.shared.updateBreaksCompleted(count: 1)
                SessionManager.shared.updateBreaksMinutes(duration: breakTime)
                NotificationCenter.default.post(name: .breakCompleted, object: nil)
            }
        } else {
            if remainingSessionTime <= 0 {
                timer?.invalidate()
                startBreak()
                playTimerEndedSound()
                SessionManager.shared.updatePomodorosCompleted(count: 1)
                SessionManager.shared.updatePomodorosMinutes(duration: sessionTime)
                NotificationCenter.default.post(name: .sessionCompleted, object: nil)
            }
        }
    }
    
    private func playTimerEndedSound() {
        let defaults = UserDefaults.standard
        let soundOnCompletion = defaults.bool(forKey: "soundOnCompletion")
        
        if soundOnCompletion {
            AudioServicesPlaySystemSound(timerEndedSoundID)
        }
    }
    
    private func startBreak() {
        // Invalidate and set timer to nil before starting a break
        timer?.invalidate()
        timer = nil
        
        isOnBreak = true
        progressBar.barColor = .green
        progressBar.putAnimation(animationName: "astronautInMug")
        
        // Check if 4 sessions are completed and set break duration accordingly
        remainingShortBreakTime = completedSessions == 4 ? longBreakTime : breakTime
        
        updateTimeLabel()
        startTimer()
        
        completedSessions += 1 // Increment the completed sessions count
        updateIndicators() // Update the indicators
        
        SessionManager.shared.saveSession(duration: Int(sessionTime))
        
        // Hide the reset button during breaks
        resetButton.isHidden = true
    }
    
    
    private func resetTimer() {
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
    }
    
    private func updateTimeLabel() {
        let minutes = Int(isOnBreak ? remainingShortBreakTime : remainingSessionTime) / 60
        let seconds = Int(isOnBreak ? remainingShortBreakTime : remainingSessionTime) % 60
        timeLeftLabel.text = String(format: "%02d:%02d", minutes, seconds)
    }
    
    private func updateIndicators() {
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
    
    private func resetIndicators() {
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
    
    private enum StatementCategory {
        case session, `break`, pause, launch
    }
    
    private func updateSayingLabel(category: StatementCategory) {
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

extension Notification.Name {
    static let sessionCompleted = Notification.Name("sessionCompleted")
    static let breakCompleted = Notification.Name("breakCompleted")
}

