import Foundation

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

    struct Sprites: Codable {
        let front_default: URL?
    }

    struct TypeElement: Codable {
        let slot: Int
        let type: NamedAPIResource
    }

    struct Ability: Codable {
        let is_hidden: Bool
        let ability: NamedAPIResource
    }

    struct Stat: Codable {
        let base_stat: Int
        let stat: NamedAPIResource
    }

    struct NamedAPIResource: Codable {
        let name: String
        let url: URL
    }

    enum CodingKeys: String, CodingKey {
        case id, name, sprites, types, weight, height, abilities, stats
    }
}

struct PokemonSpecies: Codable {
    struct Name: Codable {
        let name: String
        let language: Pokemon.NamedAPIResource
    }
    let names: [Name]
}

struct GenerationResponse: Codable {
    struct Species: Codable {
        let name: String
        let url: URL
    }
    let pokemon_species: [Species]
}

// Traductions
let typeFR: [String: String] = [
    "normal": "Normal",
    "fire": "Feu",
    "water": "Eau",
    "electric": "Électrik",
    "grass": "Plante",
    "ice": "Glace",
    "fighting": "Combat",
    "poison": "Poison",
    "ground": "Sol",
    "flying": "Vol",
    "psychic": "Psy",
    "bug": "Insecte",
    "rock": "Roche",
    "ghost": "Spectre",
    "dragon": "Dragon",
    "dark": "Ténèbres",
    "steel": "Acier",
    "fairy": "Fée"
]

let statFR: [String: String] = [
    "hp": "PV",
    "attack": "Attaque",
    "defense": "Défense",
    "special-attack": "Attaque Spéciale",
    "special-defense": "Défense Spéciale",
    "speed": "Vitesse"
]
