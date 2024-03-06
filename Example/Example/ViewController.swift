//
//  ViewController.swift
//  Example
//
//  Created by 陳翰霖 on 2024/3/6.
//

import UIKit

class ViewController: UITableViewController {
	var results = [PokemonResult]()

	override func viewDidLoad() {
		super.viewDidLoad()
		tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ExampleCell")
		let url = GetPokemonRequest().url!
		Task {
			let (data, _) = try await URLSession.shared.data(from: url)
			let decoded = try JSONDecoder().decode(PokemonResponse.self, from: data)
			results = decoded.results
			DispatchQueue.main.async {
				self.tableView.reloadData()
			}
		}
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		results.count
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "ExampleCell", for: indexPath)
		cell.textLabel?.text = results[indexPath.row].name
		cell.accessibilityIdentifier = "ExampleCell-\(results[indexPath.row].name)"
		return cell
	}
}

struct PokemonResponse: Codable, Equatable {
	var count: Int
	var next: String?
	var results: Array<PokemonResult>
}

struct PokemonResult: Codable, Equatable {
	var name: String
	var url: String
}

final class Constants {
	static let POKEMON_SERVER_HOST = "pokeapi.co"
}

protocol HttpRequest {
	var host: String { get }
	var path: String { get }
	var method: HttpMethod { get }
	var queryItems: [String:String]? { get }
}

extension HttpRequest {
	var queryItems: [String:String]? { nil }

	var urlComponents: URLComponents {
		var urlComponents = URLComponents()
		urlComponents.scheme = "https"
		urlComponents.host = host
		urlComponents.path = path

		var requestQueryItems = [URLQueryItem]()

		queryItems?.forEach { item in
			requestQueryItems.append(URLQueryItem(name: item.key, value: item.value))
		}

		urlComponents.queryItems = requestQueryItems
		return urlComponents
	}

	var url: URL? {
		urlComponents.url
	}
}


enum HttpMethod: Equatable {
	case GET
	case POST(data: Data?)
}

struct GetPokemonRequest: HttpRequest {
	var offset: Int
	var limit: Int

	init(offset: Int = 0, limit: Int = 20) {
		self.offset = offset
		self.limit = limit
	}

	var host: String { Constants.POKEMON_SERVER_HOST }
	var path: String { "/api/v2/pokemon" }
	var method: HttpMethod { .GET }
	var queryItems: [String : String]? {
		[
			"offset": "\(offset)",
			"limit": "\(limit)"
		]
	}
}