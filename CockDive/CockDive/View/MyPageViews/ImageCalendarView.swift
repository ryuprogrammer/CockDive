import SwiftUI

struct ImageCalendarView: View {
    let daysInMonth: Int = Date().numberOfDaysInMonth ?? 30
    let firstDayOfMonth: Weekday = .wednesday
    
    var body: some View {
        VStack {
            Text(Date().yearAndMonth())
                .padding()
            
            HStack {
                ForEach(0..<Weekday.allCases.count, id: \.self) { week in
                    Text(Weekday(rawValue: week)?.name ?? "")
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, 5)
            
            LazyVGrid(columns: Array(repeating: GridItem(), count: 7), spacing: 5) {
                ForEach(0..<daysInMonth + firstDayOfMonth.rawValue, id: \.self) { day in
                    if day >= firstDayOfMonth.rawValue {
                        SmallImageView(day: day - firstDayOfMonth.rawValue + 1)
                            .frame(maxWidth: .infinity)
                    } else {
                        Spacer()
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 5)
        }
    }
}

#Preview {
    ImageCalendarView()
}
