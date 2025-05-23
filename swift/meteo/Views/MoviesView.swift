import SwiftUI

struct MoviesView: View {
    @StateObject private var viewModel = MoviesViewModel()

    var body: some View {
            VStack {
                

                List(viewModel.movies) { movie in
                    NavigationLink(destination: MovieDetailView(movie: movie)) {
                        VStack(alignment: .leading) {
                            AsyncImage(url: URL(string: "https://image.tmdb.org/t/p/w500\(movie.posterPath)")) { image in
                                image.resizable()
                            } placeholder: {
                                Color.gray
                            }
                            .frame(height: 400)

                            Text(movie.title)
                                .font(.headline)
                        }
                    }
                }
                .navigationTitle("Films en salles")
            }
            .onAppear(perform: viewModel.fetchMovies)
        }
    
}
