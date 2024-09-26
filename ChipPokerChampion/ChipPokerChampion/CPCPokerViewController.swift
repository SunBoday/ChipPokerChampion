//
//  CPCPokerViewController.swift
//  ChipPokerChampion
//
//  Created by SunTory on 2024/9/26.
//

import UIKit
import Foundation
import AVFoundation


class CPCPokerViewController: UIViewController {

    // UI Elements for Player 1
    @IBOutlet weak var player1NameLabel: UILabel!
    @IBOutlet weak var player1ChipsLabel: UILabel!
    @IBOutlet weak var player1Card1ImageView: UIImageView!
    @IBOutlet weak var player1Card2ImageView: UIImageView!
    @IBOutlet weak var player1Card3ImageView: UIImageView!

    // UI Elements for Player 2
    @IBOutlet weak var player2NameLabel: UILabel!
    @IBOutlet weak var player2ChipsLabel: UILabel!
    @IBOutlet weak var player2Card1ImageView: UIImageView!
    @IBOutlet weak var player2Card2ImageView: UIImageView!
    @IBOutlet weak var player2Card3ImageView: UIImageView!

    @IBOutlet weak var winnerLabel: UILabel!
    @IBOutlet weak var betAmountTextField: UITextField!

    // Game state
    var pokerGame: PokerShowdown!
    var audioPlayer: AVAudioPlayer?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Initialize players
        let players = [
            Gambler(nickname: "Player 1", balance: 100),
            Gambler(nickname: "Player 2", balance: 100)
        ]

        pokerGame = PokerShowdown(contestants: players)
        updateUI()
    }

    func playCardSound() {
        guard let soundURL = Bundle.main.url(forResource: "cardReveal", withExtension: "mp3") else { return }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
            audioPlayer?.play()
        } catch {
            print("Error playing sound: \(error.localizedDescription)")
        }
    }

    func animateCardReveal(imageView: UIImageView) {
        imageView.alpha = 0.0
        imageView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)

        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       usingSpringWithDamping: 0.5,
                       initialSpringVelocity: 0.5,
                       options: [.curveEaseInOut],
                       animations: {
                           imageView.alpha = 1.0
                           imageView.transform = .identity
                       }, completion: nil)
    }

    func updateUI() {
        let players = pokerGame.contestants

        // Player 1
        player1NameLabel.text = players[0].nickname
        player1ChipsLabel.text = "Chips: \(players[0].balance)"
        if players[0].hand.count == 3 {
            player1Card1ImageView.image = UIImage(named: "\(players[0].hand[0].imageId)")
            player1Card2ImageView.image = UIImage(named: "\(players[0].hand[1].imageId)")
            player1Card3ImageView.image = UIImage(named: "\(players[0].hand[2].imageId)")

            // Animate cards for Player 1
            playCardSound()
            animateCardReveal(imageView: player1Card1ImageView)
            animateCardReveal(imageView: player1Card2ImageView)
            animateCardReveal(imageView: player1Card3ImageView)
        }

        // Player 2
        player2NameLabel.text = players[1].nickname
        player2ChipsLabel.text = "Chips: \(players[1].balance)"
        if players[1].hand.count == 3 {
            player2Card1ImageView.image = UIImage(named: "\(players[1].hand[0].imageId)")
            player2Card2ImageView.image = UIImage(named: "\(players[1].hand[1].imageId)")
            player2Card3ImageView.image = UIImage(named: "\(players[1].hand[2].imageId)")

            // Animate cards for Player 2
            playCardSound()
            animateCardReveal(imageView: player2Card1ImageView)
            animateCardReveal(imageView: player2Card2ImageView)
            animateCardReveal(imageView: player2Card3ImageView)
        }
    }

    @IBAction func placeBetAndPlayRound(_ sender: UIButton) {
        guard let betAmountString = betAmountTextField.text, let betAmount = Int(betAmountString), betAmount > 0 else {
            winnerLabel.text = "Please enter a valid bet amount"
            return
        }

        // Place bets and deal cards
        pokerGame.placeBets(amount: betAmount)
        pokerGame.dealHands()

        // Determine the winner
        let winner = pokerGame.determineWinner()

        // Update UI with the winner's name and award the pot
        winnerLabel.text = "\(winner.nickname) wins the pot of \(pokerGame.bettingPot) chips!"

        // Award the pot to the winner and then update the UI
        pokerGame.awardPot(to: winner)

        // Update the UI to reflect the new state after awarding the pot
        updateUI()
    }
    
    @IBAction func btnBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
}

