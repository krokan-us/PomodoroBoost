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
