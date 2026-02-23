import Foundation
import SwiftData
import SwiftUI

/// Global Application State Store
@Observable
final class AppStore {
    // We can hold global UI state here
    var activeTab: MainTabView.Tab = .discover
    var showGlobalToast: Bool = false
    var toastMessage: String = ""
    var toastIcon: String = "checkmark.circle.fill"
    
    // Global Loading State for initial fetch
    var isLoading: Bool = true
    
    // Function to trigger global toast
    func showToast(message: String, icon: String = "checkmark.circle.fill") {
        self.toastMessage = message
        self.toastIcon = icon
        withAnimation {
            self.showGlobalToast = true
        }
        
        // Auto dismiss after 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                self.showGlobalToast = false
            }
        }
    }
}
