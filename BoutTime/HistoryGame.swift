//
//  HistoryGame.swift
//  BoutTime
//
//  Created by Rohit Devnani on 10/7/17.
//  Copyright © 2017 Rohit Devnani. All rights reserved.

import Foundation
import GameKit
import AudioToolbox




protocol HistoricalEvent {
    var date: Date { get } // date
    var statement: String { get } // Historical statement
    var url: String { get }
}

protocol HistoricalGame {
    var eventCollection: [HistoricalEvent] { get set } // An array of evnets conforming to HistoricalEvent protocol
    var roundsPlayed: Int { get set }
    var numberOfRounds: Int { get }
    var points: Int { get set }
    var timer: Int { get } // how long is each round the the game type
    init(eventCollection: [HistoricalEvent]) // Should be initialized with an array of historical events as the eventCollection
    func pickRandomEvents(_ amount: Int) -> [HistoricalEvent] // pick (amount) random events and return as [HsitoricalEvents]
    func checkOrder(of array: [HistoricalEvent]) -> Bool
}

struct Event: HistoricalEvent {
    let date: Date
    let statement: String
    let url: String
}


// Error Handling
enum PlistImportError: Error {
    case invalidResource
    case conversionFailure
    case invalidSelection
}

class PlistImporter {
    static func importDictionaries(fromFile name: String, ofType type: String) throws -> [[String: AnyObject]] {
        
        guard let path = Bundle.main.path(forResource: name, ofType: type) else {
            throw PlistImportError.invalidResource
        }
        guard let arrayOfDictionaries = NSArray.init(contentsOfFile: path) as? [[String: AnyObject]] else {
            throw PlistImportError.conversionFailure
        }
        return arrayOfDictionaries
    }
}

class CollectionUnarchiver {
    static func collection(fromArray array: [[String: AnyObject]]) throws -> [HistoricalEvent] {
        
        var collection: [HistoricalEvent] = []
        
        for dictionary in array {
            
            if  let date = dictionary["date"] as? Date,
                let statement = dictionary["statement"] as? String,
                let url = dictionary["url"] as? String {
                
                let event = Event(date: date, statement: statement, url: url)
                collection.append(event)
            } else {
                print("failed")
            }
        }
        return collection
    }
}

class GameTopic: HistoricalGame {
    var eventCollection: [HistoricalEvent]
    var points: Int = 0
    var roundsPlayed: Int = 0
    let numberOfRounds: Int = 6
    var timer: Int = 60
    
    
    required init(eventCollection: [HistoricalEvent]) {
        self.eventCollection = eventCollection
    }
    
    func pickRandomEvents(_ amount: Int) -> [HistoricalEvent] {
        
        var eventsPicked: [HistoricalEvent] = []
        var randomNumbersUsed: [Int] = []
        
        while eventsPicked.count < amount {
            
            let randomNumber = GKRandomSource.sharedRandom().nextInt(upperBound: eventCollection.count)
            
            if randomNumbersUsed.contains(randomNumber) == false {
                
                eventsPicked.append(eventCollection[randomNumber])
                randomNumbersUsed.append(randomNumber)
            }
        }
        return eventsPicked
    }
    
    func checkOrder(of array: [HistoricalEvent]) -> Bool {
        if  array[0].date > array[1].date,
            array[1].date > array[2].date,
            array[2].date > array[3].date {
            points += 1
            return true
        } else {
            return false
        }
    }
}









