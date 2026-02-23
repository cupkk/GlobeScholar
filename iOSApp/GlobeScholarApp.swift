import SwiftUI
import SwiftData

@main
struct GlobeScholarApp: App {
    // 1. Initialize our global state store
    @State private var store = AppStore()
    
    // 2. Setup SwiftData Container
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            OpportunityItem.self,
            PlanTaskItem.self,
            ContactItem.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            
            // Check if it's empty and insert mock data here
            let context = container.mainContext
            let descriptor = FetchDescriptor<OpportunityItem>()
            if try context.fetchCount(descriptor) == 0 {
                // Database is empty. Injecting initial MockData
                for item in MockData.opportunities {
                    context.insert(item)
                }
                for item in MockData.tasks {
                    context.insert(item)
                }
                for item in MockData.contacts {
                    context.insert(item)
                }
                try? context.save()
            }
            
            return container
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ZStack {
                MainTabView()
                    .environment(store) // Inject global State
                    .task {
                        // 3. Trigger remote data sync on app launch
                        await NetworkManager.shared.fetchAndSync(context: sharedModelContainer.mainContext)
                        
                        // Dismiss loading screen with animation after fetch completes
                        withAnimation(.easeInOut(duration: 0.5)) {
                            store.isLoading = false
                        }
                    }
                
                // Global Toast Overlay
                if store.showGlobalToast {
                    VStack {
                        Spacer()
                        HStack(spacing: 12) {
                            Image(systemName: store.toastIcon)
                                .foregroundColor(.green)
                            Text(store.toastMessage)
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(Color(uiColor: .systemBackground))
                        .cornerRadius(24)
                        .shadow(color: Color.black.opacity(0.15), radius: 10, y: 5)
                        .padding(.bottom, 100)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                    .zIndex(100)
                }
                
                // Full Screen Loading Overlay
                if store.isLoading {
                    VStack(spacing: 24) {
                        Image(systemName: "globe.americas.fill")
                            .font(.system(size: 80))
                            .foregroundColor(Color.brandNavyAlias)
                            .symbolEffect(.pulse) // Native iOS 17 animated symbol
                        
                        Text("GlobeScholar")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(Color.brandNavyAlias)
                        
                        Text("Discovering new opportunities...")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            
                        ProgressView()
                            .padding(.top, 20)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(uiColor: .systemBackground))
                    .edgesIgnoringSafeArea(.all)
                    .zIndex(200)
                    .transition(.opacity)
                }
            }
        }
        .modelContainer(sharedModelContainer) // Inject SwiftData container
    }
}
