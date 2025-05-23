import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                
                NavigationLink(destination: MoviesView()) {
                    Text("Voir les films")
                        .font(.title)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                NavigationLink(destination: PokedexHomeView()) {
                    Text("Voir les pokémons")
                        .font(.title)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
            }
            .navigationTitle("Accueil")
        }
    }
}

// MARK: - Modèles de données
struct Pokemon: Identifiable, Codable {
    let id: Int
    let name: String
    var frenchName: String = ""
    let sprites: Sprites
    let types: [TypeElement]
    let weight: Int
    let height: Int
    let abilities: [Ability]
    let stats: [Stat]

    struct Sprites: Codable { let front_default: URL? }
    struct TypeElement: Codable { let slot: Int; let type: NamedAPIResource }
    struct Ability: Codable { let is_hidden: Bool; let ability: NamedAPIResource }
    struct Stat: Codable { let base_stat: Int; let stat: NamedAPIResource }
    struct NamedAPIResource: Codable { let name: String; let url: URL }

    enum CodingKeys: String, CodingKey {
        case id, name, sprites, types, weight, height, abilities, stats
    }
}

struct PokemonSpecies: Codable {
    struct Name: Codable { let name: String; let language: Pokemon.NamedAPIResource }
    let names: [Name]
}

struct GenerationResponse: Codable {
    struct Species: Codable { let name: String; let url: URL }
    let pokemon_species: [Species]
}

// Traductions
let typeFR: [String: String] = ["normal":"Normal","fire":"Feu","water":"Eau","electric":"Électrik","grass":"Plante","ice":"Glace","fighting":"Combat","poison":"Poison","ground":"Sol","flying":"Vol","psychic":"Psy","bug":"Insecte","rock":"Roche","ghost":"Spectre","dragon":"Dragon","dark":"Ténèbres","steel":"Acier","fairy":"Fée"]
let statFR: [String:String] = ["hp":"PV","attack":"Attaque","defense":"Défense","special-attack":"Attaque Spéciale","special-defense":"Défense Spéciale","speed":"Vitesse"]

// MARK: - Vue d'accueil
struct PokedexHomeView: View {
    @State private var pokemonList: [Pokemon] = []
    @State private var searchText: String = ""
    @State private var isLoading = false
    @State private var selectedGen = 1

    let gens = [1,2,3,4,5]

    var filteredList: [Pokemon] {
        if searchText.isEmpty { return pokemonList }
        return pokemonList.filter {
            $0.frenchName.lowercased().contains(searchText.lowercased()) ||
            $0.name.lowercased().contains(searchText.lowercased())
        }
    }

