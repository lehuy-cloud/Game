import SwiftUI

struct RewardStarsView: View {
    let count: Int

    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<count, id: \.self) { _ in
                Image(systemName: "star.fill")
                    .foregroundStyle(.yellow)
            }
        }
        .font(.title)
        .animation(.spring(response: 0.3, dampingFraction: 0.5), value: count)
    }
}
