import SwiftUI

struct PokedexHomeView: View {
    @StateObject private var viewModel = PokedexViewModel()

    var body: some View {
            VStack {
                Picker("Génération", selection: $viewModel.selectedGen) {
                    ForEach(viewModel.gens, id: \.self) { gen in
                        Text("Gen \(gen)").tag(gen)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()

                List(viewModel.filteredList) { pokemon in
                    NavigationLink(destination: PokemonDetailView(pokemon: pokemon)) {
                        HStack {
                            AsyncImage(url: pokemon.sprites.front_default) { phase in
                                if let img = phase.image {
                                    img.resizable().aspectRatio(contentMode: .fit).frame(width: 50, height: 50)
                                } else {
                                    Color.gray.frame(width: 50, height: 50)
                                }
                            }
                            VStack(alignment: .leading) {
                                Text(pokemon.frenchName.isEmpty ? pokemon.name.capitalized : pokemon.frenchName)
                                    .font(.headline)
                                HStack {
                                    ForEach(pokemon.types, id: \.slot) { t in
                                        Text(typeFR[t.type.name] ?? t.type.name.capitalized)
                                            .font(.subheadline)
                                            .padding(4)
                                            .background(Color.gray.opacity(0.2))
                                            .cornerRadius(6)
                                    }
                                }
                            }
                        }
                    }
                }
                .listStyle(PlainListStyle())
                .overlay {
                    if viewModel.isLoading {
                        ProgressView("Chargement…")
                    }
                }
                .searchable(text: $viewModel.searchText, prompt: "Rechercher un Pokémon")
                .onChange(of: viewModel.selectedGen) { _ in
                    viewModel.fetchGeneration(viewModel.selectedGen)
                }
                .onAppear {
                    viewModel.fetchGeneration(viewModel.selectedGen)
                }
            }
            .navigationTitle("Pokédex")
        }
    
}
