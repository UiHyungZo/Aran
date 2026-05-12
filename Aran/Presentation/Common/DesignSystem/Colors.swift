import UIKit
import SwiftUI

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

    // UIKit variants
    static let primaryUI = UIColor(named: "primaryColor") ?? .systemPink
    static let backgroundUI = UIColor(named: "backgroundColor") ?? .systemBackground
}
