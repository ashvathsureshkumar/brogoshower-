import Foundation

// MARK: - Onboarding Data Models
struct OnboardingData {
    var race: Race?
    var major: Major?
    var showerFrequency: ShowerFrequency?
}

enum Race: String, CaseIterable {
    case asian = "Asian"
    case black = "Black"
    case white = "White"
    case latino = "Latino"
    case other = "Other"
}

enum Major: String, CaseIterable {
    case cs = "CS"
    case math = "Math"
    case physics = "Physics"
    case engineering = "Engineering"
}

enum ShowerFrequency: String, CaseIterable {
    case onceAWeek = "Once a week"
    case twiceAWeek = "Twice a week"
    case threeTimesAWeek = "Three times a week"
    case everyday = "Everyday"
    case twiceADay = "Twice a day"
    
    var needsDogAnimation: Bool {
        return self == .everyday || self == .twiceADay
    }
    
    var analysisResult: String {
        switch self {
        case .onceAWeek:
            return "Woah buddy, you need to shower A LOT"
        case .twiceAWeek:
            return "You definitely need to shower more"
        case .threeTimesAWeek:
            return "You need to shower more"
        case .everyday:
            return "Not bad, but you can do better"
        case .twiceADay:
            return "Wow, you're actually clean!"
        }
    }
} 