
import SwiftUI

struct SearchMovieView: View {
    @State private var searchText = ""
    @State private var searchResults: [Movie] = []

    var body: some View {
        VStack {
            TextField("Rechercher un film", text: $searchText, onCommit: {
                searchMovies()
            })
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .padding()

            List(searchResults) { movie in
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
        }
        .navigationTitle("Rechercher des films")
    }

    func searchMovies() {
        let apiKey = "0302bab21d55da9e8b034faed6f15aed"
        let accessToken = "eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiIwMzAyYmFiMjFkNTVkYTllOGIwMzRmYWVkNmYxNWFlZCIsIm5iZiI6MTc0NzQwMjQ1Mi41MjEsInN1YiI6IjY4MjczZWQ0MmQzOTQwZWJhNTVhNDBhZCIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.psdQ3ZIKCffXBtls4IxfXcNg4bGIc_7kV9f21I2R3KU"
        let query = searchText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "https://api.themoviedb.org/3/search/movie?api_key=\(apiKey)&query=\(query)&language=fr-FR"

        guard let url = URL(string: urlString) else {
            print("URL invalide")
            return
        }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Erreur lors de la requête : \(error)")
                return
            }

            guard let data = data else {
                print("Aucune donnée reçue")
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let results = json["results"] as? [[String: Any]] {
                    DispatchQueue.main.async {
                        self.searchResults = results.compactMap { movieDict in
                            guard let title = movieDict["title"] as? String,
                                  let overview = movieDict["overview"] as? String,
                                  let posterPath = movieDict["poster_path"] as? String,
                                  let voteAverage = movieDict["vote_average"] as? Double,
                                  let releaseDate = movieDict["release_date"] as? String else { return nil }
                            return Movie(title: title, overview: overview, posterPath: posterPath, voteAverage: voteAverage, releaseDate: releaseDate)
                        }
                    }
                }
            } catch let parseError {
                print("Erreur lors de la désérialisation JSON : \(parseError)")
            }
        }

        task.resume()
    }
}

struct SearchMovieView_Previews: PreviewProvider {
    static var previews: some View {
        SearchMovieView()
    }
}
