import Foundation

enum VocabularyContent {
    static let categories: [VocabularyCategory] = [
        VocabularyCategory(id: "animals", title: "Animals", symbolName: "pawprint.fill", colorHex: "#FF9F43"),
        VocabularyCategory(id: "colors", title: "Colors", symbolName: "paintpalette.fill", colorHex: "#5F27CD"),
    ]

    static let cards: [VocabularyCard] = [
        VocabularyCard(id: "animal_dog", word: "Dog", emoji: "🐶", symbolName: "dog.fill", imageName: nil, categoryId: "animals"),
        VocabularyCard(id: "animal_cat", word: "Cat", emoji: "🐱", symbolName: "cat.fill", imageName: nil, categoryId: "animals"),
        VocabularyCard(id: "animal_bird", word: "Bird", emoji: "🐦", symbolName: "bird.fill", imageName: nil, categoryId: "animals"),
        VocabularyCard(id: "animal_fish", word: "Fish", emoji: "🐟", symbolName: "fish.fill", imageName: nil, categoryId: "animals"),
        VocabularyCard(id: "animal_rabbit", word: "Rabbit", emoji: "🐰", symbolName: "hare.fill", imageName: nil, categoryId: "animals"),
        VocabularyCard(id: "animal_bear", word: "Bear", emoji: "🐻", symbolName: nil, imageName: nil, categoryId: "animals"),
        VocabularyCard(id: "animal_lion", word: "Lion", emoji: "🦁", symbolName: nil, imageName: nil, categoryId: "animals"),
        VocabularyCard(id: "animal_elephant", word: "Elephant", emoji: "🐘", symbolName: nil, imageName: nil, categoryId: "animals"),

        VocabularyCard(id: "color_red", word: "Red", emoji: "🔴", symbolName: "circle.fill", imageName: nil, categoryId: "colors"),
        VocabularyCard(id: "color_blue", word: "Blue", emoji: "🔵", symbolName: "circle.fill", imageName: nil, categoryId: "colors"),
        VocabularyCard(id: "color_yellow", word: "Yellow", emoji: "🟡", symbolName: "circle.fill", imageName: nil, categoryId: "colors"),
        VocabularyCard(id: "color_green", word: "Green", emoji: "🟢", symbolName: "circle.fill", imageName: nil, categoryId: "colors"),
        VocabularyCard(id: "color_orange", word: "Orange", emoji: "🟠", symbolName: "circle.fill", imageName: nil, categoryId: "colors"),
        VocabularyCard(id: "color_purple", word: "Purple", emoji: "🟣", symbolName: "circle.fill", imageName: nil, categoryId: "colors"),
        VocabularyCard(id: "color_pink", word: "Pink", emoji: "🩷", symbolName: "circle.fill", imageName: nil, categoryId: "colors"),
        VocabularyCard(id: "color_black", word: "Black", emoji: "⚫", symbolName: "circle.fill", imageName: nil, categoryId: "colors"),
    ]

    static func cards(for categoryId: String) -> [VocabularyCard] {
        cards.filter { $0.categoryId == categoryId }
    }
}
