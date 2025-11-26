import SwiftUI

struct GenderData: Identifiable {
    let id = UUID()
    let gender: String
    let percent: Double
    let color: Color
}
