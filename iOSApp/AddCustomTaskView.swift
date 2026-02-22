import SwiftUI
import SwiftData

struct AddCustomTaskView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) var dismiss
    
    // Form States
    @State private var taskTitle = ""
    @State private var schoolName = ""
    @State private var programName = ""
    @State private var deadline = Calendar.current.date(byAdding: .day, value: 7, to: Date())!
    
    // Auto-generate abbreviation from school name
    var computedAbbr: String {
        let words = schoolName.components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }
        if words.isEmpty { return "NA" }
        if words.count == 1 { return String(words[0].prefix(2)).uppercased() }
        let first = String(words[0].prefix(1))
        let second = String(words[1].prefix(1))
        return (first + second).uppercased()
    }
    
    var isFormValid: Bool {
        !taskTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !schoolName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Target Program")) {
                    TextField("School Name (e.g., Stanford)", text: $schoolName)
                    TextField("Program/Lab Name (optional)", text: $programName)
                }
                
                Section(header: Text("Task Details")) {
                    TextField("Task Title (e.g., Write Statement of Purpose)", text: $taskTitle)
                    
                    DatePicker("Deadline", selection: $deadline, displayedComponents: [.date, .hourAndMinute])
                }
            }
            .navigationTitle("Add Custom Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveTask()
                    }
                    .fontWeight(.bold)
                    .disabled(!isFormValid)
                }
            }
        }
    }
    
    private func saveTask() {
        let newTask = PlanTaskItem(
            schoolAbbr: computedAbbr,
            schoolName: schoolName,
            programName: programName.isEmpty ? "General Application" : programName,
            title: taskTitle,
            deadline: deadline
        )
        
        modelContext.insert(newTask)
        
        // Schedule local push notification
        NotificationManager.shared.scheduleDeadlineNotification(
            id: newTask.id,
            title: newTask.title,
            school: newTask.schoolName,
            program: newTask.programName,
            deadline: newTask.deadline
        )
        
        HapticManager.shared.notification(type: .success)
        dismiss()
    }
}

#Preview {
    AddCustomTaskView()
}
