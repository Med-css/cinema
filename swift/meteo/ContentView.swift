import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                
                NavigationLink(destination: MovieView()) {
                    Text("Voir les films")
                        .font(.title)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                NavigationLink(destination: AnotherView()) {
                    Text("Voir les pokémons")
                        .font(.title)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                Spacer()
            }
            .navigationTitle("Accueil")
        }
    }
}

struct AnotherView: View {
    var body: some View {
        Text("Bienvenue sur l'autre page !")
            .font(.largeTitle)
            .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
