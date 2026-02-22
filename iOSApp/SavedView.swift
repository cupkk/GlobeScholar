import SwiftUI
import SwiftData

struct SavedView: View {
    @Query(filter: #Predicate<OpportunityItem> { $0.isSaved }, sort: \.dateSaved, order: .reverse) private var savedPrograms: [OpportunityItem]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    
                    // Programs Section
                    SectionView(title: "PROGRAMS (\(savedPrograms.count))") {
                        if savedPrograms.isEmpty {
                            VStack(spacing: 20) {
                                ZStack {
                                    Circle()
                                        .fill(Color(uiColor: .systemGray6))
                                        .frame(width: 72, height: 72)
                                    Image(systemName: "bookmark.slash")
                                        .font(.system(size: 28))
                                        .foregroundColor(.secondary)
                                }
                                
                                VStack(spacing: 8) {
                                    Text("Nothing saved yet")
                                        .font(.headline)
                                    Text("Explore the Discover tab to find and save summer research or PhD opportunities.")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                        .multilineTextAlignment(.center)
                                }
                            }
                            .padding(.vertical, 32)
                            .frame(maxWidth: .infinity)
                            .background(Color(uiColor: .secondarySystemGroupedBackground))
                            .cornerRadius(16)
                        } else {
                            VStack(spacing: 12) {
                                ForEach(savedPrograms) { prog in
                                    SavedItemRow(icon: "graduationcap", title: prog.programName, subtitle: "\(prog.schoolAbbr) - \(prog.location)", tag: "Summer Research")
                                }
                            }
                        }
                    }
                    
                    // Schools Section
                    SectionView(title: "SCHOOLS (1)") {
                        SavedItemRow(icon: "graduationcap", title: "Stanford University", subtitle: "Stanford, CA, USA", tag: "1 Active Program")
                    }
                    
                    // Professors Section
                    SectionView(title: "PROFESSORS (1)") {
                        SavedItemRow(icon: "person", title: "Prof. Sarah Chen", subtitle: "MIT - Machine Learning / NLP", tag: "Replied", tagColor: .green)
                    }
                    
                    // Articles Section
                    SectionView(title: "ARTICLES (1)") {
                        SavedItemRow(icon: "doc.text", title: "How to Write a Winning SOP", subtitle: "By GlobeScholar Guide", tag: "Article")
                    }
                }
                .padding(.vertical)
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("Saved")
        }
    }
}

struct SectionView<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.footnote)
                .fontWeight(.bold)
                .foregroundColor(.secondary)
                .padding(.horizontal, 24)
            
            content
                .padding(.horizontal)
        }
    }
}

struct SavedItemRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let tag: String
    var tagColor: Color = .secondary
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color(uiColor: .systemGray6))
                    .frame(width: 48, height: 48)
                Image(systemName: icon)
                    .foregroundColor(Color.brandNavyAlias)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .lineLimit(1)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                
                Text(tag)
                    .font(.caption2)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(tagColor == .secondary ? Color(uiColor: .systemGray6) : tagColor.opacity(0.1))
                    .foregroundColor(tagColor == .secondary ? .primary : tagColor)
                    .cornerRadius(4)
            }
            
            Spacer()
            
            Button(action: {}) {
                Image(systemName: "trash")
                    .foregroundColor(.secondary)
            }
            .padding(.trailing, 8)
            
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
                .font(.caption)
        }
        .padding()
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
}
