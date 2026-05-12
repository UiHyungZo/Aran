import UIKit
import SwiftUI

enum AranFont {
    static func title(_ size: CGFloat = 20) -> Font { .system(size: size, weight: .bold) }
    static func body(_ size: CGFloat = 16) -> Font { .system(size: size, weight: .regular) }
    static func caption(_ size: CGFloat = 12) -> Font { .system(size: size, weight: .regular) }

    static func titleUI(_ size: CGFloat = 20) -> UIFont { .systemFont(ofSize: size, weight: .bold) }
    static func bodyUI(_ size: CGFloat = 16) -> UIFont { .systemFont(ofSize: size, weight: .regular) }
    static func captionUI(_ size: CGFloat = 12) -> UIFont { .systemFont(ofSize: size, weight: .regular) }
}
