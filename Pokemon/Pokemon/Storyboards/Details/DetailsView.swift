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

final class DetailsView: UIViewController {

    @IBOutlet weak var weightLabel: UILabel!
    @IBOutlet weak var pokemonImageView: UIImageView!
    @IBOutlet weak var typesLabel: UILabel!
    @IBOutlet weak var heightLabel: UILabel!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    var id: Int = 0
    private var viewModel: DetailsViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
}

extension DetailsView: DetailsViewProtocol {
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
        viewModel.loadImage { [weak self] image in
            self?.pokemonImageView.image = image
        }
    }
    
    func showError(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

extension DetailsView {
    private func setup() {
        showLoading()
        viewModel = DetailsViewModel(dataFetcherManager: DataFetcherManager())
        viewModel.fetchPokemonDetails(id: id) { [weak self] error in
            self?.hideLoading()
            if let error = error {
                self?.showError(error)
            } else if let cachedPokemonDetails = self?.viewModel.getCachedPokemonDetails() {
                self?.configureUI(with: cachedPokemonDetails)
            }
        }
    }
}
    



