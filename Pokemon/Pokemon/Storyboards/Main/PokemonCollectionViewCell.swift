//
//  PokemonCollectionViewCell.swift
//  Pokemon
//
//  Created by Артем Пашевич on 17.03.23.
//

import UIKit

class PokemonCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var pokemonNameLabel: UILabel!
    @IBOutlet weak var pokemonNumberLabel: UILabel!
    
    func config(_ name: String, _ number: String) {
        pokemonNameLabel.text = name
        pokemonNumberLabel.text = number
    }
    
}
