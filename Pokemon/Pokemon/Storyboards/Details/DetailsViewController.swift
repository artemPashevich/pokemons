//
//  DetailsViewController.swift
//  Pokemon
//
//  Created by Артем Пашевич on 17.03.23.
//

import UIKit
import RealmSwift

protocol DetailsViewProtocol: AnyObject {
    func showLoading()
    func hideLoading()
    func configureUI(with pokemon: CachedPokemonDetails)
    func showError(_ message: String)
}

final class DetailsViewController: UIViewController {

    @IBOutlet weak var weightLabel: UILabel!
    @IBOutlet weak var pokemonImageView: UIImageView!
    @IBOutlet weak var typesLabel: UILabel!
    @IBOutlet weak var heightLabel: UILabel!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    var id: Int = 0
    let dataFetcherManager = DataFetcherManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
}

extension DetailsViewController: DetailsViewProtocol {
    func showLoading() {
        loadingIndicator.startAnimating()
        view.isUserInteractionEnabled = false
    }
    
    func hideLoading() {
        loadingIndicator.stopAnimating()
        view.isUserInteractionEnabled = true
    }
    
    func configureUI(with pokemon: CachedPokemonDetails) {
        weightLabel.text = pokemon.weight
        typesLabel.text = pokemon.types
        heightLabel.text = pokemon.height
        print(pokemon.height)
        print(pokemon.imageUrlString)
        dataFetcherManager.loadImageFromURL(urlString: pokemon.imageUrlString) { [weak self] image, error  in
            self?.pokemonImageView.image = image
        }
    }
    
    func showError(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

extension DetailsViewController {
    private func setup() {
        showLoading()
        dataFetcherManager.getPokemonDetails(id: id) { [weak self] json, error, track  in
            self?.hideLoading()
            if let json = json, let track = track {
                self?.configureUI(with: CachedPokemonDetails(json: json, online: track))
            } else if let error = error {
                self?.showError(error.description)
            }
        }
    }
}
    



