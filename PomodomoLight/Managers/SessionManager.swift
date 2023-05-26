//
//  SessionManager.swift
//  PomodomoLight
//
//  Created by Asım Altınışık on 11.05.2023.
//

import Foundation
import CoreData
import UIKit

class SessionManager {
    static let shared = SessionManager()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var isTimerRunning = false
    var isShortBreakRunning = false
    var isLongBreakRunning = false
    
    // MARK: - User Defaults Functions
    
    // Function to update the number of started pomodoros
    func updatePomodorosStarted(count: Int) {
        let currentCount = UserDefaults.standard.integer(forKey: "PomodorosStarted")
        UserDefaults.standard.set(currentCount + count, forKey: "PomodorosStarted")
    }

    // Function to update the number of completed pomodoros
    func updatePomodorosCompleted(count: Int) {
        let currentCount = UserDefaults.standard.integer(forKey: "PomodorosCompleted")
        UserDefaults.standard.set(currentCount + count, forKey: "PomodorosCompleted")
    }

    // Function to update the total duration of pomodoros in seconds
    func updatePomodorosMinutes(duration: TimeInterval) {
        let currentDuration = UserDefaults.standard.double(forKey: "PomodorosMinutes")
        UserDefaults.standard.set(currentDuration + duration, forKey: "PomodorosMinutes")
    }

    // Function to update the number of started breaks
    func updateBreaksStarted(count: Int) {
        let currentCount = UserDefaults.standard.integer(forKey: "BreaksStarted")
        UserDefaults.standard.set(currentCount + count, forKey: "BreaksStarted")
    }

    // Function to update the number of completed breaks
    func updateBreaksCompleted(count: Int) {
        let currentCount = UserDefaults.standard.integer(forKey: "BreaksCompleted")
        UserDefaults.standard.set(currentCount + count, forKey: "BreaksCompleted")
    }

    // Function to update the total duration of breaks in seconds
    func updateBreaksMinutes(duration: TimeInterval) {
        let currentDuration = UserDefaults.standard.double(forKey: "BreaksMinutes")
        UserDefaults.standard.set(currentDuration + duration, forKey: "BreaksMinutes")
    }
    
    // MARK: - Core Data Funcrtions
    
    func saveSession(duration: Int) {
        let entity = NSEntityDescription.entity(forEntityName: "Session", in: context)
        let newSession = NSManagedObject(entity: entity!, insertInto: context)
        newSession.setValue(duration, forKey: "duration")
        newSession.setValue(Date(), forKey: "date")

        do {
            try context.save()
        } catch {
            print("Failed saving")
        }
    }

    func fetchSessions() -> [NSManagedObject] {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Session")
        var sessions: [NSManagedObject] = []
        do {
            sessions = try context.fetch(request) as! [NSManagedObject]
        } catch {
            print("Failed to fetch sessions")
        }
        return sessions
    }

    func fetchSessions(forDate date: Date) -> [NSManagedObject] {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Session")
        let startOfDay = Calendar.current.startOfDay(for: date)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!
        request.predicate = NSPredicate(format: "(%@ <= date) AND (date < %@)", startOfDay as NSDate, endOfDay as NSDate)
        var sessions: [NSManagedObject] = []
        do {
            sessions = try context.fetch(request) as! [NSManagedObject]
        } catch {
            print("Failed to fetch sessions for date")
        }
        return sessions
    }
}
