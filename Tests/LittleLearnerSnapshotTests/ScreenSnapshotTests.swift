import XCTest
import SwiftUI
@testable import LittleLearner

final class ScreenSnapshotTests: XCTestCase {
    private static let devices: [SnapshotHelper.DeviceSize] = [.iphone, .ipad]

    @MainActor
    func testCharacterSelection() async {
        for device in Self.devices {
            await SnapshotHelper.capture(name: "CharacterSelectionView", device: device) { CharacterSelectionView() }
        }
    }

    @MainActor
    func testVocabularyScreens() async {
        for device in Self.devices {
            await SnapshotHelper.capture(name: "VocabularyHomeView", device: device) { VocabularyHomeView() }
            await SnapshotHelper.capture(name: "FlashcardDeckView", device: device) { FlashcardDeckView(categoryId: Fixtures.categoryId) }
        }
    }

    @MainActor
    func testGamesHomeAndMatching() async {
        for device in Self.devices {
            await SnapshotHelper.capture(name: "GamesHomeView", device: device) { GamesHomeView() }
            await SnapshotHelper.capture(name: "MatchingHomeView", device: device) { MatchingHomeView() }
            await SnapshotHelper.capture(name: "LevelPickerView", device: device) { LevelPickerView(categoryId: Fixtures.categoryId) }
            await SnapshotHelper.capture(name: "MatchingGameView", device: device) {
                MatchingGameView(categoryId: Fixtures.categoryId, level: Fixtures.level)
            }
        }
    }

    @MainActor
    func testOtherGames() async {
        for device in Self.devices {
            await SnapshotHelper.capture(name: "ListenChooseGameView", device: device) { ListenChooseGameView() }
            await SnapshotHelper.capture(name: "SecretDoorGameView", device: device) { SecretDoorGameView() }
            await SnapshotHelper.capture(name: "OddOneOutGameView", device: device) { OddOneOutGameView() }
            await SnapshotHelper.capture(name: "CountingGameView", device: device) { CountingGameView() }
            await SnapshotHelper.capture(name: "MatchWordGameView", device: device) { MatchWordGameView() }
        }
    }

    @MainActor
    func testStoryScreens() async {
        for device in Self.devices {
            await SnapshotHelper.capture(name: "StoryListView", device: device) { StoryListView(path: .constant(NavigationPath())) }
            await SnapshotHelper.capture(name: "StoryHomeView", device: device) {
                StoryHomeView(story: Fixtures.story, path: .constant(NavigationPath()))
            }
            await SnapshotHelper.capture(name: "StoryChapterView", device: device) {
                StoryChapterView(chapter: Fixtures.chapter("ch1"), path: .constant(NavigationPath()))
            }
        }
    }

    @MainActor
    func testStoryMiniGames() async {
        for device in Self.devices {
            await SnapshotHelper.capture(name: "IceMeltGameView", device: device) {
                IceMeltGameView(chapter: Fixtures.chapter("ch1"), path: .constant(NavigationPath()))
            }
            await SnapshotHelper.capture(name: "LaughChaseGameView", device: device) {
                LaughChaseGameView(chapter: Fixtures.chapter("ch2"), path: .constant(NavigationPath()))
            }
            await SnapshotHelper.capture(name: "LanternPathGameView", device: device) {
                LanternPathGameView(chapter: Fixtures.chapter("ch3"), path: .constant(NavigationPath()))
            }
            await SnapshotHelper.capture(name: "StormBattleGameView", device: device) {
                StormBattleGameView(chapter: Fixtures.chapter("ch4"), path: .constant(NavigationPath()))
            }
        }
    }
}
