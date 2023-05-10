import UIKit
import AVFoundation

class BackgroundVoicesViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var backgroundVoicesCollectionView: UICollectionView!
    
    let noises = ["Bloom", "By The Seaside", "Chimes", "Crickets", "Droplets", "Night Owl", "Rain", "Stream"]
    let systemSoundIDs = [1116, 1117, 1118, 1119, 1120, 1121, 1122, 1123]
    
    var audioPlayer: AVAudioPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Register the collection view cell class
        let nib = UINib(nibName: "BackgroundNoisesCollectionViewCell", bundle: nil)
        backgroundVoicesCollectionView.register(nib, forCellWithReuseIdentifier: "backgroundNoiceCell")
        
        // Set collection view delegate and data source
        backgroundVoicesCollectionView.delegate = self
        backgroundVoicesCollectionView.dataSource = self
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
        cell.layer.borderWidth = 3.0 // Set the border width of the cell
        cell.layer.borderColor = UIColor.red.cgColor // Set the border color of the cell

        cell.noiseNameLabel.text = noises[indexPath.row]
        
        return cell
    }


    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Play the system sound when the user taps on the cell
        AudioServicesPlaySystemSound(SystemSoundID(systemSoundIDs[indexPath.row]))
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

