import UIKit
import AVFoundation

class BackgroundVoicesViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var backgroundVoicesCollectionView: UICollectionView!
    
    let noises = ["Rain", "Forest", "Campfire", "River", "Wind", "Night", "Droplets", "Chimes"]
    let soundFiles = ["rain.mp3", "forest.mp3", "campfire.mp3", "river.mp3", "wind.mp3", "night.mp3", "droplets.mp3", "chimes.mp3"]
    
    var audioPlayers: [AVAudioPlayer] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Register the collection view cell class
        let nib = UINib(nibName: "BackgroundNoisesCollectionViewCell", bundle: nil)
        backgroundVoicesCollectionView.register(nib, forCellWithReuseIdentifier: "backgroundNoiceCell")
        
        // Set collection view delegate and data source
        backgroundVoicesCollectionView.delegate = self
        backgroundVoicesCollectionView.dataSource = self
        
        // Load audio players
        for file in soundFiles {
            if let url = Bundle.main.url(forResource: file, withExtension: nil) {
                do {
                    let player = try AVAudioPlayer(contentsOf: url)
                    player.numberOfLoops = -1 // Play infinitely
                    audioPlayers.append(player)
                } catch {
                    print("Error loading audio player for file \(file): \(error.localizedDescription)")
                }
            }
        }
    }
    
    // MARK: - Collection View Delegate
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return noises.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "backgroundNoiceCell", for: indexPath) as! BackgroundNoisesCollectionViewCell
        
        // Set cell image and text
        switch indexPath.row {
        case 0:
            cell.noiseImageView.image = UIImage(named: "1")
        case 1:
            cell.noiseImageView.image = UIImage(named: "2")
        case 2:
            cell.noiseImageView.image = UIImage(named: "3")
        case 3:
            cell.noiseImageView.image = UIImage(named: "4")
        case 4:
            cell.noiseImageView.image = UIImage(named: "5")
        case 5:
            cell.noiseImageView.image = UIImage(named: "6")
        case 6:
            cell.noiseImageView.image = UIImage(named: "7")
        case 7:
            cell.noiseImageView.image = UIImage(named: "8")
        default:
            cell.noiseImageView.image = nil
        }
        
        cell.noiseImageView.contentMode = .scaleAspectFill
        cell.contentView.layer.cornerRadius = 10
        cell.contentView.layer.masksToBounds = true
        cell.layer.cornerRadius = 20
        cell.layer.masksToBounds = true
        cell.layer.borderWidth = 2.0 // Set the border width of the cell
        cell.layer.borderColor = UIColor.red.cgColor // Set the border color of the cell

        cell.noiseNameLabel.text = noises[indexPath.row]
        
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        // Determine if the selected item is currently playing
        let selectedItemIsPlaying = audioPlayers[indexPath.row].isPlaying
        
        // Stop the currently playing sound
        for player in audioPlayers {
            if player.isPlaying {
                player.stop()
            }
        }

        // Play the selected sound if it wasn't already playing
        if !selectedItemIsPlaying {
            let player = audioPlayers[indexPath.row]
            player.currentTime = 0 // Restart from the beginning
            player.play()
        }

        // Update button transparency based on the playing state
        for visibleCellIndexPath in collectionView.indexPathsForVisibleItems {
            let cell = collectionView.cellForItem(at: visibleCellIndexPath) as! BackgroundNoisesCollectionViewCell
            if selectedItemIsPlaying { // If a sound was playing before tapping, all buttons should be fully visible
                cell.alpha = 1.0
            } else { // If no sound was playing before tapping, the playing button should be fully visible, while others are half visible
                cell.alpha = visibleCellIndexPath == indexPath ? 1.0 : 0.5
            }
        }
    }
}

// MARK: - Collection View Flow Layout

extension BackgroundVoicesViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let spacing: CGFloat = 10.0 // Set the spacing between cells
        let cellWidth = (collectionView.bounds.width - spacing * 3) / 2 // Calculate the width of each cell
        let cellHeight = cellWidth + 30 // Set the height of each cell
        return CGSize(width: cellWidth, height: cellHeight)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let spacing: CGFloat = 10.0 // Set the spacing between cells
        return UIEdgeInsets(top: 10, left: spacing, bottom: 10, right: spacing) // Set the top and bottom insets to 10, and the left and right insets to the spacing value
    }
}

