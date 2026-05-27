import SwiftUI
import UIKit

enum AranColor {
    static let primary = Color(uiColor: UIColor(named: "primaryColor") ?? .systemPink)
    static let secondary = Color("secondaryColor")
    static let background = Color("backgroundColor")

    static let dotHospital = Color("dotHospital")
    static let dotOvulation = Color("dotOvulation")
    static let dotPeriod = Color("dotPeriod")
    static let dotRetrieval = Color("dotRetrieval")
    static let dotTransfer = Color("dotTransfer")
    static let dotMedication = Color("dotMedication")
    static let dotHealthRecord = Color("dotHealthRecord")

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
}
