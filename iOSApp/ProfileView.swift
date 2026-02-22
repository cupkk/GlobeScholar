import SwiftData

struct ProfileView: View {
    @Query(filter: #Predicate<OpportunityItem> { $0.isSaved }) private var savedPrograms: [OpportunityItem]
    @Query private var planTasks: [PlanTaskItem]
    @Query private var contacts: [ContactItem]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    
                    // User Card
                    VStack(spacing: 16) {
                        HStack(spacing: 16) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color(uiColor: .systemGray5))
                                    .frame(width: 72, height: 72)
                                Image(systemName: "graduationcap.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 36, height: 36)
                                    .foregroundColor(Color.brandNavyAlias)
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Scholar User")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                Text("2027 Fall Application")
                                    .foregroundColor(.secondary)
                                
                                HStack {
                                    ProfileTag(text: "AI / ML")
                                    ProfileTag(text: "PhD")
                                    ProfileTag(text: "CS")
                                }
                            }
                            Spacer()
                        }
                        
                        Divider()
                        
                        // Stats
                        HStack {
                            StatItem(value: "\(savedPrograms.count)", label: "Saved")
                            Divider().frame(height: 30)
                            StatItem(value: "\(planTasks.count)", label: "Tasks")
                            Divider().frame(height: 30)
                            StatItem(value: "\(contacts.count)", label: "Contacts")
                        }
                    }
                    .padding()
                    .background(Color(uiColor: .secondarySystemGroupedBackground))
                    .cornerRadius(16)
                    .padding(.horizontal)
                    
                    // Settings List
                    VStack(spacing: 0) {
                        Button(action: {}) {
                            SettingsRow(icon: "bell", title: "Notification Settings", subtitle: "Manage push notifications")
                        }
                        .buttonStyle(PlainButtonStyle())
                        Divider().padding(.leading, 56)
                        
                        Button(action: {}) {
                            SettingsRow(icon: "globe", title: "Language & Region", subtitle: "English (US)")
                        }
                        .buttonStyle(PlainButtonStyle())
                        Divider().padding(.leading, 56)
                        
                        Button(action: {}) {
                            SettingsRow(icon: "gearshape", title: "App Settings", subtitle: "Theme, preferences")
                        }
                        .buttonStyle(PlainButtonStyle())
                        Divider().padding(.leading, 56)
                        
                        Button(action: {}) {
                            SettingsRow(icon: "flag", title: "Report Error", subtitle: "Report incorrect data")
                        }
                        .buttonStyle(PlainButtonStyle())
                        Divider().padding(.leading, 56)
                        
                        Button(action: {}) {
                            SettingsRow(icon: "shield", title: "Disclaimer", subtitle: "Terms and legal info")
                        }
                        .buttonStyle(PlainButtonStyle())
                        Divider().padding(.leading, 56)
                        
                        Button(action: {}) {
                            SettingsRow(icon: "questionmark.circle", title: "Help & Support", subtitle: "FAQ and contact support")
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .background(Color(uiColor: .secondarySystemGroupedBackground))
                    .cornerRadius(16)
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("Profile")
        }
    }
}

struct ProfileTag: View {
    let text: String
    var body: some View {
        Text(text)
            .font(.caption2)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.blue.opacity(0.08))
            .foregroundColor(.blue)
            .cornerRadius(12)
    }
}

struct StatItem: View {
    let value: String
    let label: String
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(Color.brandNavyAlias)
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct SettingsRow: View {
    let icon: String
    let title: String
    let subtitle: String
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color(uiColor: .systemGray6))
                    .frame(width: 40, height: 40)
                Image(systemName: icon)
                    .foregroundColor(.primary)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body)
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
                .font(.caption)
        }
        .padding()
    }
}
