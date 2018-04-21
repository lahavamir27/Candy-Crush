import UIKit
import SpriteKit
import AVFoundation

class GameViewController: UIViewController {
    
    
    // MARK: Varibles

    var scene: GameScene!
    var level: Level!
    var movesLeft = 0
    var score = 0
    var currentLevelNum = 1
    var tapGestureRecognizer: UITapGestureRecognizer!
    
    // MARK: Outlets

    @IBOutlet weak var targetLabel: UILabel!
    @IBOutlet weak var movesLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var gameOverPanel: UIImageView!
    @IBOutlet weak var shuffleButton: UIButton!
    @IBOutlet weak var hintButton: UIButton!

    
    // MARK: Game Cycle
    
    func beginGame() {
        
        movesLeft = level.maximumMoves
        score = 0
        updateLabels()
        level.resetComboMultiplier()
        scene.animateBeginGame()  {self.shuffleButton.isHidden = false
            self.hintButton.isHidden = false
            }
        
        shuffle()
        
        
        
    }
    
    func beginNextTurn() {
        level.resetComboMultiplier()
        level.detectPossibleSwaps()
        self.decrementMoves(steps: 1)
        view.isUserInteractionEnabled = true
    }
    
    
    func showGameOver() {
        
        gameOverPanel.isHidden = false
        scene.isUserInteractionEnabled = false
        
        scene.animateGameOver() {
            self.tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.hideGameOver))
            self.view.addGestureRecognizer(self.tapGestureRecognizer)
        }
        shuffleButton.isHidden = true
        hintButton.isHidden = true
        
    }
    
    
    // MARK: Gestures


    // block user from swap while animate preform
    func handleSwipe(swap: Swap) {

        //make the screen inactive
        view.isUserInteractionEnabled = false
        
        //check if the swap is allowed
        if level.isPossibleSwap(swap: swap) {
            level.performSwap(swap: swap)
            scene.animateSwap(swap: swap, completion: handleMatches)
        } else {
            
            scene.animateInvalidSwap(swap: swap) {
                self.view.isUserInteractionEnabled = true
            }
        }
    }


    // MARK: Action

    @IBAction func shuffleButtonPressed(_: AnyObject) {
        shuffle()
        decrementMoves(steps: 1)
    }
    
    // MARK: Helpes

    func handleMatches() {
        
        let chains = level.removeMatches()
        
        if chains.count == 0 {
            beginNextTurn()
            return
        }
        scene.animateMatchedCookies(chains: chains) {
            for chain in chains {
                self.score += chain.score
            }
            self.updateLabels()
            let columns = self.level.fillHoles()
            self.scene.animateFallingCookies(columns: columns) {
                let columns = self.level.topUpCookies()
                self.scene.animateNewCookies(columns: columns) {
                    self.handleMatches()
                }
            }
        }
    }
    
    func updateLabels() {
        targetLabel.text = String(format: "%ld", level.targetScore)
        movesLabel.text = String(format: "%ld", movesLeft)
        scoreLabel.text = String(format: "%ld", score)
    }
    
    func setupLevel(levelNum: Int) {
        let skView = view as! SKView
        skView.isMultipleTouchEnabled = false
        
        // Create and configure the scene.
        scene = GameScene(size: skView.bounds.size)
        scene.scaleMode = .aspectFill
        
        // Setup the level.
        level = Level(filename: "Level_\(levelNum)")
        scene.level = level
        
        scene.addTiles()
        scene.swipeHandler = handleSwipe
        
        gameOverPanel.isHidden = true
        shuffleButton.isHidden = true
        hintButton.isHidden = true
        
        // Present the scene.
        skView.presentScene(scene)
        
        // Start the game.
        beginGame()
    }
    
    func decrementMoves(steps: Int) {
        movesLeft -= steps
        updateLabels()
        if score >= level.targetScore {
            gameOverPanel.image = UIImage(named: "LevelComplete")
            currentLevelNum = currentLevelNum < NumLevels ? currentLevelNum+1 : 1
            showGameOver()
        } else if movesLeft == 0 {
            gameOverPanel.image = UIImage(named: "GameOver")
            showGameOver()
        }
    }
    
    func hideGameOver() {
        view.removeGestureRecognizer(tapGestureRecognizer)
        tapGestureRecognizer = nil
        
        gameOverPanel.isHidden = true
        scene.isUserInteractionEnabled = true
        
        setupLevel(levelNum: currentLevelNum)
        
    }
    
    func hint(){
        
        let posibleSwapArray = Array(level.possibleSwaps)
        print(posibleSwapArray)
        if posibleSwapArray.count > 0 {

            hintButton.isEnabled = false
            let swap = posibleSwapArray[0]

            scene.showSelectionIndicatorForCookie(cookie: swap.cookieA, completion: enableHint)
//            decrementMoves(steps: 2)

        }else{
            print("no hint for u")
        }
    }
    
    func enableHint() {
        
        hintButton.isEnabled = true
        }
    
    func shuffle() {
        scene.removeAllCookieSprites()
        let newCookies = level.shuffle()
        scene.addSpritesForCookies(cookies: newCookies)
    }
    
    func delay(delay: Double, closure: ()->()) {
 
    }
    
    @IBAction func getHint(sender: UIButton) {
        hint()
            print("hint")
    }
    // MARK: Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup view with level 1
        setupLevel(levelNum: currentLevelNum)
        
        let clock = Clock(time: 5.0)
        clock.startTimer(){_ in
            print("finish")
        
        
        }

        
        // Start the background music.
        backgroundMusic?.play()
    }
    
    lazy var backgroundMusic: AVAudioPlayer? = {
        guard let url = Bundle.main.url(forResource: "Mining by Moonlight", withExtension: "mp3") else {
            return nil
        }
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.numberOfLoops = -1
            return player
        } catch {
            return nil
        }
    }()
    
    
}
