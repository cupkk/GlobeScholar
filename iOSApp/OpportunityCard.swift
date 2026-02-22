import SwiftUI

struct OpportunityCard: View {
    let opportunity: OpportunityItem
    
    var daysLeft: Int {
        Calendar.current.dateComponents([.day], from: Date(), to: opportunity.deadline).day ?? 0
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack(alignment: .top) {
                // School Icon
                ZStack {
                    Circle()
                        .fill(Color(uiColor: .systemGray6))
                        .frame(width: 48, height: 48)
                    Image(systemName: "graduationcap")
                        .foregroundColor(Color.brandNavyAlias)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(opportunity.schoolAbbr)
                            .font(.headline)
                            .foregroundColor(Color.brandNavyAlias)
                        
                        if opportunity.isOfficial {
                            HStack(spacing: 2) {
                                Image(systemName: "checkmark.seal")
                                    .font(.caption2)
                                Text("Official")
                                    .font(.caption2)
                            }
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.blue.opacity(0.1))
                            .foregroundColor(.blue)
                            .cornerRadius(4)
                        }
                    }
                    
                    Text(opportunity.programName)
                        .font(.headline)
                        .fontWeight(.bold)
                        .lineLimit(2)
                }
                
                Spacer()
                
                // Deadline Pill
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .font(.caption)
                    Text("\(daysLeft)d")
                        .font(.caption)
                        .fontWeight(.bold)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.red.opacity(0.1))
                .foregroundColor(.red)
                .cornerRadius(12)
            }
            
            // Description
            Text(opportunity.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(2)
            
            Divider()
            
            // Footer Tags
            HStack {
                ForEach(opportunity.tags, id: \.self) { tag in
                    Text(tag)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(tag == "Funded" ? Color.green.opacity(0.1) : Color(uiColor: .systemGray6))
                        .foregroundColor(tag == "Funded" ? .green : .primary)
                        .cornerRadius(8)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
        }
        .padding(16)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}
