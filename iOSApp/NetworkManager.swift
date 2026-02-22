import Foundation
import SwiftData
import os

struct OpportunityDTO: Codable {
    let id: UUID
    let schoolAbbr: String
    let schoolName: String
    let programName: String
    let location: String
    let description: String
    let websiteUrl: String
    let deadline: Date
    let tags: [String]
}

@Observable
final class NetworkManager {
    static let shared = NetworkManager()
    
    // In a real production scenario, this would point to your hosted JSON (e.g., GitHub Pages, AWS S3)
    // For this MVP, we use the raw URL from the GitHub repository where the GitHub Action commits the scraped data.
    // Replace 'YourUsername/YourRepo' with the actual repository:
    // let remoteJSONUrl = URL(string: "https://raw.githubusercontent.com/YourUsername/YourRepo/main/backend/scraper/opportunities.json")!
    let remoteJSONUrl = URL(string: "https://run.mocky.io/v3/YOUR-MOCK-ID-HERE")! // Placeholder for demo
    
    private let logger = Logger(subsystem: "com.globescholar", category: "NetworkManager")
    
    // We also provide a fast path to test with local bundled JSON for demonstration if remote is unavailable
    func fetchAndSync(context: ModelContext) async {
        do {
            logger.info("Attempting to fetch remote data...")
            // 1. Fetch JSON from remote
            // let (data, _) = try await URLSession.shared.data(from: remoteJSONUrl)
            
            // For MVP demonstration, since we don't have a real hosted URL yet,
            // we will simulate the remote fetch by parsing the local scraping output if available,
            // or we will just use this structure for when the user adds their real URL.
            
            // NOTE: Uncomment the URLSession line above and remove the dummy data below when using a real URL.
            let dummyJSON = """
            [
              {
                "id": "\(UUID().uuidString)",
                "schoolAbbr": "MIT",
                "schoolName": "Massachusetts Institute of Technology",
                "programName": "MSRP - MIT Summer Research Program",
                "location": "Cambridge, MA, USA",
                "description": "Remote fetched: The MIT Summer Research Program (MSRP) seeks to promote the value of graduate education...",
                "websiteUrl": "https://odge.mit.edu/undergraduate/msrp/",
                "deadline": "\(ISO8601DateFormatter().string(from: Date().addingTimeInterval(86400 * 15)))",
                "tags": ["Summer Research", "Engineering"]
              }
            ]
            """.data(using: .utf8)!
            let data = dummyJSON
            
            // 2. Decode the JSON
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            let downloadedItems = try decoder.decode([OpportunityDTO].self, from: data)
            
            // 3. Upsert into SwiftData
            await MainActor.run {
                for dto in downloadedItems {
                    let itemId = dto.id
                    let descriptor = FetchDescriptor<OpportunityItem>(predicate: #Predicate { $0.id == itemId })
                    
                    if let existing = try? context.fetch(descriptor).first {
                        // Update existing record (Upsert logic)
                        existing.schoolName = dto.schoolName
                        existing.schoolAbbr = dto.schoolAbbr
                        existing.programName = dto.programName
                        existing.programDescription = dto.description
                        existing.location = dto.location
                        existing.websiteUrl = dto.websiteUrl
                        existing.deadline = dto.deadline
                        existing.tags = dto.tags
                    } else {
                        // Insert new record
                        let newItem = OpportunityItem(
                            id: dto.id,
                            schoolName: dto.schoolName,
                            schoolAbbr: dto.schoolAbbr,
                            isOfficial: true,
                            programName: dto.programName,
                            programDescription: dto.description,
                            tags: dto.tags,
                            deadline: dto.deadline,
                            status: "Open",
                            location: dto.location,
                            websiteUrl: dto.websiteUrl
                        )
                        context.insert(newItem)
                    }
                }
                
                try? context.save()
                logger.info("Successfully synced \(downloadedItems.count) remote opportunities into SwiftData.")
                
                // If we had a global store injected here we could show a toast: "Database Updated!"
            }
            
        } catch {
            logger.error("Failed to sync remote data: \(error.localizedDescription)")
            // App gracefully falls back to existing local SwiftData cache without crashing
        }
    }
}
