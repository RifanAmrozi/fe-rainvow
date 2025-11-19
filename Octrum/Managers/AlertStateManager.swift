import Foundation
import Combine

class AlertStateManager: ObservableObject {
    static let shared = AlertStateManager()
    
    @Published private var alertStates: [String: Bool?] = [:]
    
    private init() {}
    
    func getAlertStatus(alertId: String) -> Bool? {
        return alertStates[alertId] ?? nil
    }
    
    func updateAlertStatus(alertId: String, isValid: Bool?) {
        alertStates[alertId] = isValid
    }
    
    func clearAllStates() {
        alertStates.removeAll()
    }
    
    func clearState(alertId: String) {
        alertStates.removeValue(forKey: alertId)
    }
}
