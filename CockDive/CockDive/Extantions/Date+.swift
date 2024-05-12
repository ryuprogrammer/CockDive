import Foundation

enum Weekday: Int, CaseIterable {
    case sunday = 0
    case monday = 1
    case tuesday = 2
    case wednesday = 3
    case thursday = 4
    case friday = 5
    case saturday = 6
    
    var name: String {
        switch self {
        case .sunday: return "日"
        case .monday: return "月"
        case .tuesday: return "火"
        case .wednesday: return "水"
        case .thursday: return "木"
        case .friday: return "金"
        case .saturday: return "土"
        }
    }
}

extension Date {
    /// 月の日数を取得
    var numberOfDaysInMonth: Int {
        let calendar = Calendar.current
        guard let range = calendar.range(of: .day, in: .month, for: self) else {
            return 30
        }
        return range.count
    }
    
    /// 月の最初の曜日を取得
    var weekdayOfFirstDay: Weekday {
        let calendar = Calendar.current
        let weekdayNumber = calendar.component(.weekday, from: self)
        return Weekday(rawValue: weekdayNumber) ?? Weekday.monday
    }
    
    /// 年と月を取得
    func yearAndMonth() -> String {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: self)
        let year = components.year ?? 2000 // デフォルト値は2000年
        let month = components.month ?? 1 // デフォルト値は1月
        
        return String(format: "%04d年%02d月", year, month)
    }
    
    // 月をIntで取得
    func month() -> Int {
        return Calendar.current.component(.month, from: self)
    }
    
    /// 次の月
    func nextMonth() -> Date {
        guard let nextMonthDate = Calendar.current.date(byAdding: .month, value: 1, to: self) else {
            return Date()
        }
        return nextMonthDate
    }
    
    /// 前の月
    func previousMonth() -> Date {
        guard let previousMonthDate = Calendar.current.date(byAdding: .month, value: -1, to: self) else {
            return Date()
        }
        return previousMonthDate
    }
}
