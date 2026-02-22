import Foundation

struct MockData {
    static let opportunities: [OpportunityItem] = [
        OpportunityItem(
            schoolName: "Massachusetts Institute of Technology",
            schoolAbbr: "MIT",
            isOfficial: true,
            programName: "2027 CS Summer Research",
            programDescription: "A highly prestigious 8-week summer research program in the Computer Science and Artificial Intelligence Laboratory (CSAIL). Focus on machine learning algorithms and systems.",
            tags: ["Summer Research", "CS", "Funded"],
            deadline: Calendar.current.date(byAdding: .day, value: 5, to: Date())!,
            status: "Fully Funded",
            location: "Cambridge, MA, USA"
        ),
        OpportunityItem(
            schoolName: "Stanford University",
            schoolAbbr: "Stanford",
            isOfficial: true,
            programName: "Human-Computer Interaction Fellowship",
            programDescription: "Research fellowship focusing on next-generation wearable technologies and accessible interfaces. Collaborate with top faculty.",
            tags: ["Fellowship", "HCI"],
            deadline: Calendar.current.date(byAdding: .day, value: 12, to: Date())!,
            status: "$5,000 Stipend",
            location: "Stanford, CA, USA"
        ),
        OpportunityItem(
            schoolName: "Carnegie Mellon University",
            schoolAbbr: "CMU",
            isOfficial: false,
            programName: "Robotics Institute Summer Scholars (RISS)",
            programDescription: "Intensive summer research program in robotics, computer vision, and autonomous systems.",
            tags: ["Summer Research", "Robotics"],
            deadline: Calendar.current.date(byAdding: .day, value: 20, to: Date())!,
            status: "Stipend + Housing",
            location: "Pittsburgh, PA, USA"
        ),
        OpportunityItem(
            schoolName: "ETH Zurich",
            schoolAbbr: "ETH",
            isOfficial: true,
            programName: "Student Summer Research Fellowship",
            programDescription: "Fellowship program for undergraduate and graduate students to gain research experience in computer science.",
            tags: ["Summer Research", "CS"],
            deadline: Calendar.current.date(byAdding: .day, value: 30, to: Date())!,
            status: "Travel + Stipend",
            location: "Zurich, Switzerland"
        ),
        OpportunityItem(
            schoolName: "The University of Tokyo",
            schoolAbbr: "UTokyo",
            isOfficial: true,
            programName: "Amgen Scholars Program",
            programDescription: "An undergraduate summer research program in science and biotechnology.",
            tags: ["Summer Research", "BioTech"],
            deadline: Calendar.current.date(byAdding: .day, value: 45, to: Date())!,
            status: "Fully Funded",
            location: "Tokyo, Japan"
        )
    ]
    
    // Provide some mock tasks
    static let tasks: [PlanTaskItem] = [
        PlanTaskItem(schoolAbbr: "MIT", schoolName: "MIT", programName: "2027 CS Summer Research", title: "Contact Prof. Smith via cold email", deadline: Calendar.current.date(byAdding: .day, value: 1, to: Date())!),
        PlanTaskItem(schoolAbbr: "MIT", schoolName: "MIT", programName: "2027 CS Summer Research", title: "Submit Online Application Form", deadline: Calendar.current.date(byAdding: .day, value: 4, to: Date())!),
        PlanTaskItem(schoolAbbr: "Stanford", schoolName: "Stanford", programName: "HCI Fellowship", title: "Draft Personal Statement", deadline: Calendar.current.date(byAdding: .day, value: 10, to: Date())!)
    ]
    
    // Provide some mock contacts
    static let contacts: [ContactItem] = [
        ContactItem(name: "Dr. Alan Turing", title: "Professor of AI, MIT", status: .replied),
        ContactItem(name: "Dr. Grace Hopper", title: "Systems Lab, Stanford", status: .followingUp),
        ContactItem(name: "Dr. John von Neumann", title: "Math Dept, Princeton", status: .emailSent)
    ]
}
