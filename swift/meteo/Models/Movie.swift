import Foundation

struct Movie: Identifiable {
    let id = UUID()
    let title: String
    let overview: String
    let posterPath: String
    let voteAverage: Double
    let releaseDate: String
}
