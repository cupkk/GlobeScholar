import SwiftUI
import SwiftData

struct PlanView: View {
    @Query(sort: \PlanTaskItem.deadline) private var tasks: [PlanTaskItem]
    @Query(sort: \ContactItem.date, order: .reverse) private var contacts: [ContactItem]
    
    @State private var selectedTab = 0
    @State private var showingAddTask = false
    @State private var showingAddContact = false
    
    var body: some View {
        NavigationStack {
            VStack {
                // Header
                let completedCount = tasks.filter { $0.isCompleted }.count
                VStack(alignment: .leading, spacing: 4) {
                    Text("My Plan")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    Text("\(completedCount) of \(tasks.count) tasks done")
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                
                // Custom Segmented Control
                HStack(spacing: 0) {
                    SegmentButton(title: "Tasks", isSelected: selectedTab == 0) { selectedTab = 0 }
                    SegmentButton(title: "Contacts", isSelected: selectedTab == 1) { selectedTab = 1 }
                }
                .background(Color(uiColor: .secondarySystemGroupedBackground))
                .cornerRadius(12)
                .padding(.horizontal)
                .padding(.bottom, 8)
                
                // Content
                ScrollView {
                    if selectedTab == 0 {
                        TasksTab(tasks: tasks)
                    } else {
                        ContactsTab(contacts: contacts)
                    }
                }
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .overlay(
                Button(action: {
                    if selectedTab == 0 {
                        showingAddTask = true
                    } else {
                        showingAddContact = true
                    }
                }) {
                    Image(systemName: "plus")
                        .font(.title2)
                        .padding(16)
                        .background(Color.brandNavyAlias)
                        .foregroundColor(.white)
                        .clipShape(Circle())
                        .shadow(color: Color.black.opacity(0.15), radius: 6, x: 0, y: 3)
                }
                .padding()
                , alignment: .bottomTrailing
            )
        }
        .sheet(isPresented: $showingAddTask) {
            AddCustomTaskView()
        }
        .sheet(isPresented: $showingAddContact) {
            AddContactView()
        }
    }
}

// Subviews for PlanView
struct SegmentButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(isSelected ? Color(uiColor: .systemBackground) : Color.clear)
                .foregroundColor(isSelected ? .primary : .secondary)
                .cornerRadius(10)
                .shadow(color: isSelected ? Color.black.opacity(0.05) : Color.clear, radius: 2, y: 1)
        }
        .padding(2)
    }
}

struct TasksTab: View {
    let tasks: [PlanTaskItem]
    
