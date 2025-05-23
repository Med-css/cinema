import SwiftUI

struct MovieDetailView: View {
    let movie: Movie
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                AsyncImage(url: URL(string: "https://image.tmdb.org/t/p/w500\(movie.posterPath)")) { image in
                    image.resizable()
                } placeholder: {
                    Color.gray
                }
                .frame(height: 400)

                Text(movie.title)
                    .font(.largeTitle).bold()

                Text("Note: \(movie.voteAverage, specifier: "%.1f")")
                    .font(.headline)

                Text("Date de sortie: \(movie.releaseDate)")
                    .font(.subheadline)

                Text("Résumé")
                    .font(.headline)
                    .padding(.top)

                Text(movie.overview)
                    .font(.body)
            }
            .padding()
        }
        .navigationTitle(movie.title)
    }
}
