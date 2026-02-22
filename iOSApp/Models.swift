import Foundation
import SwiftData
import SwiftUI

// MARK: - SwiftData Models

@Model
final class OpportunityItem {
    @Attribute(.unique) var id: UUID
    var schoolName: String
    var schoolAbbr: String
    var isOfficial: Bool
    var programName: String
    var programDescription: String
    var tags: [String]
    var deadline: Date
    var status: String
    var location: String
    var websiteUrl: String // Added for remote JSON and in-app browser
    
    // Relationship: Whether user has saved this
    var isSaved: Bool
    var dateSaved: Date?

    init(id: UUID = UUID(), schoolName: String, schoolAbbr: String, isOfficial: Bool, programName: String, programDescription: String, tags: [String], deadline: Date, status: String, location: String, websiteUrl: String = "https://www.university.edu", isSaved: Bool = false, dateSaved: Date? = nil) {
        self.id = id
        self.schoolName = schoolName
        self.schoolAbbr = schoolAbbr
        self.isOfficial = isOfficial
        self.programName = programName
        self.programDescription = programDescription
        self.tags = tags
        self.deadline = deadline
        self.status = status
        self.location = location
        self.websiteUrl = websiteUrl
        self.isSaved = isSaved
        self.dateSaved = dateSaved
    }
}

@Model
final class PlanTaskItem {
    @Attribute(.unique) var id: UUID
    var schoolAbbr: String
    var schoolName: String
    var programName: String
    var title: String
    var deadline: Date
    var isCompleted: Bool
    var createdAt: Date

    init(id: UUID = UUID(), schoolAbbr: String, schoolName: String, programName: String, title: String, deadline: Date, isCompleted: Bool = false, createdAt: Date = Date()) {
        self.id = id
        self.schoolAbbr = schoolAbbr
        self.schoolName = schoolName
        self.programName = programName
        self.title = title
        self.deadline = deadline
        self.isCompleted = isCompleted
        self.createdAt = createdAt
    }
}

@Model
final class ContactItem {
    @Attribute(.unique) var id: UUID
    var name: String
    var title: String
    var statusRawValue: String
    var date: Date
    
    var status: ContactStatus {
        get { ContactStatus(rawValue: statusRawValue) ?? .notContacted }
        set { statusRawValue = newValue.rawValue }
    }

    init(id: UUID = UUID(), name: String, title: String, status: ContactStatus, date: Date = Date()) {
        self.id = id
        self.name = name
        self.title = title
        self.statusRawValue = status.rawValue
        self.date = date
    }
}

// Keeping the enum for UI mapping
enum ContactStatus: String, Codable, CaseIterable {
    case replied = "Replied"
    case emailSent = "Email Sent"
    case followingUp = "Following Up"
    case notContacted = "Not Contacted"
    
    var color: Color {
        switch self {
        case .replied: return .green
        case .emailSent: return .blue
        case .followingUp: return .orange
        case .notContacted: return .gray
        }
    }
}
