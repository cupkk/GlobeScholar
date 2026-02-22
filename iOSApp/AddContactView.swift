import SwiftUI
import SwiftData

struct AddContactView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) var dismiss
    
    // Form States
    @State private var name = ""
    @State private var title = ""
    @State private var email = ""
    @State private var selectedStatus: ContactStatus = .notContacted
    @State private var notes = ""
    
    var isFormValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Professor Details")) {
                    TextField("Name (e.g., Dr. John Smith)", text: $name)
                    TextField("Title & School (e.g., AI Lab, MIT)", text: $title)
                    TextField("Email Address", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                }
                
                Section(header: Text("Outreach Status")) {
                    Picker("Current Status", selection: $selectedStatus) {
                        ForEach(ContactStatus.allCases, id: \.self) { status in
                            Text(status.rawValue).tag(status)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                Section(header: Text("Notes")) {
                    TextEditor(text: $notes)
                        .frame(minHeight: 100)
                }
            }
            .navigationTitle("New Contact")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveContact()
                    }
                    .fontWeight(.bold)
                    .disabled(!isFormValid)
                }
            }
        }
    }
    
    private func saveContact() {
        // Create the new contact item
        let newContact = ContactItem(
            name: name,
            title: title + (email.isEmpty ? "" : " | \(email)"), // Combine title and email for MVP
            status: selectedStatus,
            date: Date()
        )
        // Store notes if needed (our MVP model doesn't explicitly have notes yet, but we can expand later)
        
        // Insert into SwiftData context
        modelContext.insert(newContact)
        
        // Trigger generic haptic success
        HapticManager.shared.notification(type: .success)
        dismiss()
    }
}

#Preview {
    AddContactView()
}
