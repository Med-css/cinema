import Foundation

class PokedexViewModel: ObservableObject {
    @Published var pokemonList: [Pokemon] = []
    @Published var searchText: String = ""
    @Published var isLoading = false
    @Published var selectedGen = 1

    let gens = [1, 2, 3, 4, 5]

    var filteredList: [Pokemon] {
        if searchText.isEmpty {
            return pokemonList
        }
        return pokemonList.filter {
            $0.frenchName.lowercased().contains(searchText.lowercased()) ||
            $0.name.lowercased().contains(searchText.lowercased())
        }
    }

    func fetchGeneration(_ gen: Int) {
        isLoading = true
        pokemonList = []
        let url = URL(string: "https://pokeapi.co/api/v2/generation/\(gen)/")!

        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data,
                  let genResp = try? JSONDecoder().decode(GenerationResponse.self, from: data) else {
                DispatchQueue.main.async {
                    self.isLoading = false
                }
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
