import SwiftUI

/// `.navigationBarBackButtonHidden()` ẩn nút back hệ thống (để thay bằng nút
/// back tự vẽ trong header) nhưng vô tình tắt luôn cử chỉ vuốt từ mép màn
/// hình để back — bật lại cử chỉ đó ở đây.
private struct SwipeBackEnabler: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        let controller = UIViewController()
        DispatchQueue.main.async {
            controller.navigationController?.interactivePopGestureRecognizer?.delegate = nil
            controller.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        }
        return controller
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

extension View {
    func enableSwipeBack() -> some View {
        background(SwipeBackEnabler())
    }
}
