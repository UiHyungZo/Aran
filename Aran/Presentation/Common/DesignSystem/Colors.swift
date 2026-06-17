import SwiftUI
import UIKit
import AranDomain

enum AranColor {
    static let primary = Color("primaryColor")
    static let secondary = Color("secondaryColor")
    static let background = Color("backgroundColor")
    static let surface = Color("surfaceColor")
    static let accentMedication = Color("accentMedication")
    static let accentHealth = Color("accentHealth")
    static let accentProcedure = Color("accentProcedure")
    static let accentDrug = Color("accentDrug")

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
    static let procedureChipBackground = accentProcedure.opacity(0.12)
    static let procedureChipText = accentProcedure

    // UIKit variants
    static let primaryUI = UIColor(named: "primaryColor") ?? .systemPink
    static let backgroundUI = UIColor(named: "backgroundColor") ?? .systemBackground
    static let surfaceUI = UIColor(named: "surfaceColor") ?? .secondarySystemBackground
    static let accentMedicationUI = UIColor(named: "accentMedication") ?? .systemPurple
    static let accentHealthUI = UIColor(named: "accentHealth") ?? .systemBlue
    static let accentProcedureUI = UIColor(named: "accentProcedure") ?? .systemGreen
    static let accentDrugUI = UIColor(named: "accentDrug") ?? .systemGreen
    static let healthRecordUI = accentHealthUI
    static let healthRecordFieldBackgroundUI = accentHealthUI.withAlphaComponent(0.12)
    static let badgeFailedBackgroundUI = UIColor(named: "badgeFailedBackground") ?? UIColor.systemRed.withAlphaComponent(0.12)
    static let badgeFailedTextUI = UIColor(named: "badgeFailedText") ?? .systemRed
    static let trendUpBackgroundUI = UIColor(named: "badgeFailedBackground") ?? UIColor.systemRed.withAlphaComponent(0.12)
    static let trendUpTextUI = UIColor(named: "badgeFailedText") ?? .systemRed
    static let trendDownBackgroundUI = UIColor(named: "badgeSuccessBackground") ?? UIColor.systemGreen.withAlphaComponent(0.12)
    static let trendDownTextUI = UIColor(named: "badgeSuccessText") ?? .systemGreen
}
