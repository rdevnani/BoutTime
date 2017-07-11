//
//  ViewController.swift
//  BoutTime
//
//  Created by Rohit Devnani on 10/7/17.
//  Copyright © 2017 Rohit Devnani. All rights reserved.
//

import UIKit
import AVFoundation
import GameKit
import AudioToolbox

class ViewController: UIViewController, GameFinishedDelegate {
    
    // MARK: OUTLETS
    
    @IBOutlet weak var firstEventDown: UIButton!
    @IBOutlet weak var secondEventUp: UIButton!
    @IBOutlet weak var secondEventDown: UIButton!
    @IBOutlet weak var thirdEventUp: UIButton!
    @IBOutlet weak var thirdEventDown: UIButton!
    @IBOutlet weak var fourthEventUp: UIButton!
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var upperMiddleLabel: UILabel!
    @IBOutlet weak var underMiddleLabel: UILabel!
    @IBOutlet weak var bottomLabel: UILabel!
    @IBOutlet weak var shakeTextLabel: UILabel!
    @IBOutlet weak var failButton: UIButton!
    @IBOutlet weak var successButton: UIButton!
    @IBOutlet weak var countdown: UILabel!
    @IBOutlet weak var topEventButton: UIButton!
    @IBOutlet weak var secondEventButton: UIButton!
    @IBOutlet weak var thirdEventButton: UIButton!
    @IBOutlet weak var fourthEventButton: UIButton!
        

    
    @IBAction func forceNextRound(_ sender: UIButton!) {
        if sender == successButton || sender == failButton {
            newRound()
        }
    }
    
    @IBAction func moveLowerMiddleUp(_ sender: Any) {
        moveUpperMiddleDown(Any.self)
    }
    @IBAction func moveUpperMiddleDown(_ sender: Any) {
        
        let tempEventTwo    = events[1]
        let tempEventThree  = events[2]
        
        events[1] = tempEventThree
        events[2] = tempEventTwo
        
        updateLabels()
        

    }
    @IBAction func moveUpperMiddleUp(_ sender: Any) {
        moveTopDown(Any.self)
    }
    @IBAction func moveTopDown(_ sender: Any) {
        let tempEventOne = events[0]
        let tempEventTwo = events[1]
        events[0] = tempEventTwo
        events[1] = tempEventOne
        updateLabels()
    }
    @IBAction func moveLowerMiddleDown(_ sender: Any) {
        moveBottomEventUp(Any.self)
    }
    @IBAction func moveBottomEventUp(_ sender: Any) {
        let tempEventThree = events[2]
        let tempEventFour = events[3]
        events[2] = tempEventFour
        events[3] = tempEventThree
        updateLabels()
    }
    
    func playAgainButtonPressed(_ playAgain: Bool) {
        game.points = 0
        game.roundsPlayed = 0
        newRound()
    }
    
    
    let game: GameTopic
    
    required init?(coder aDecoder: NSCoder) {
        do {
            // Importing PList
            let arrayOfDictionaries = try PlistImporter.importDictionaries(fromFile: "EventCollection", ofType: "plist")
            let collection = try CollectionUnarchiver.collection(fromArray: arrayOfDictionaries)
            self.game = GameTopic(eventCollection: collection)
            
        } catch let error {
            
            fatalError("\(error)")
        }
        super.init(coder: aDecoder)
    }
    
    func updateLabels() {
        topLabel.text = events[0].statement
        upperMiddleLabel.text = events[1].statement
        underMiddleLabel.text = events[2].statement
        bottomLabel.text = events[3].statement
        
    }
    
    var events: [HistoricalEvent] = []
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "GameFinishedSegue" {
            if let destination = segue.destination as? GameFinishedViewController {
                if let score = sender as? Int {
                    
                    destination.score = score
                    
                    destination.delegate = self
                }
                
            }
        }
        
    }
    
    func newRound() {
        
        guard game.roundsPlayed != game.numberOfRounds else {
            
            timer?.invalidate()
            performSegue(withIdentifier: "GameFinishedSegue", sender: game.points)
            return
        }
        
        events = game.pickRandomEvents(4)
        countdown.text = "1:00"
        updateLabels()
        
        game.timer = 60
        game.roundsPlayed += 1
        
        failButton.isHidden = true
        successButton.isHidden = true
        countdown.isHidden = false
        
        shakeTextLabel.text = "Shake to Complete"
        
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: Selector(("tick")), userInfo: nil, repeats: true)
    }
    
    func endOfRound(answer: Bool) {
        
        switch answer {
        case true :
            successButton.isHidden = false
            failButton.isHidden = true
        case false :
            successButton.isHidden = true
            failButton.isHidden = false
            break
        }
        
        countdown.isHidden = true
        timer?.invalidate() // stop timer
        
    }
    
    // Shake Method
    override func motionBegan(_ motion: UIEventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            
            endOfRound(answer:
                game.checkOrder(of: events)
            )
            
        }
    }
    
    var timer: Timer?
    
    func tick() {
        game.timer -= 1
        
        if game.timer >= 10 {
            countdown.text = "0:\(game.timer)"
            
        } else if game.timer < 10 {
            countdown.text = "0:0\(game.timer)"
        }
        
        if game.timer <= 0 {
            endOfRound(answer:
                game.checkOrder(of: events)
            )
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        successButton.isHidden = true
        failButton.isHidden = true
        
        newRound()
     
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}





























