import SwiftUI

/// A simple manager to trigger iOS system haptic feedback
class HapticManager {
    static let shared = HapticManager()
    
    // Impact feedback (for satisfying ticks like completing a task or hearting an item)
    func impact(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }
    
    // Notification feedback (for success/warning states, like error alerts)
    func notification(type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(type)
    }
}
