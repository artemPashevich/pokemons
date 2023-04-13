//
//  ViewController.swift
//  Pokemon
//
//  Created by Артем Пашевич on 15.03.23.
//

import UIKit

protocol PokemonsViewProtocol: AnyObject {
    func showLoading()
    func hideLoading()
    func showError(_ message: String)
}

protocol PokemonsfetchProtocol: AnyObject {
    func fetchPokemons()
}


final class PokemonsViewController: UIViewController, PokemonsfetchProtocol {

    @IBOutlet var collectionPokemon: UICollectionView!
    let loadingIndicator = UIActivityIndicatorView(style: .large)
    
    var pokemonsGroups: [Pokemon]?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupLoadingIndicator()
        fetchPokemons()
    }
    
    func fetchPokemons() {
        showLoading()
        Manager.shared.getListName { [weak self] pokemons, error in
            guard let self = self else {
                return
            }
            self.hideLoading()
            if let error = error {
                self.showError(error.description)
            } else {
                self.pokemonsGroups = pokemons
                self.collectionPokemon.reloadData()
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

extension PokemonsViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        pokemonsGroups?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.pokemonCell.value, for: indexPath) as? PokemonCollectionViewCell else {
            return UICollectionViewCell()
        }
        if let pokemonName = pokemonsGroups?[indexPath.row].name {
            cell.config(pokemonName, (indexPath.row + 1).description)
        }
        return cell
    }
}

extension PokemonsViewController: PokemonsViewProtocol {
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

extension PokemonsViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let indexPaths = collectionPokemon.indexPathsForSelectedItems, let indexPath = indexPaths.first {
            if segue.identifier == Constants.segue.value {
                if let destinationVC = segue.destination as? DetailsViewController {
                    destinationVC.id = indexPath.row + 1
                    destinationVC.title = pokemonsGroups?[indexPath.row].name
                }
            }
        }
    }
}

private extension PokemonsViewController {
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
