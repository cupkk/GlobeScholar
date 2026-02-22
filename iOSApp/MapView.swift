import SwiftUI
import MapKit
import SwiftData

struct MapView: View {
    @Query private var opportunities: [OpportunityItem]
    
    @State private var position: MapCameraPosition = .automatic
    @State private var searchText = ""
    @State private var showBottomSheet = true
    @State private var selectedSchool: String? // Track selected marker
    
    
    // Compute unique locations from SwiftData opportunities, applying search filter
    var mapLocations: [String: [OpportunityItem]] {
        let filteredOps = searchText.isEmpty ? opportunities : opportunities.filter {
            $0.schoolName.localizedCaseInsensitiveContains(searchText) ||
            $0.schoolAbbr.localizedCaseInsensitiveContains(searchText) ||
            $0.programName.localizedCaseInsensitiveContains(searchText) ||
            $0.location.localizedCaseInsensitiveContains(searchText)
        }
        return Dictionary(grouping: filteredOps, by: { $0.schoolAbbr })
    }
    
    private func getCoordinates(for abbr: String) -> CLLocationCoordinate2D {
        // Fallback mock coordinates since our current models don't store lat/lon explicitly
        let coords: [String: CLLocationCoordinate2D] = [
            "MIT": CLLocationCoordinate2D(latitude: 42.3601, longitude: -71.0942),
            "Stanford": CLLocationCoordinate2D(latitude: 37.4275, longitude: -122.1697),
            "ETH": CLLocationCoordinate2D(latitude: 47.3769, longitude: 8.5417),
            "CMU": CLLocationCoordinate2D(latitude: 40.4432, longitude: -79.9428)
        ]
        return coords[abbr] ?? CLLocationCoordinate2D(latitude: 0, longitude: 0)
    }

    var body: some View {
        ZStack(alignment: .top) {
            // Full Screen Map First
            Map(position: $position, selection: $selectedSchool) {
                ForEach(Array(mapLocations.keys), id: \.self) { abbr in
                    if let programs = mapLocations[abbr] {
                        Annotation(abbr, coordinate: getCoordinates(for: abbr)) {
                            MapPinView(name: abbr, count: programs.count, isSelected: selectedSchool == abbr)
                                .onTapGesture {
                                    withAnimation {
                                        selectedSchool = abbr
                                        HapticManager.shared.impact(style: .light)
                                    }
                                }
                        }
                        .tag(abbr) // Tag for selection binding
                    }
                }
            }
            .mapStyle(.standard(elevation: .realistic))
            .ignoresSafeArea(edges: .top)
            
            // Floating Top Search Bar
            VStack {
                HStack {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        TextField("Search schools, programs...", text: $searchText)
                            .font(.body)
                    }
                    .padding(12)
                    .background(Color(uiColor: .systemBackground))
                    .cornerRadius(24)
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                    
                    Button(action: {}) {
                        Image(systemName: "slider.horizontal.3")
                            .padding(12)
                            .background(Color(uiColor: .systemBackground))
                            .clipShape(Circle())
                            .foregroundColor(.primary)
                            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
                
                // Active status pill
                HStack {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 8, height: 8)
                    Text("\(mapLocations.count) active schools")
                        .font(.caption)
                        .fontWeight(.medium)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color(uiColor: .systemBackground))
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                .padding(.top, 4)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 24)
                
                Spacer()
            }
        }
        // Using sheet for bottom sheet
        .sheet(isPresented: $showBottomSheet) {
            NearbyOpportunitiesSheet(mapLocations: mapLocations, selectedSchool: $selectedSchool)
                .presentationDetents([.fraction(0.35), .large])
                .presentationDragIndicator(.visible)
                .interactiveDismissDisabled() // Keeps it persistent like in the design
                .presentationBackgroundInteraction(.enabled(upThrough: .fraction(0.35))) // Map is interactive behind it
        }
    }
}

// Custom Map Pin
struct MapPinView: View {
    let name: String
    let count: Int
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 4) {
                Text(name)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(isSelected ? .white : .primary)
                Text("\(count)")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(isSelected ? Color.brandNavyAlias : .white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(isSelected ? Color.white : Color.green)
                    .clipShape(Capsule())
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(isSelected ? Color.brandNavyAlias : Color(uiColor: .systemBackground))
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.15), radius: 4, x: 0, y: 2)
            .scaleEffect(isSelected ? 1.1 : 1.0)
            
            // Pin Triangle
            Image(systemName: "arrowtriangle.down.fill")
                .foregroundColor(isSelected ? Color.brandNavyAlias : .green)
                .font(.caption)
                .offset(y: -4)
        }
    }
}

struct MapLocation: Identifiable {
    let id = UUID()
    let name: String
    let coordinate: CLLocationCoordinate2D
    let activeCount: Int
}

struct NearbyOpportunitiesSheet: View {
    let mapLocations: [String: [OpportunityItem]]
    @Binding var selectedSchool: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Nearby Opportunities")
                    .font(.title3)
                    .fontWeight(.bold)
                Text("Tap a pin to explore")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)
            .padding(.top, 16)
            
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(Array(mapLocations.keys.sorted()), id: \.self) { abbr in
                            if let items = mapLocations[abbr], let firstItem = items.first {
                                SchoolRow(abbr: abbr, schoolName: firstItem.schoolName, location: firstItem.location, count: items.count, isSelected: selectedSchool == abbr)
                                    .id(abbr) // ID for ScrollViewReader
                                    .onTapGesture {
                                        withAnimation {
                                            selectedSchool = abbr
                                            HapticManager.shared.impact(style: .light)
                                            proxy.scrollTo(abbr, anchor: .center)
                                        }
                                    }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .onChange(of: selectedSchool) { _, newValue in
                    // Automatically scroll to the selected item when the map pin is tapped
                    if let newSelection = newValue {
                        withAnimation {
                            proxy.scrollTo(newSelection, anchor: .top)
                        }
                    }
                }
            }
        }
        .background(Color(uiColor: .systemGroupedBackground))
    }
}

struct SchoolRow: View {
    let abbr: String
    let schoolName: String
    let location: String
    let count: Int
    let isSelected: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(isSelected ? Color.brandNavyAlias : Color.brandNavyAlias.opacity(0.1))
                    .frame(width: 48, height: 48)
                Text(abbr)
                    .fontWeight(.bold)
                    .foregroundColor(isSelected ? .white : Color.brandNavyAlias)
            }
            
            VStack(alignment: .leading) {
                Text(schoolName)
                    .font(.headline)
                Text(location)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text("\(count) programs")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .white : .green)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(isSelected ? Color.green : Color.green.opacity(0.1))
                .cornerRadius(12)
        }
        .padding()
        .background(isSelected ? Color.blue.opacity(0.05) : Color(uiColor: .secondarySystemGroupedBackground))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isSelected ? Color.brandNavyAlias.opacity(0.5) : Color.clear, lineWidth: 2)
        )
    }
}
