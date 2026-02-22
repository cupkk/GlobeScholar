import Foundation
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()
    
    private init() {}
    
    /// Requests authorization from the user to display notifications
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if let error = error {
                print("Error requesting notification authorization: \(error.localizedDescription)")
            }
            // Move to main thread if updating UI
            DispatchQueue.main.async {
                completion(success)
            }
        }
    }
    
    /// Schedules a notification for a deadline
    /// In a real app, you might schedule this 1 week, 3 days, or 24 hours before the actual deadline.
    func scheduleDeadlineNotification(id: UUID, title: String, school: String, program: String, deadline: Date) {
        // Core Notification Content
        let content = UNMutableNotificationContent()
        content.title = "Upcoming Deadline: \(school)"
        content.subtitle = title
        content.body = "Your application for \(program) is due soon. Make sure all materials are ready!"
        content.sound = .default
        
        // Define when the notification should fire.
        // For demonstration, let's schedule it 1 day before the deadline.
        let triggerDate = Calendar.current.date(byAdding: .day, value: -1, to: deadline) ?? deadline
        
        // Ensure the trigger date is in the future
        guard triggerDate > Date() else {
            print("Deadline is already past or too close to schedule a 1-day advance notification.")
            return
        }
        
        let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate)
        
        // Create the trigger
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        // Create the request using the item ID so we can cancel it later if needed
        let request = UNNotificationRequest(identifier: id.uuidString, content: content, trigger: trigger)
        
        // Schedule it
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            } else {
                print("Successfully scheduled notification for \(title) at \(triggerDate)")
            }
        }
    }
    
    /// Cancels a previously scheduled notification
    func cancelNotification(id: UUID) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id.uuidString])
    }
}
