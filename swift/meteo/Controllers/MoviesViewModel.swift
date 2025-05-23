import Foundation

class MoviesViewModel: ObservableObject {
    @Published var movies: [Movie] = []

    func fetchMovies() {
        let apiKey = "0302bab21d55da9e8b034faed6f15aed"
        let accessToken = "eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiIwMzAyYmFiMjFkNTVkYTllOGIwMzRmYWVkNmYxNWFlZCIsIm5iZiI6MTc0NzQwMjQ1Mi41MjEsInN1YiI6IjY4MjczZWQ0MmQzOTQwZWJhNTVhNDBhZCIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.psdQ3ZIKCffXBtls4IxfXcNg4bGIc_7kV9f21I2R3KU"
        let urlString = "https://api.themoviedb.org/3/movie/now_playing?api_key=\(apiKey)&language=fr-FR"

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
                        self.movies = results.compactMap { movieDict in
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
