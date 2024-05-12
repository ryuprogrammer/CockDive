import Foundation

extension Date {
    var numberOfDaysInMonth: Int? {
        let calendar = Calendar.current
        guard let range = calendar.range(of: .day, in: .month, for: self) else {
            return nil
        }
        return range.count
    }
    
    var weekdayOfFirstDay: Int? {
        let calendar = Calendar.current
        return calendar.component(.weekday, from: self)
    }
}
