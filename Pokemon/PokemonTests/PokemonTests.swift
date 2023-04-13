//
//  PokemonTests.swift
//  PokemonTests
//
//  Created by Артем Пашевич on 15.03.23.
//

import XCTest
import RealmSwift
@testable import Pokemon

final class PokemonTests: XCTestCase {
    
     var realm: Realm!

     override func setUp() {
         super.setUp()
         realm = try! Realm(configuration: Realm.Configuration(inMemoryIdentifier: "test"))
     }

     override func tearDown() {
         realm = nil
         super.tearDown()
     }

     func testGetListNameWithCachedData() {
         let pokemon1 = Pokemon()
         pokemon1.name = "Pikachu"
         let pokemon2 = Pokemon()
         pokemon2.name = "Charmander"
         try! realm.write {
             realm.add([pokemon1, pokemon2])
         }
         
         let expectation = self.expectation(description: "Completion handler called")
         getListName { (pokemons, error) in
             XCTAssertEqual(pokemons?.count, 2)
             XCTAssertEqual(pokemons?[0].name, "Pikachu")
             XCTAssertEqual(pokemons?[1].name, "Charmander")
             XCTAssertNil(error)
             expectation.fulfill()
         }
         waitForExpectations(timeout: 1, handler: nil)
     }
     
     func testGetListNameWithBackendData() {
         let backendData = """
             {
                 "results": [
                     { "name": "Squirtle" },
                     { "name": "Bulbasaur" }
                 ]
             }
         """.data(using: .utf8)!
         let mockSession = URLSessionMock(data: backendData, response: nil, error: nil)
   
         let expectation = self.expectation(description: "Completion handler called")
         let backendUrl = URL(string: "https://example.com")!
         let api = YourAPI(session: mockSession, realm: realm)
         api.getListName(backendUrl: backendUrl) { (pokemons, error) in
             XCTAssertEqual(pokemons?.count, 2)
             XCTAssertEqual(pokemons?[0].name, "Squirtle")
             XCTAssertEqual(pokemons?[1].name, "Bulbasaur")
             XCTAssertNil(error)
             expectation.fulfill()
         }
         waitForExpectations(timeout: 1, handler: nil)
     }
 }

 class URLSessionMock: URLSession {
     
     var data: Data?
     var response: URLResponse?
     var error: Error?
     
     init(data: Data?, response: URLResponse?, error: Error?) {
         self.data = data
         self.response = response
         self.error = error
     }
     
     override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
         return MockTask(data: data, response: response, error: error, completionHandler: completionHandler)
     }
 }

 class MockTask: URLSessionDataTask {
     
     private let data: Data?
     private let response: URLResponse?
     private let error: Error?
     private let completionHandler: (Data?, URLResponse?, Error?) -> Void
     
     init(data: Data?, response: URLResponse?, error: Error?, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
         self.data = data
         self.response = response
         self.error = error
         self.completionHandler = completionHandler
     }
     
     override func resume() {
         DispatchQueue.main.async {
             self.completionHandler(self.data, self.response, self.error)
         }
     }
 }
