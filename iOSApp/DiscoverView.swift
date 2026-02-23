import SwiftUI
import SwiftData

struct DiscoverView: View {
    @Environment(AppStore.self) private var store
    @Environment(\.modelContext) private var modelContext
    @Query private var opportunities: [OpportunityItem]
    
    @State private var selectedFilter = "All"
    @State private var searchText = ""
    let filters = ["All", "Summer Research", "PhD Openings"]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    // Banner
                    HStack {
                        Image(systemName: "sparkles")
                            .foregroundColor(.red)
                        Text("**\(opportunities.count > 0 ? opportunities.count : 3)** opportunities closing within 15 days")
                            .font(.subheadline)
                            .foregroundColor(.primary)
                        Spacer()
                    }
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
                    // Filter Pills
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(filters, id: \.self) { filter in
                                FilterPill(title: filter, isSelected: selectedFilter == filter) {
                                    selectedFilter = filter
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Cards List
                    LazyVStack(spacing: 16) {
                        // In a real app we'd apply the filter to the @Query,
                        // here we just filter the array for demo purposes
                        var filtered = opportunities.filter { selectedFilter == "All" ? true : $0.tags.contains(selectedFilter) }
                        
                        if !searchText.isEmpty {
                            filtered = filtered.filter {
                                $0.schoolName.localizedCaseInsensitiveContains(searchText) ||
                                $0.programName.localizedCaseInsensitiveContains(searchText) ||
                                $0.schoolAbbr.localizedCaseInsensitiveContains(searchText)
                            }
                        }
                        
                        // Fallback to mock data if empty (for preview/initial state)
                        let displayData = filtered.isEmpty && opportunities.isEmpty ? MockData.opportunities : filtered
                        
                        ForEach(displayData, id: \.id) { opportunity in
                            NavigationLink(destination: OpportunityDetailView(opportunity: opportunity)) {
                                OpportunityCard(opportunity: opportunity)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal)
                    .animation(.spring(response: 0.4, dampingFraction: 0.8), value: opportunities)
                    .animation(.spring(response: 0.4, dampingFraction: 0.8), value: selectedFilter)
                    .animation(.spring(response: 0.4, dampingFraction: 0.8), value: searchText)
                }
                .padding(.vertical)
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("Discover")
            .searchable(text: $searchText, prompt: "Search schools, programs...")
            .disableAutocorrection(true)
            .refreshable {
                // Trigger manual pull-to-refresh
                // HIG: Give a haptic feedback when pull to refresh is triggered
                HapticManager.shared.impact(style: .light)
                await NetworkManager.shared.fetchAndSync(context: modelContext)
            }
        }
    }
}

struct FilterPill: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.brandNavy : Color(uiColor: .secondarySystemGroupedBackground))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(20)
        }
    }
}

// Keep extensions locally for previews to work stand-alone if needed
extension Color {
    static let brandNavyAlias = Color(red: 26/255, green: 54/255, blue: 93/255)
}

struct DiscoverView_Previews: PreviewProvider {
    static var previews: some View {
        DiscoverView()
    }
}
