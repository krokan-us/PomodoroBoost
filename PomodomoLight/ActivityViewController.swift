import UIKit

class ActivityViewController: UIViewController {
    
    @IBOutlet weak var progressBar: CircularProgressBar!
    @IBOutlet weak var timeLeftLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
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
    
    private let sessionTime: TimeInterval = 30
    private var remainingTime: TimeInterval = 30
    private let breakTime: TimeInterval = 10
    private let longBreakTime: TimeInterval = 10
    
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
    
    private var totalWorkTime: TimeInterval {
        get {
            return UserDefaults.standard.double(forKey: "totalWorkTime")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "totalWorkTime")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if !hasTimerStarted {
            progressBar.progress = 0
            progressBar.putAnimation(animationName: "astronautOperatingLaptop")
            setButton()
            updateTimeLabel()
            updateSayingLabel(category: .launch)
        }
    }
    
    @IBAction func startButtonTapped(_ sender: Any) {
        hasTimerStarted = true
        if isTimerRunning {
            pauseTimer()
        } else {
            startTimer()
        }
    }
    
    private func setButton() {
        startButton.backgroundColor = .red
        startButton.layer.cornerRadius = 20
        startButton.tintColor = .white
    }
    
    private func startTimer() {
        // Invalidate and set timer to nil before starting a new timer
        timer?.invalidate()
        timer = nil

        progressBar.putAnimation(animationName: isOnBreak ? "astronautInMug" : "astronautOnARocket")
        progressBar.barColor = isOnBreak ? .green : .red // update the bar color

        startButton.setTitle("Pause", for: .normal)
        isTimerRunning = true
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateCountdown), userInfo: nil, repeats: true)
        updateSayingLabel(category: isOnBreak ? .break : .session)
    }

    
    private func pauseTimer() {
        startButton.setTitle("Continue", for: .normal)
        progressBar.putAnimation(animationName: "astronautHoldingAStar")
        isTimerRunning = false
        timer?.invalidate()
        timer = nil
        updateSayingLabel(category: .pause)
    }
    
    @objc private func updateCountdown() {
        remainingTime -= 1
        updateTimeLabel()
        
        let progress = CGFloat(1 - remainingTime / (isOnBreak ? breakTime : sessionTime))
        progressBar.progress = progress
        
        if remainingTime <= 0 {
            timer?.invalidate()
            if isOnBreak {
                resetTimer()
            } else {
                startBreak()
            }
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
        remainingTime = completedSessions == 4 ? longBreakTime : breakTime
        
        updateTimeLabel()
        startTimer()

        completedSessions += 1 // Increment the completed sessions count
        updateIndicators() // Update the indicators
        
        SessionManager.shared.saveSession(duration: Int(sessionTime))
        NotificationCenter.default.post(name: .sessionCompleted, object: nil)
    }
    

    private func resetTimer() {
        // Invalidate and set timer to nil before resetting the timer
        timer?.invalidate()
        timer = nil

        isOnBreak = false
        remainingTime = sessionTime
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
        let minutes = Int(remainingTime) / 60
        let seconds = Int(remainingTime) % 60
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
}
