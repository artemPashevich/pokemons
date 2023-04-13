//
//  DetailsViewController.swift
//  Pokemon
//
//  Created by Артем Пашевич on 17.03.23.
//

import UIKit

protocol DetailsViewProtocol: AnyObject {
    func showLoading()
    func hideLoading()
    func configureUI(with pokemon: PokemonDetails)
    func showError(_ message: String)
}

final class DetailsViewController: UIViewController {

    @IBOutlet weak var weightLabel: UILabel!
    @IBOutlet weak var pokemonImageView: UIImageView!
    @IBOutlet weak var typesLabel: UILabel!
    @IBOutlet weak var heightLabel: UILabel!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    var id: Int!
    
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
    
    func configureUI(with pokemon: PokemonDetails) {
        weightLabel.text = pokemon.weight
        typesLabel.text = pokemon.types
        heightLabel.text = pokemon.height

        Manager.shared.loadImageFromURL(url: pokemon.imageUrl) { [weak self] image in
            DispatchQueue.main.async {
                self?.pokemonImageView.image = image
            }
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
        Manager.shared.getDetailsInfo(id: id) { [weak self] json, error in
        guard let self = self else { return }
        self.hideLoading()
        if let json = json {
            self.configureUI(with: PokemonDetails(json: json))
        } else if let error = error {
            self.showError(error.description)
        }
    }
    }
}
    



