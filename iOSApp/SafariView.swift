import SwiftUI
import SafariServices

/// A SwiftUI wrapper around UIKit's SFSafariViewController
struct SafariView: UIViewControllerRepresentable {
    let url: URL
    
    func makeUIViewController(context: Context) -> SFSafariViewController {
        let configuration = SFSafariViewController.Configuration()
        configuration.entersReaderIfAvailable = false
        
        let safariViewController = SFSafariViewController(url: url, configuration: configuration)
        safariViewController.preferredControlTintColor = UIColor(Color.brandNavyAlias)
        
        return safariViewController
    }
    
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {
        // No need to update anything dynamically for now
    }
}