    var body: some View {
        VStack {
            Picker("Génération", selection: $selectedGen) {
                ForEach(gens, id: \.self) { gen in Text("Gen \(gen)").tag(gen) }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()

            List(filteredList) { pokemon in
                NavigationLink(destination: PokemonDetailView(pokemon: pokemon)) {
                    HStack {
                        AsyncImage(url: pokemon.sprites.front_default) { phase in
                            if let img = phase.image {
                                img.resizable().aspectRatio(contentMode: .fit).frame(width:50,height:50)
                            } else { Color.gray.frame(width:50,height:50) }
                        }
                        VStack(alignment: .leading) {
                            Text(pokemon.frenchName.isEmpty ? pokemon.name.capitalized : pokemon.frenchName)
                                .font(.headline)
                            HStack {
                                ForEach(pokemon.types, id: \.slot) { t in
                                    Text(typeFR[t.type.name] ?? t.type.name.capitalized)
                                        .font(.subheadline).padding(4)
                                        .background(Color.gray.opacity(0.2)).cornerRadius(6)
                                }
                            }
                        }
                    }
                }
            }
            .listStyle(PlainListStyle())
            .overlay { if isLoading { ProgressView("Chargement…") } }
            .searchable(text: $searchText, prompt: "Rechercher un Pokémon sur cette page")
            .onChange(of: selectedGen) { _ in fetchGeneration(selectedGen) }
            .onAppear { fetchGeneration(selectedGen) }
        }
        .navigationTitle("Pokédex")
    }

    private func fetchGeneration(_ gen: Int) {
        isLoading = true
        pokemonList = []
        let url = URL(string: "https://pokeapi.co/api/v2/generation/\(gen)/")!

        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data,
                  let genResp = try? JSONDecoder().decode(GenerationResponse.self, from: data) else {
                DispatchQueue.main.async { isLoading = false }
                return
            }

            let speciesNames = genResp.pokemon_species.map { $0.name }
            let group = DispatchGroup()
            var temp: [Pokemon] = []

            for name in speciesNames {
                group.enter()
                let pokeURL = URL(string: "https://pokeapi.co/api/v2/pokemon/\(name)/")!
                URLSession.shared.dataTask(with: pokeURL) { pd, _, _ in
                    guard let pd = pd,
                          var p = try? JSONDecoder().decode(Pokemon.self, from: pd) else {
                        group.leave()
                        return
                    }
                    // Récupère le nom français et attend
                    let spURL = URL(string: "https://pokeapi.co/api/v2/pokemon-species/\(p.id)/")!
                    URLSession.shared.dataTask(with: spURL) { sd, _, _ in
                        if let sd = sd,
                           let sp = try? JSONDecoder().decode(PokemonSpecies.self, from: sd),
                           let fr = sp.names.first(where: { $0.language.name == "fr" }) {
                            p.frenchName = fr.name.capitalized
                        }
                        temp.append(p)
                        group.leave()
                    }.resume()
                }.resume()
            }

            group.notify(queue: .main) {
                self.pokemonList = temp.sorted { $0.id < $1.id }
                self.isLoading = false
            }
        }.resume()
    }
}

// MARK: - Vue détail
struct PokemonDetailView: View {
    let pokemon: Pokemon
    var body: some View {
        ScrollView {
            VStack(alignment: .center, spacing: 16) {
                AsyncImage(url: pokemon.sprites.front_default) { phase in
                    if let img = phase.image {
                        img.resizable().aspectRatio(contentMode: .fit).frame(width:150,height:150)
                    } else { Color.gray.frame(width:150,height:150) }
                }
                Text(pokemon.frenchName.isEmpty ? pokemon.name.capitalized : pokemon.frenchName)
                    .font(.largeTitle).bold()

                HStack { ForEach(pokemon.types, id: \.slot) { t in
                    Text(typeFR[t.type.name] ?? t.type.name.capitalized)
                        .padding(6).background(Color.gray.opacity(0.2)).cornerRadius(8)
                }}
                .padding(.bottom)

                HStack(spacing: 20) {
                    VStack { Text("Taille").bold(); Text("\(Double(pokemon.height)/10, specifier:"%.1f") m") }
                    VStack { Text("Poids").bold(); Text("\(Double(pokemon.weight)/10, specifier:"%.1f") kg") }
                }
                .padding(.bottom)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Aptitudes").font(.headline)
                    ForEach(pokemon.abilities, id: \.ability.name) { a in
                        Text("- \(a.ability.name.capitalized) \(a.is_hidden ? "(cachée)" : "")")
                    }
                }
                .padding(.bottom)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Statistiques").font(.headline)
                    ForEach(pokemon.stats, id: \.stat.name) { s in
                        Text("\(statFR[s.stat.name] ?? s.stat.name.capitalized): \(s.base_stat)")
                    }
                }
            }
            .padding()
        }
        .navigationTitle(pokemon.frenchName.isEmpty ? pokemon.name.capitalized : pokemon.frenchName)
    }
}

struct Movie: Identifiable {
    let id = UUID()
    let title: String
    let overview: String
    let posterPath: String
    let voteAverage: Double
    let releaseDate: String
}

struct MoviesView: View {
    @State private var movies: [Movie] = []

    var body: some View {
        VStack {
            NavigationLink(destination: SearchMovieView()) {
                Text("Rechercher des films")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding()

            List(movies) { movie in
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
        .onAppear(perform: fetchMovies)
    }

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

struct MoviesView_Previews: PreviewProvider {
    static var previews: some View {
        MoviesView()
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
