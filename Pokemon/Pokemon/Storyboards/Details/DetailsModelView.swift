//
//  DetailsModelView.swift
//  Pokemon
//
//  Created by Артем Пашевич on 23.05.23.
//

import UIKit

final class DetailsViewModel {
    private let dataFetcherManager: DataFetcherManager
    private var cachedPokemonDetails: CachedPokemonDetails?
    private var loadedImage: UIImage?
    
    init(dataFetcherManager: DataFetcherManager) {
        self.dataFetcherManager = dataFetcherManager
    }
    
    func fetchPokemonDetails(id: Int, completion: @escaping (String?) -> Void) {
        dataFetcherManager.getPokemonDetails(id: id) { [weak self] json, error, track in
            if let json = json, let track = track {
                self?.cachedPokemonDetails = CachedPokemonDetails(json: json, online: track)
                completion(nil)
            } else if let error = error {
                completion(error)
            }
        }
    }
    
    func loadImage(completion: @escaping (UIImage?) -> Void) {
            guard let imageUrlString = cachedPokemonDetails?.imageUrlString else {
                completion(nil)
                return
            }
            
            dataFetcherManager.loadImageFromURL(urlString: imageUrlString) { [weak self] image, error in
                self?.loadedImage = image
                completion(image)
            }
        }
    
    func getCachedPokemonDetails() -> CachedPokemonDetails? {
        return cachedPokemonDetails
    }
}