// Gambler model
class Gambler {
    var nickname: String
    var balance: Int
    var hand: [PlayingCard] = []
    
    init(nickname: String, balance: Int) {
        self.nickname = nickname
        self.balance = balance
    }
}

// PlayingCard model
class PlayingCard {
    var value: CardValue
    var suit: String
    var imageId: Int
    
    init(value: CardValue, suit: String, imageId: Int) {
        self.value = value
        self.suit = suit
        self.imageId = imageId
    }
}

// Enums for card values and poker hand rankings
enum CardValue: Int, Comparable {
    case two = 2, three, four, five, six, seven, eight, nine, ten, jack, queen, king, ace
    
    static func < (lhs: CardValue, rhs: CardValue) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}

enum HandRank: Int {
    case highCard = 1
    case pair
    case threeOfAKind
}

// PokerShowdown model (game logic)
class PokerShowdown {
    var contestants: [Gambler]
    var bettingPot: Int = 0
    
    init(contestants: [Gambler]) {
        self.contestants = contestants
    }

    // Create a deck of cards with image identifiers
    func createDeck() -> [PlayingCard] {
        let suits = ["Hearts", "Diamonds", "Clubs", "Spades"]
        var deck: [PlayingCard] = []
        var imageId = 1
        
        for suit in suits {
            for value in CardValue.two.rawValue...CardValue.ace.rawValue {
                if let cardValue = CardValue(rawValue: value) {
                    deck.append(PlayingCard(value: cardValue, suit: suit, imageId: imageId))
                    imageId += 1
                }
            }
        }
        return deck
    }

    // Deal 3 random cards to each gambler
    func dealHands() {
        var deck = createDeck().shuffled()
        
        for i in 0..<contestants.count {
            contestants[i].hand = Array(deck.prefix(3)) // Deal 3 cards to each gambler
            deck.removeFirst(3)
        }
    }
    
    // Compare hands and determine the winner
    func determineWinner() -> Gambler {
        let contestant1HandRank = evaluateHand(for: contestants[0])
        let contestant2HandRank = evaluateHand(for: contestants[1])
        
        if contestant1HandRank.rawValue > contestant2HandRank.rawValue {
            return contestants[0]
        } else if contestant2HandRank.rawValue > contestant1HandRank.rawValue {
            return contestants[1]
        } else {
            // If hands are equal, compare by highest card
            let contestant1HighCard = contestants[0].hand.max(by: { $0.value < $1.value })!
            let contestant2HighCard = contestants[1].hand.max(by: { $0.value < $1.value })!
            
            return contestant1HighCard.value > contestant2HighCard.value ? contestants[0] : contestants[1]
        }
    }

    func evaluateHand(for gambler: Gambler) -> HandRank {
        let values = gambler.hand.map { $0.value }
        let suits = gambler.hand.map { $0.suit }
        let valueCounts = Dictionary(grouping: values, by: { $0 }).mapValues { $0.count }
        
        let isFlush = suits.allSatisfy { $0 == suits.first }
        let sortedValues = values.sorted()
        let isStraight = (sortedValues[0].rawValue + 1 == sortedValues[1].rawValue &&
                          sortedValues[1].rawValue + 1 == sortedValues[2].rawValue)

        if isFlush && isStraight {
            return .threeOfAKind // Consider creating a new case for "straight flush"
        } else if isFlush {
            return .threeOfAKind // Consider creating a new case for "flush"
        } else if isStraight {
            return .threeOfAKind // Consider creating a new case for "straight"
        } else if valueCounts.values.contains(3) {
            return .threeOfAKind
        } else if valueCounts.values.contains(2) {
            return .pair
        } else {
            return .highCard
        }
    }
    
    // Place bets
    func placeBets(amount: Int) {
        for i in 0..<contestants.count {
            contestants[i].balance -= amount
        }
        bettingPot += amount * contestants.count
    }
    
    // Award the pot to the winner
    func awardPot(to winner: Gambler) {
        winner.balance += bettingPot
        bettingPot = 0 // Reset the pot
    }
}

