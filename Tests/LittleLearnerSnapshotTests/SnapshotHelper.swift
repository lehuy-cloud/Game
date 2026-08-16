import SwiftUI
import UIKit
import XCTest
@testable import LittleLearner

/// Render 1 screen ra PNG bằng ImageRenderer — không cần simulator UI,
/// không bị các cửa sổ khác che mất như thao tác chuột thủ công.
@MainActor
enum SnapshotHelper {
    static let outputDirectory: URL = {
        // Simulator process có quyền ghi thẳng vào đường dẫn thật trên Mac (không sandbox
        // như thiết bị thật), nên ghi cứng path thay vì dùng homeDirectoryForCurrentUser
        // (API không có trên iOS).
        let dir = URL(fileURLWithPath: "/Users/lehuy/Desktop/LittleLearnerSnapshots", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }()

    enum DeviceSize {
        case iphone
        case ipad

        var size: CGSize {
            switch self {
            case .iphone: CGSize(width: 402, height: 874)
            case .ipad: CGSize(width: 1032, height: 1376)
            }
        }

        var sizeClass: UserInterfaceSizeClass {
            switch self {
            case .iphone: .compact
            case .ipad: .regular
            }
        }

        var suffix: String {
            switch self {
            case .iphone: "iphone"
            case .ipad: "ipad"
            }
        }
    }

    static func capture<V: View>(name: String, device: DeviceSize, @ViewBuilder content: () -> V) async {
        let profileStore = Fixtures.profileStore()
        let progressStore = Fixtures.progressStore()
        let theme = Theme.named(profileStore.themeId)

        let wrapped = content()
            .environment(profileStore)
            .environment(progressStore)
            .environment(\.theme, theme)
            .environment(\.horizontalSizeClass, device.sizeClass)
            .frame(width: device.size.width, height: device.size.height)

        let renderer = ImageRenderer(content: wrapped)
        renderer.proposedSize = ProposedViewSize(device.size)
        renderer.scale = 2

        // Render nháp để .onAppear kịp chạy (build board/questions), rồi chờ 1 nhịp trước khi chụp thật.
        _ = renderer.uiImage
        try? await Task.sleep(for: .milliseconds(200))

        guard let image = renderer.uiImage, let data = image.pngData() else {
            XCTFail("Không render được \(name) (\(device.suffix))")
            return
        }
        let url = outputDirectory.appendingPathComponent("\(name)-\(device.suffix).png")
        try? data.write(to: url)
    }
}
