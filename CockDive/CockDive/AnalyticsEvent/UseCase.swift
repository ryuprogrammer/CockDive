import Foundation

protocol LogEventUseCase {
    func logShowView(viewName: ViewNameType)
    func logTapButton(buttonName: ButtonNameType)
}

class LogEventUserCaseImpl: LogEventUseCase {
    private let repository: LogEventRepository
    
    init(repository: LogEventRepository) {
        self.repository = repository
    }
    
    func logShowView(viewName: ViewNameType) {
        repository.log(event: .screenView(viewName))
    }
    
    func logTapButton(buttonName: ButtonNameType) {
        repository.log(event: .buttonTap(buttonName: buttonName))
    }
}
