import SwiftUI

struct ImageCalendarView: View {
    let daysInMonth: Int = 30
    let firstDayOfMonth: Int = 1
    
    enum DayOfWeek: Int {
        case monday = 1
        case tuesday = 2
        case wednesday = 3
        case thursday = 4
        case friday = 5
        case saturday = 6
        case sunday = 7
    }
    
    var body: some View {
        VStack {
            Text("Month Name") // 月の名前を表示する部分
                .font(.title)
                .padding()
            
            LazyVGrid(columns: Array(repeating: GridItem(), count: 7), spacing: 0) {
                ForEach(1...daysInMonth, id: \.self) { day in
                    Text("\(day)")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .border(Color.gray)
                }
            }
        }
    }
}

#Preview {
    ImageCalendarView()
}
