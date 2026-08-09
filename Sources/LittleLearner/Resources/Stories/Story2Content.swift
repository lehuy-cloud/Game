import Foundation

enum Story2Content {
    static let story = Story(
        id: "story2",
        title: "Câu chuyện mới",
        coverImageName: nil,
        accentHex: "#8BC34A",
        secondaryHex: "#F1F8E9",
        chapters: [
            StoryChapter(
                id: "s2_ch1",
                index: 1,
                title: "Chương 1",
                icon: "📖",
                imageName: nil,
                accentHex: "#8BC34A",
                secondaryHex: "#F1F8E9",
                pages: [
                    StoryPage(id: "s2_ch1_p1", text: "Nội dung đang được viết...", emoji: "✍️", imageName: nil),
                ],
                hasMiniGame: false,
                outroText: "Còn tiếp...",
                vocabCardIds: []
            ),
        ]
    )
}
