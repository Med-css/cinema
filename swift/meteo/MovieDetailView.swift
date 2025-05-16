
import SwiftUI

struct MovieDetailView: View {
    let movie: Movie

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                AsyncImage(url: URL(string: "https://image.tmdb.org/t/p/w500\(movie.posterPath)")) { image in
                    image.resizable()
                } placeholder: {
                    Color.gray
                }
                .frame(height: 500)

                Text(movie.title)
                    .font(.title)

                Text("Date de sortie: \(movie.releaseDate)")
                    .font(.subheadline)
                    .padding(.top, 5)

                Text(movie.overview)
                    .font(.body)
                    .padding(.top, 10)

                HStack {
                    Text("Note :")
                    Text(String(format: "%.1f", movie.voteAverage))
                }
                .font(.caption)
                .padding(.top, 10)
            }
            .padding()
        }
        .navigationTitle(movie.title)
    }
}
