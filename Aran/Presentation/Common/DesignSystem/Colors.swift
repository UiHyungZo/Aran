import SwiftUI
import UIKit

enum AranColor {
    static let primary = Color("primaryColor")
    static let secondary = Color("secondaryColor")
    static let background = Color("backgroundColor")

    static let dotHospital = Color("dotHospital")
    static let dotOvulation = Color("dotOvulation")
    static let dotPeriod = Color("dotPeriod")
    static let dotRetrieval = Color("dotRetrieval")
    static let dotTransfer = Color("dotTransfer")
    static let dotMedication = Color("dotMedication")
    static let dotHealthRecord = Color("dotHealthRecord")
    static let dotDiary = Color("dotDiary")

    static let badgePendingBackground = Color("badgePendingBackground")
    static let badgePendingText = Color("badgePendingText")
    static let badgeSuccessBackground = Color("badgeSuccessBackground")
    static let badgeSuccessText = Color("badgeSuccessText")
    static let badgeFailedBackground = Color("badgeFailedBackground")
    static let badgeFailedText = Color("badgeFailedText")
    static let procedureChipBackground = dotTransfer.opacity(0.12)
    static let procedureChipText = dotTransfer

    // UIKit variants
    static let primaryUI = UIColor(named: "primaryColor") ?? .systemPink
    static let backgroundUI = UIColor(named: "backgroundColor") ?? .systemBackground
    static let healthRecordUI = UIColor(named: "dotHealthRecord") ?? UIColor(red: 0.094, green: 0.373, blue: 0.647, alpha: 1)
    static let healthRecordFieldBackgroundUI = UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark
            ? UIColor.secondarySystemGroupedBackground
            : UIColor(red: 0.902, green: 0.945, blue: 0.984, alpha: 1)
    }
    static let trendUpBackgroundUI = UIColor(named: "badgeFailedBackground") ?? UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 0.271, green: 0.039, blue: 0.039, alpha: 1)
            : UIColor(red: 0.988, green: 0.922, blue: 0.922, alpha: 1)
    }
    static let trendUpTextUI = UIColor(named: "badgeFailedText") ?? UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 0.988, green: 0.647, blue: 0.647, alpha: 1)
            : UIColor(red: 0.639, green: 0.176, blue: 0.176, alpha: 1)
    }
    static let trendDownBackgroundUI = UIColor(named: "badgeSuccessBackground") ?? UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 0.008, green: 0.173, blue: 0.133, alpha: 1)
            : UIColor(red: 0.882, green: 0.961, blue: 0.933, alpha: 1)
    }
    static let trendDownTextUI = UIColor(named: "badgeSuccessText") ?? UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 0.431, green: 0.906, blue: 0.718, alpha: 1)
            : UIColor(red: 0.031, green: 0.314, blue: 0.255, alpha: 1)
    }
}
