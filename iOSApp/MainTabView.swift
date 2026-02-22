import SwiftUI

struct MainTabView: View {
    @Environment(AppStore.self) private var store
    
    enum Tab {
        case map, discover, plan, saved, profile
    }

    var body: some View {
        // We bind the TabView selection to our global store so it can be controlled programmatically
        @Bindable var bindableStore = store
        
        TabView(selection: $bindableStore.activeTab) {
            MapView()
                .tabItem {
                    Label("Map", systemImage: "map")
                }
                .tag(Tab.map)

            DiscoverView()
                .tabItem {
                    Label("Discover", systemImage: "safari")
                }
                .tag(Tab.discover)

            PlanView()
                .tabItem {
                    Label("Plan", systemImage: "list.clipboard")
                }
                .tag(Tab.plan)

            SavedView()
                .tabItem {
                    Label("Saved", systemImage: "star")
                }
                .tag(Tab.saved)

            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
                .tag(Tab.profile)
        }
        .tint(Color("BrandNavy", bundle: nil)) // Use primary brand color
        .onAppear {
            // Request Notification permissions on app launch
            NotificationManager.shared.requestAuthorization { _ in }
        }
    }
}

extension Color {
    static let brandNavy = Color(red: 26/255, green: 54/255, blue: 93/255)
    static let bgGray = Color(uiColor: .systemGroupedBackground)
}

#Preview {
    MainTabView()
}
