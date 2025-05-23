import SwiftUI

struct PokemonDetailView: View {
    let pokemon: Pokemon

    var body: some View {
        ScrollView {
            VStack(alignment: .center, spacing: 16) {
                AsyncImage(url: pokemon.sprites.front_default) { phase in
                    if let img = phase.image {
                        img.resizable().aspectRatio(contentMode: .fit).frame(width: 150, height: 150)
                    } else {
                        Color.gray.frame(width: 150, height: 150)
                    }
                }
                Text(pokemon.frenchName.isEmpty ? pokemon.name.capitalized : pokemon.frenchName)
                    .font(.largeTitle).bold()

                HStack {
                    ForEach(pokemon.types, id: \.slot) { t in
                        Text(typeFR[t.type.name] ?? t.type.name.capitalized)
                            .padding(6)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(8)
                    }
                }
                .padding(.bottom)

                HStack(spacing: 20) {
                    VStack {
                        Text("Taille").bold()
                        Text("\(Double(pokemon.height)/10, specifier: "%.1f") m")
                    }
                    VStack {
                        Text("Poids").bold()
                        Text("\(Double(pokemon.weight)/10, specifier: "%.1f") kg")
                    }
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
