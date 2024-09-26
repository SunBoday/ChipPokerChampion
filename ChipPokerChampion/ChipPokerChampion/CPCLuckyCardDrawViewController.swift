//
//  CPCLuckyCardDrawViewController.swift
//  ChipPokerChampion
//
//  Created by SunTory on 2024/9/26.
//

import UIKit

// Enums, structs, and classes remain the same
enum CardRank: Int, Comparable {
    case two = 2, three, four, five, six, seven, eight, nine, ten
    case jack = 11, queen, king, ace

    static func < (lhs: CardRank, rhs: CardRank) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}

class Card {
    let rank: CardRank
    let suit: String

    init(rank: CardRank, suit: String) {
        self.rank = rank
        self.suit = suit
    }
}

class Player {
    let name: String
    var chips: Int
    var card: Card?

    init(name: String, chips: Int) {
        self.name = name
        self.chips = chips
        self.card = nil // Initialize as nil
    }

    func placeBet(amount: Int) -> Bool {
        if chips >= amount {
            chips -= amount
            return true
        } else {
            return false
        }
    }
}

class LuckyCardDrawGame {
    var players: [Player]
    var pot: Int = 0

    init(players: [Player]) {
        self.players = players
    }

    func createDeck() -> [Card] {
        let suits = ["Hearts", "Diamonds", "Clubs", "Spades"]
        var deck: [Card] = []

        for suit in suits {
            for rank in CardRank.two.rawValue...CardRank.ace.rawValue {
                if let cardRank = CardRank(rawValue: rank) {
                    deck.append(Card(rank: cardRank, suit: suit))
                }
            }
        }
        return deck
    }

    func dealCards() {
        var deck = createDeck().shuffled()

        for i in 0..<players.count {
            if !deck.isEmpty {
                players[i].card = deck.removeFirst()
            }
        }
    }

    func placeBets(betAmount: Int) {
        for player in players {
            if player.placeBet(amount: betAmount) {
                pot += betAmount
            }
        }
    }

    func determineWinner() -> Player? {
        return players.max { (lhs, rhs) in
            guard let leftCard = lhs.card, let rightCard = rhs.card else {
                return false // If either card is nil, it can't be compared
            }
            return leftCard.rank < rightCard.rank
        }
    }
}

class CPCLuckyCardDrawViewController: UIViewController {
    
    // IBOutlets for UI elements
    @IBOutlet weak var player1NameLabel: UILabel!
    @IBOutlet weak var player1ChipsLabel: UILabel!
    @IBOutlet weak var player1CardImageView: UIImageView!
    
    @IBOutlet weak var player2NameLabel: UILabel!
    @IBOutlet weak var player2ChipsLabel: UILabel!
    @IBOutlet weak var player2CardImageView: UIImageView!
    
    @IBOutlet weak var player3NameLabel: UILabel!
    @IBOutlet weak var player3ChipsLabel: UILabel!
    @IBOutlet weak var player3CardImageView: UIImageView!
    
    @IBOutlet weak var winnerLabel: UILabel!
    
    @IBOutlet weak var betAmountTextField: UITextField!
    
    // Game state
    var luckyCardDrawGame: LuckyCardDrawGame!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize players
        let players = [
            Player(name: "Player 1", chips: 100),
            Player(name: "Player 2", chips: 100),
            Player(name: "Player 3", chips: 100)
        ]
        
        luckyCardDrawGame = LuckyCardDrawGame(players: players)
        updateUI()
    }
    
    func updateUI() {
        // Update player names, chips, and pot
        let players = luckyCardDrawGame.players
        player1NameLabel.text = players[0].name
        player1ChipsLabel.text = "Chips: \(players[0].chips)"
        player1CardImageView.image = cardImage(for: players[0].card)
        
        player2NameLabel.text = players[1].name
        player2ChipsLabel.text = "Chips: \(players[1].chips)"
        player2CardImageView.image = cardImage(for: players[1].card)
        
        player3NameLabel.text = players[2].name
        player3ChipsLabel.text = "Chips: \(players[2].chips)"
        player3CardImageView.image = cardImage(for: players[2].card)
        
       // potLabel.text = "Pot: \(luckyCardDrawGame.pot) Chips"

    }
    
    func cardImage(for card: Card?) -> UIImage? {
        guard let card = card else {
            return UIImage(named: "card_back")
        }

        let suitOffset: Int
        switch card.suit {
        case "Hearts":
            suitOffset = 0
        case "Diamonds":
            suitOffset = 13
        case "Clubs":
            suitOffset = 26
        case "Spades":
            suitOffset = 39
        default:
            suitOffset = 0
        }
        
        let imageIndex = suitOffset + card.rank.rawValue - 1
        return UIImage(named: "\(imageIndex + 1)") // +1 for 1-52 mapping
    }

    // IBAction for betting and starting the round
    @IBAction func placeBetAndPlayRound(_ sender: UIButton) {
        guard let betAmountString = betAmountTextField.text,
              let betAmount = Int(betAmountString),
              betAmount > 0 else {
            winnerLabel.text = "Please enter a valid bet amount"
            return
        }
        
        // Place bets and play the round
        luckyCardDrawGame.placeBets(betAmount: betAmount)
        luckyCardDrawGame.dealCards()
        
        // Debugging: Print cards for each player
        for player in luckyCardDrawGame.players {
            if let card = player.card {
                //print("\(player.name) drew a \(card.rank) of \(card.suit)")
            }
        }
        
        if let winner = luckyCardDrawGame.determineWinner() {
           
            // Award the pot to the winner
            luckyCardDrawGame.players = luckyCardDrawGame.players.map {
                var p = $0
                if p.name == winner.name {
                    p.chips += luckyCardDrawGame.pot
                }
                return p
            }
            // Reset pot
            winnerLabel.text = "\(winner.name) wins the pot of \(luckyCardDrawGame.pot) chips!"
            luckyCardDrawGame.pot = 0
        } else {
            winnerLabel.text = "No winner in this round."
        }
        
        updateUI() // Ensure UI is updated after determining the winner
    }
    
    
    @IBAction func btnBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
}

