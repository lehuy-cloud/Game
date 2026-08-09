import Foundation

enum StoryRoute: Hashable {
    case story(Story)
    case chapter(StoryChapter)
    case miniGame(StoryChapter)
}
