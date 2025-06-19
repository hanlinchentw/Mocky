//
//  App.swift
//  Example
//
//  Created by leoc on 2025/6/19.
//

import MockyCore
import SwiftUI

@main
struct ExampleApp: App {
    init() {
#if DEBUG
        if ProcessInfo.isTestAutomation {
            Mocky.start(domains: [Constants.POKEMON_SERVER_HOST])
        }
#endif
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    @State var pokemons: [PokemonResult] = []

    var body: some View {
        List(pokemons) { pokemon in
            Text(pokemon.name)
        }
        .task {
            await fetchPokemons()
        }
    }

    func fetchPokemons() async {
        let api = PokemonAPI()
        if let pokemons = try? await api.fetchPokemons() {
            self.pokemons = pokemons
        }
    }
}
