import SwiftUI

struct ImageCalendarView: View {
    // 表示されている月
    @State private var showingDate = Date()
    
    var body: some View {
        VStack {
            HStack {
                Button {
                    showingDate = showingDate.previousMonth()
                } label: {
                    StrokeButtonUI(text: "\(showingDate.previousMonth().month())月", size: .small, isFill: false)
                }
                
                StrokeButtonUI(text: showingDate.yearAndMonth(), size: .small, isFill: true)
                
                Button {
                    showingDate = showingDate.nextMonth()
                } label: {
                    StrokeButtonUI(text: "\(showingDate.nextMonth().month())月", size: .small, isFill: false)
                }
            }
            
            HStack {
                ForEach(0..<Weekday.allCases.count, id: \.self) { week in
                    Text(Weekday(rawValue: week)?.name ?? "")
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, 5)
            
            LazyVGrid(columns: Array(repeating: GridItem(), count: 7), spacing: 5) {
                ForEach(0..<showingDate.numberOfDaysInMonth + showingDate.weekdayOfFirstDay.rawValue + 2, id: \.self) { day in
                    if day > showingDate.weekdayOfFirstDay.rawValue + 1 {
                        SmallImageView(day: day - showingDate.weekdayOfFirstDay.rawValue - 1)
                            .frame(maxWidth: .infinity)
                    } else {
                        Spacer()
                    }
                }
            }
            .animation(.linear, value: showingDate)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 5)
        }
    }
}

#Preview {
    ImageCalendarView()
}

