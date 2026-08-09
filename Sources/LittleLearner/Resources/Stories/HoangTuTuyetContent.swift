import Foundation

enum HoangTuTuyetContent {
    static let story = Story(
        id: "hoang_tu_tuyet",
        title: "Hoàng tử Tuyết và Những Người Bạn",
        coverImageName: "story_cover",
        accentHex: "#4FC3F7",
        secondaryHex: "#E1F5FE",
        chapters: [
            StoryChapter(
                id: "ch1",
                index: 1,
                title: "Người bạn đầu tiên",
                icon: "🦊",
                imageName: "hoang_tu_portrait",
                accentHex: "#4FC3F7",
                secondaryHex: "#E1F5FE",
                pages: [
                    StoryPage(id: "ch1_p1", text: "Trong khu rừng băng giá, Hoàng tử Tuyết nghe thấy tiếng kêu yếu ớt. Đó là một chú cáo tuyết bị mắc kẹt trong khối băng.", emoji: "🧊", imageName: "ch1_ice_fox"),
                    StoryPage(id: "ch1_p2", text: "Hoàng tử nhẹ nhàng đặt tay lên khối băng. Phép thuật tỏa sáng lấp lánh khắp nơi, băng dần tan chảy.", emoji: "✨", imageName: "ch1_hero"),
                    StoryPage(id: "ch1_p3", text: "Chú cáo nhảy ra, đôi mắt sáng rực biết ơn. Từ hôm đó, chú cáo trở thành người bạn đồng hành đầu tiên, luôn nhanh nhẹn và thông minh.", emoji: "🦊", imageName: "hoang_tu_va_cao"),
                ],
                hasMiniGame: true,
                outroText: "Chú cáo nhảy ra, đôi mắt sáng rực biết ơn. Từ hôm đó, chú cáo trở thành người bạn đồng hành đầu tiên, luôn nhanh nhẹn và thông minh!",
                vocabCardIds: ["story_fox"]
            ),
            StoryChapter(
                id: "ch2",
                index: 2,
                title: "Tiếng cười giữa trời tuyết",
                icon: "🐧",
                imageName: "ch2_penguin_map",
                accentHex: "#FF9F43",
                secondaryHex: "#FFF3E0",
                pages: [
                    StoryPage(id: "ch2_p1", text: "Khi đi sâu hơn vào rừng, hoàng tử và cáo tuyết gặp một chú chim cánh cụt đang lạc đường.", emoji: "🐧", imageName: "ch2_penguin_map"),
                    StoryPage(id: "ch2_p2", text: "Chim cánh cụt kể những câu chuyện ngộ nghĩnh, khiến cả nhóm cười vang.", emoji: "😄", imageName: "ch2_penguin_laugh"),
                    StoryPage(id: "ch2_p3", text: "Tiếng cười ấy xua tan cái lạnh buốt, làm cho hành trình trở nên ấm áp hơn. Hoàng tử nhận ra rằng niềm vui cũng là một phép màu.", emoji: "😄", imageName: "ch2_penguin_laugh"),
                ],
                hasMiniGame: true,
                outroText: "Tiếng cười ấy xua tan cái lạnh buốt, làm cho hành trình trở nên ấm áp hơn. Hoàng tử nhận ra rằng niềm vui cũng là một phép màu!",
                vocabCardIds: ["story_penguin", "story_laugh"]
            ),
            StoryChapter(
                id: "ch3",
                index: 3,
                title: "Ngọn đèn trong đêm tối",
                icon: "🔦",
                imageName: "den_portrait",
                accentHex: "#FFC107",
                secondaryHex: "#FFF8E1",
                pages: [
                    StoryPage(id: "ch3_p1", text: "Đêm xuống, tuyết phủ dày đặc, cả nhóm gần như không thấy đường.", emoji: "🌑", imageName: "ch3_dark_forest"),
                    StoryPage(id: "ch3_p2", text: "Bỗng một cậu bé từ ngôi làng gần rừng xuất hiện, mang theo ngọn đèn nhỏ.", emoji: "🔦", imageName: "ch3_lantern_boy"),
                    StoryPage(id: "ch3_p3", text: "Ánh sáng vàng ấm áp soi đường, giúp họ vượt qua bóng tối. Cậu bé dũng cảm, không ngại nguy hiểm, và nhanh chóng trở thành người bạn mới của cả nhóm!", emoji: "🔦", imageName: "ch3_lantern_boy"),
                ],
                hasMiniGame: true,
                outroText: "Ánh sáng vàng ấm áp soi đường, giúp họ vượt qua bóng tối. Cậu bé dũng cảm, không ngại nguy hiểm, và nhanh chóng trở thành người bạn mới của cả nhóm!",
                vocabCardIds: ["story_lantern", "story_brave"]
            ),
            StoryChapter(
                id: "ch4",
                index: 4,
                title: "Cơn bão của phù thủy bóng tối",
                icon: "🌪️",
                imageName: "witch_portrait",
                accentHex: "#7E57C2",
                secondaryHex: "#EDE7F6",
                pages: [
                    StoryPage(id: "ch4_p1", text: "Một ngày, bầu trời đen kịt, gió rít lên dữ dội. Phù thủy bóng tối xuất hiện, tạo ra cơn bão tuyết ma thuật muốn nuốt chửng vương quốc.", emoji: "🧙", imageName: "ch4_witch_appear"),
                    StoryPage(id: "ch4_p2", text: "Hoàng tử và những người bạn run sợ, nhưng họ quyết định cùng nhau đối mặt với cơn bão!", emoji: "🌪️", imageName: "ch4_prince_shield"),
                    StoryPage(id: "ch4_p3", text: "Cáo tuyết dẫn đường, chim cánh cụt mang lại tiếng cười, cậu bé thắp sáng ngọn đèn, còn hoàng tử dùng phép thuật — cả nhóm cùng nhau đẩy lùi cơn bão!", emoji: "🌪️", imageName: "ch4_prince_shield"),
                ],
                hasMiniGame: true,
                outroText: "Cáo tuyết dẫn đường, chim cánh cụt mang lại tiếng cười, cậu bé thắp sáng ngọn đèn, còn hoàng tử dùng phép thuật — cả nhóm cùng nhau đẩy lùi cơn bão!",
                vocabCardIds: ["story_storm", "story_witch"]
            ),
            StoryChapter(
                id: "ch5",
                index: 5,
                title: "Chiến thắng và tình bạn",
                icon: "🌟",
                imageName: "ch5_ending",
                accentHex: "#FFD54F",
                secondaryHex: "#FFFDE7",
                pages: [
                    StoryPage(id: "ch5_p1", text: "Sau một trận chiến dài, ánh sáng, niềm vui và tình bạn đã hợp lực cùng phép thuật của hoàng tử để đánh bại phù thủy.", emoji: "⚔️", imageName: "ch5_victory"),
                    StoryPage(id: "ch5_p2", text: "Bão tan, tuyết trở lại hiền hòa, vương quốc rực rỡ dưới ánh sáng lung linh.", emoji: "🏰", imageName: "ch5_ending"),
                    StoryPage(id: "ch5_p3", text: "Hoàng tử mỉm cười, không còn cô đơn nữa, bởi bên cạnh cậu đã có những người bạn tuyệt vời.", emoji: "🏰", imageName: "ch5_ending"),
                ],
                hasMiniGame: false,
                outroText: "Hoàng tử mỉm cười, không còn cô đơn nữa, bởi bên cạnh cậu đã có những người bạn tuyệt vời. Hết truyện! 🎉",
                vocabCardIds: ["story_friend"]
            ),
        ]
    )
}
