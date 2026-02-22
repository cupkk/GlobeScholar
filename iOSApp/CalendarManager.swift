import Foundation
import EventKit
import SwiftUI

class CalendarManager {
    static let shared = CalendarManager()
    let eventStore = EKEventStore()
    
    private init() {}
    
    /// Requests access to the user's Calendar
    func requestAccess(completion: @escaping (Bool) -> Void) {
        if #available(iOS 17.0, *) {
            eventStore.requestFullAccessToEvents { granted, error in
                DispatchQueue.main.async {
                    completion(granted)
                }
            }
        } else {
            // Fallback for older iOS versions
            eventStore.requestAccess(to: .event) { granted, error in
                DispatchQueue.main.async {
                    completion(granted)
                }
            }
        }
    }
    
    /// Adds a deadline event to the default calendar
    func addDeadlineEvent(title: String, school: String, urlString: String?, deadline: Date, completion: @escaping (Bool, String?) -> Void) {
        // Ensure we have permission first
        let authStatus = EKEventStore.authorizationStatus(for: .event)
        
        let executeAdd = {
            let event = EKEvent(eventStore: self.eventStore)
            event.title = "Application Deadline: \(school) - \(title)"
            event.startDate = deadline
            event.endDate = Calendar.current.date(byAdding: .hour, value: 1, to: deadline) ?? deadline
            event.isAllDay = true 
            event.notes = "GlobeScholar Deadline tracking for \(title)."
            
            if let safeUrlString = urlString, let url = URL(string: safeUrlString) {
                event.url = url
            }
            
            event.calendar = self.eventStore.defaultCalendarForNewEvents
            
            do {
                try self.eventStore.save(event, span: .thisEvent)
                DispatchQueue.main.async {
                    completion(true, nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(false, error.localizedDescription)
                }
            }
        }
        
        switch authStatus {
        case .authorized, .fullAccess:
            executeAdd()
        case .notDetermined:
            self.requestAccess { granted in
                if granted {
                    executeAdd()
                } else {
                    completion(false, "Calendar access denied.")
                }
            }
        case .denied, .restricted, .writeOnly:
            completion(false, "Please grant Calendar permissions in iOS Settings.")
        @unknown default:
            completion(false, "Unknown authorization status.")
        }
    }
}