    var body: some View {
        let completedCount = tasks.filter { $0.isCompleted }.count
        let totalCount = tasks.count
        let progress = totalCount > 0 ? CGFloat(completedCount) / CGFloat(totalCount) : 0
        
        VStack(spacing: 16) {
            // Overall Progress
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Overall Progress")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("\(Int(progress * 100))%")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(Color.brandNavyAlias)
                }
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color(uiColor: .systemGray5))
                            .frame(height: 8)
                        Capsule()
                            .fill(Color.brandNavyAlias)
                            .frame(width: geometry.size.width * progress, height: 8)
                    }
                }
                .frame(height: 8)
                
                HStack {
                    Text("\(completedCount) completed")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("\(totalCount - completedCount) remaining")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(Color(uiColor: .secondarySystemGroupedBackground))
            .cornerRadius(12)
            .padding(.horizontal)
            
            // Task List Segment (Grouped by School)
            if tasks.isEmpty {
                VStack(spacing: 24) {
                    ZStack {
                        Circle()
                            .fill(Color.brandNavyAlias.opacity(0.1))
                            .frame(width: 80, height: 80)
                        Image(systemName: "list.clipboard")
                            .font(.system(size: 32))
                            .foregroundColor(Color.brandNavyAlias)
                    }
                    
                    VStack(spacing: 8) {
                        Text("No Tasks Yet")
                            .font(.title3)
                            .fontWeight(.bold)
                        Text("Add programs from Discover to automatically generate standard application task checklists.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                    }
                }
                .padding(.vertical, 60)
                .frame(maxWidth: .infinity)
            } else {
                let groupedTasks = Dictionary(grouping: tasks, by: { $0.schoolAbbr })
                
                ForEach(Array(groupedTasks.keys.sorted()), id: \.self) { abbr in
                    if let schoolTasks = groupedTasks[abbr], let firstTask = schoolTasks.first {
                        let schoolCompleted = schoolTasks.filter { $0.isCompleted }.count
                        
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                ZStack {
                                    Circle()
                                        .fill(Color(uiColor: .systemGray5))
                                        .frame(width: 40, height: 40)
                                    Text(abbr)
                                        .font(.headline)
                                        .foregroundColor(Color.brandNavyAlias)
                                }
                                
                                VStack(alignment: .leading) {
                                    Text(firstTask.schoolName)
                                        .font(.headline)
                                    Text(firstTask.programName)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                // Sub progess
                                HStack(spacing: 4) {
                                    Capsule().fill(Color.brandNavyAlias).frame(width: 20, height: 6)
                                    Capsule().fill(Color(uiColor: .systemGray5)).frame(width: 20, height: 6)
                                    Text("\(schoolCompleted)/\(schoolTasks.count)").font(.caption).foregroundColor(.secondary)
                                }
                            }
                            .padding(.horizontal)
                            
                            VStack(spacing: 0) {
                                ForEach(schoolTasks) { task in
                                    TaskRow(task: task)
                                    if task.id != schoolTasks.last?.id {
                                        Divider()
                                            .padding(.leading, 48)
                                    }
                                }
                            }
                            .background(Color(uiColor: .secondarySystemGroupedBackground))
                            .cornerRadius(12)
                            .padding(.horizontal)
                        }
                    }
                }
            }
        }
        .padding(.vertical)
    }
}

struct TaskRow: View {
    @Bindable var task: PlanTaskItem
    
    var body: some View {
        Button(action: {
            task.isCompleted.toggle()
            HapticManager.shared.impact(style: task.isCompleted ? .medium : .light)
        }) {
            HStack(spacing: 16) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(task.isCompleted ? .brandNavyAlias : .gray)
                    .font(.title3)
            
            HStack {
                Text(task.title)
                    .strikethrough(task.isCompleted)
                    .foregroundColor(task.isCompleted ? .secondary : .primary)
                    .lineLimit(2)
                
                Spacer()
                
                Label(task.deadline, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .padding()
    }
}

struct ContactsTab: View {
    let contacts: [ContactItem]
    
    var body: some View {
        VStack(spacing: 12) {
            if contacts.isEmpty {
                VStack(spacing: 24) {
                    ZStack {
                        Circle()
                            .fill(Color.blue.opacity(0.1))
                            .frame(width: 80, height: 80)
                        Image(systemName: "person.crop.circle.badge.plus")
                            .font(.system(size: 32))
                            .foregroundColor(.blue)
                    }
                    
                    VStack(spacing: 8) {
                        Text("Empty CRM")
                            .font(.title3)
                            .fontWeight(.bold)
                        Text("Start adding professors and track your cold email and follow-up status here.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                    }
                }
                .padding(.vertical, 60)
                .frame(maxWidth: .infinity)
            } else {
                ForEach(contacts) { contact in
                HStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(Color(uiColor: .systemGray6))
                            .frame(width: 48, height: 48)
                        Image(systemName: "person.circle")
                            .foregroundColor(Color.brandNavyAlias)
                            .font(.title2)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(contact.name)
                            .font(.headline)
                        Text(contact.title)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        HStack {
                            Text(contact.status.rawValue)
                                .font(.caption2)
                                .fontWeight(.medium)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(contact.status.color.opacity(0.1))
                                .foregroundColor(contact.status.color)
                                .cornerRadius(4)
                            
                            Text(contact.date, style: .date)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    Button(action: {}) {
                        Image(systemName: "envelope")
                            .foregroundColor(.secondary)
                            .padding(10)
                            .background(Color(uiColor: .systemGray6))
                            .clipShape(Circle())
                    }
                }
                .padding()
                .background(Color(uiColor: .secondarySystemGroupedBackground))
                .cornerRadius(12)
                .padding(.horizontal)
            }
        }
        .padding(.vertical)
    }
}
