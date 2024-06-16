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
    
    /// その月の1日目の曜日を取得
    var weekdayOfFirstDay: Weekday {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month], from: self)
        components.day = 1
        let firstDayOfMonth = calendar.date(from: components)!
        let weekdayNumber = calendar.component(.weekday, from: firstDayOfMonth) - 1 // 日曜日を0とする
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
    
    /// 日時のStringを取得
    func dateString() -> String {
        let calendar = Calendar.current
        let dateFormatter = DateFormatter()
        
        // 今年以外なら、年月日を書く
        if calendar.component(.year, from: self) != calendar.component(.year, from: Date()) {
            dateFormatter.dateFormat = "yyyy年M月d日H:mm"
            return dateFormatter.string(from: self)
        }
        
        // 今年で今日と昨日以外なら、月+日+時間を書く
        if !calendar.isDateInToday(self) && !calendar.isDateInYesterday(self) {
            dateFormatter.dateFormat = "M月d日H:mm"
            return dateFormatter.string(from: self)
        }
        
        // 昨日なら、「"昨日"+時間」を書く
        if calendar.isDateInYesterday(self) {
            dateFormatter.dateFormat = "'昨日 'HH:mm"
            return dateFormatter.string(from: self)
        }
        
        // 今日なら、「"今日"+時間」を書く
        dateFormatter.dateFormat = "'今日 'HH:mm"
        return dateFormatter.string(from: self)
    }

    /// 日付のみ（"M月d日"）
    func dateStringDate() -> String {
        let dateFormatter = DateFormatter()

        dateFormatter.dateFormat = "M月d日"
        return dateFormatter.string(from: self)
    }
}
