import Combine

class LogEventViewModel: ObservableObject {
    private let logEventUseCase: LogEventUseCase = LogEventUserCaseImpl(repository: LogEventRepositoryImpl())
    private var cancellables = Set<AnyCancellable>()

    @Published var screenName: ViewNameType?
    
    func logScreenView(_ screenName: ViewNameType) {
        logEventUseCase.logShowView(viewName: screenName)
        self.screenName = screenName
    }

    func logButtonTap(_ buttonName: ButtonNameType) {
        logEventUseCase.logTapButton(buttonName: buttonName)
    }
}
