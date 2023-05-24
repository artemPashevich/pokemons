//
//  ViewController.swift
//  Pokemon
//
//  Created by Артем Пашевич on 15.03.23.
//

import UIKit
import RealmSwift

protocol PokemonsViewProtocol: AnyObject {
    func showLoading()
    func hideLoading()
    func showError(_ message: String)
    func reloadData()
}

final class PokemonsView: UIViewController {

    @IBOutlet var collectionPokemon: UICollectionView!
    let loadingIndicator = UIActivityIndicatorView(style: .large)
    
    private var viewModel: PokemonsViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLoadingIndicator()
        setup()
    }
    
    private func setup() {
        showLoading()
        viewModel = PokemonsViewModel(dataFetcherManager: DataFetcherManager())
        viewModel.fetchPokemons { [weak self] error in
            self?.hideLoading()
            if let error = error {
                self?.showError(error)
            } else {
                self?.reloadData()
            }
        }
    }

    private func setupLoadingIndicator() {
        view.addSubview(loadingIndicator)
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
}

extension PokemonsView: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.numberOfPokemons
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.pokemonCell.value, for: indexPath) as? PokemonsViewCell else {
            return UICollectionViewCell()
        }
        if let pokemonName = viewModel.getPokemonName(at: indexPath.row) {
            cell.config(pokemonName, (indexPath.row + 1).description)
        }
        return cell
    }
}

extension PokemonsView: PokemonsViewProtocol {
    func reloadData() {
        collectionPokemon.reloadData()
    }
    
    func showLoading() {
        loadingIndicator.startAnimating()
        view.isUserInteractionEnabled = false
    }
    
    func hideLoading() {
        loadingIndicator.stopAnimating()
        view.isUserInteractionEnabled = true
    }
    
    func showError(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

extension PokemonsView {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let indexPaths = collectionPokemon.indexPathsForSelectedItems, let indexPath = indexPaths.first {
            if segue.identifier == Constants.segue.value {
                if let destinationVC = segue.destination as? DetailsView {
                    destinationVC.id = indexPath.row + 1
                    destinationVC.title = viewModel.getPokemonName(at: indexPath.row)
                }
            }
        }
    }
}

private extension PokemonsView {
    enum Constants {
        case pokemonCell
        case segue

        var value: String {
            switch self {
            case .pokemonCell:
                return "PokemonCollectionViewCell"
            case .segue:
                return "showDetailsSegue"
            }
        }
    }
}
