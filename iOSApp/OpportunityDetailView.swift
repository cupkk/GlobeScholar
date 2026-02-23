import SwiftUI
import SwiftData

struct OpportunityDetailView: View {
    let opportunity: OpportunityItem
    
    @Environment(\.modelContext) private var modelContext
    @Environment(AppStore.self) private var store
    @Environment(\.dismiss) var dismiss
    
    @State private var showSafariView = false
    
    var daysLeft: Int {
        Calendar.current.dateComponents([.day], from: Date(), to: opportunity.deadline).day ?? 0
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header Area
                HStack(alignment: .center, spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(Color(uiColor: .systemGray5))
                            .frame(width: 64, height: 64)
                            
                        if !opportunity.imageUrl.isEmpty, let url = URL(string: opportunity.imageUrl) {
                            AsyncImage(url: url) { phase in
                                switch phase {
                                case .empty:
                                    ProgressView()
                                case .success(let image):
                                    image.resizable()
                                         .scaledToFit()
                                         .frame(width: 48, height: 48)
                                         .clipShape(Circle())
                                case .failure:
                                    Image(systemName: "graduationcap")
                                        .font(.title)
                                        .foregroundColor(Color.brandNavyAlias)
                                @unknown default:
                                    EmptyView()
                                }
                            }
                        } else {
                            Image(systemName: "graduationcap")
                                .font(.title)
                                .foregroundColor(Color.brandNavyAlias)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(opportunity.schoolAbbr)
                            .font(.headline)
                            .foregroundColor(Color.brandNavyAlias)
                        Text(opportunity.schoolName)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.top)
                
                Text(opportunity.programName)
                    .font(.title2)
                    .fontWeight(.bold)
                
                // Badges
                HStack(spacing: 8) {
                    if opportunity.isOfficial {
                        Label("Official", systemImage: "checkmark.seal")
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.blue.opacity(0.1))
                            .foregroundColor(.blue)
                            .cornerRadius(8)
                    }
                    
                    Label(opportunity.status, systemImage: "dollarsign.circle")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.green.opacity(0.1))
                        .foregroundColor(.green)
                        .cornerRadius(8)
                }
                
                // Location & Type
                HStack(spacing: 8) {
                    Label(opportunity.location, systemImage: "mappin.and.ellipse")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color(uiColor: .systemGray6))
                        .cornerRadius(8)
                    
                    Text("Summer Research")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color(uiColor: .systemGray6))
                        .cornerRadius(8)
                }
                
                // Deadline Alert
                HStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(Color.red.opacity(0.1))
                            .frame(width: 40, height: 40)
                        Image(systemName: "clock")
                            .foregroundColor(.red)
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Application Deadline")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        HStack {
                            Text(opportunity.deadline, style: .date)
                                .font(.headline)
                            Text("\(daysLeft) days left")
                                .font(.caption)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.red.opacity(0.2))
                                .foregroundColor(.red)
                                .cornerRadius(4)
                        }
                    }
                    Spacer()
                }
                .padding()
                .background(Color.red.opacity(0.05))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.red.opacity(0.1), lineWidth: 1)
                )
                
                // Program Overview
                VStack(alignment: .leading, spacing: 12) {
                    Label("Program Overview", systemImage: "doc.text")
                        .font(.headline)
                    
                    Text(opportunity.description)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .lineSpacing(4)
                }
                .padding(.top, 16)
                
                // Eligibility
                VStack(alignment: .leading, spacing: 12) {
                    Label("Eligibility", systemImage: "checkmark.circle")
                        .font(.headline)
                }
                .padding(.top, 16)
                
                Spacer(minLength: 40)
            }
            .padding(.horizontal)
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack(spacing: 8) {
                    // Export to Calendar Button
                    Button(action: {
                        CalendarManager.shared.addDeadlineEvent(
                            title: opportunity.programName,
                            school: opportunity.schoolName,
                            urlString: opportunity.websiteUrl,
                            deadline: opportunity.deadline
                        ) { success, errorMsg in
                            HapticManager.shared.notification(type: success ? .success : .error)
                            store.showToast(
                                message: success ? "Exported to Calendar" : (errorMsg ?? "Calendar export failed"),
                                icon: success ? "calendar.badge.plus" : "exclamationmark.triangle"
                            )
                        }
                    }) {
                        Image(systemName: "calendar.badge.plus")
                            .foregroundColor(.primary)
                    }
                    
                    Button(action: {
                        // Toggle Saved Status
                        opportunity.isSaved.toggle()
                        opportunity.dateSaved = opportunity.isSaved ? Date() : nil
                        
                        // HIG: Add Haptic Feedback
                        HapticManager.shared.impact(style: opportunity.isSaved ? .medium : .light)
                        
                        store.showToast(message: opportunity.isSaved ? "Saved to your list" : "Removed from saved")
                    }) {
                        Image(systemName: opportunity.isSaved ? "bookmark.fill" : "bookmark")
                            .foregroundColor(opportunity.isSaved ? Color.brandNavyAlias : .primary)
                    }
                }
                .foregroundColor(.primary)
            }
        }
        // Action Buttons at bottom
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 12) {
                Button(action: {
                    // Create a new PlanTask based on this opportunity
                    let newTask = PlanTaskItem(
                        schoolAbbr: opportunity.schoolAbbr,
                        schoolName: opportunity.schoolName,
                        programName: opportunity.programName,
                        title: "Review eligibility for \(opportunity.programName)",
                        deadline: opportunity.deadline
                    )
                    modelContext.insert(newTask)
                    
                    // HIG: Add Haptic Feedback
                    HapticManager.shared.notification(type: .success)
                    
                    // System Integration: Schedule push notification
                    NotificationManager.shared.scheduleDeadlineNotification(
                        id: newTask.id,
                        title: newTask.title,
                        school: newTask.schoolName,
                        program: newTask.programName,
                        deadline: newTask.deadline
                    )
                    
                    store.showToast(message: "Added to Plan")
                    
                    // Navigate to Plan tab
                    dismiss()
                    store.activeTab = .plan
                }) {
                    Text("Add to Plan")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.brandNavyAlias)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                
                Button(action: {
                    if let _ = URL(string: opportunity.websiteUrl) { 
                        showSafariView = true
                    }
                }) {
                    Label("Visit Official Website", systemImage: "arrow.up.right.square")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.clear)
                        .foregroundColor(.primary)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(uiColor: .systemGray4), lineWidth: 1)
                        )
                }
            }
            .padding()
            .background(Color(uiColor: .secondarySystemGroupedBackground).ignoresSafeArea())
        }
        .fullScreenCover(isPresented: $showSafariView) {
            if let url = URL(string: opportunity.websiteUrl) {
                SafariView(url: url)
                    .ignoresSafeArea()
            }
        }
    }
}
