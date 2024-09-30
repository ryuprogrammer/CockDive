import Foundation
import Firebase
import FirebaseAnalytics

// Action
enum LogEventAction {
    case screenView(ViewNameType)
    case buttonTap(buttonName: ButtonNameType)
}

protocol LogEventRepository {
    func log(event: LogEventAction)
}

// Repository
class LogEventRepositoryImpl: LogEventRepository {
    func log(event: LogEventAction) {
        event.log()
    }
}

extension LogEventAction {
    func log() {
        switch self {
        case .screenView(let screenName):
            Analytics.logEvent("show_view222", parameters: [
                "show_view222": screenName.rawValue
            ])
//            Analytics.logEvent(AnalyticsEventScreenView, parameters: [
//                AnalyticsParameterScreenName: screenName.rawValue,
//                AnalyticsParameterScreenClass: "ScreenView"
//            ])
            
        case .buttonTap(let buttonName):
            Analytics.logEvent("button_tap", parameters: [
                "button_name": buttonName.rawValue
            ])
        }
    }
}
