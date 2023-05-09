import UIKit

class ActivityViewController: UIViewController {
    
    @IBOutlet weak var progressBar: CircularProgressBar!
    @IBOutlet weak var timeLeftLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    
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
        
        startButton.setTitle("Pause", for: .normal)
        isTimerRunning = true
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateCountdown), userInfo: nil, repeats: true)
    }
    
    private func pauseTimer() {
        startButton.setTitle("Continue", for: .normal)
        progressBar.putAnimation(animationName: "astronautHoldingAStar")
        isTimerRunning = false
        timer?.invalidate()
        timer = nil
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
        progressBar.putAnimation(animationName: "astronautInMug")
        
        // Check if 4 sessions are completed and set break duration accordingly
        remainingTime = completedSessions == 4 ? longBreakTime : breakTime
        
        updateTimeLabel()
        startTimer()
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
}
