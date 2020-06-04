//
//  NewPostViewController.swift
//  Sorbet
//
//  Created by Georgy Stepanov on 04.06.2020.
//  Copyright © 2020 Georgy Stepanov. All rights reserved.
//

import UIKit

fileprivate let newPostCellReuseIdentifier = "NewPostCell"

class NewPostViewController: UIViewController {

    var cellsPerRow: Int = 1
    
    var imagePicker: UIImagePickerController = UIImagePickerController()
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        
        collectionView.register(UINib(nibName: "NewPostCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: newPostCellReuseIdentifier)
        
        navigationController?.navigationBar.largeTitleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.color.sunFlower
        ]
    }

}


extension NewPostViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: newPostCellReuseIdentifier, for: indexPath) as! NewPostCollectionViewCell
        
        if indexPath.row == 0 {
            cell.typeNameLabel.text = "Just meme"
        } else if indexPath.row == 1 {
            cell.typeNameLabel.text = "Каламбур!"
        } else if indexPath.row == 2 {
            cell.typeNameLabel.text = "Комикс"
        }
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! NewPostCollectionViewCell
        collectionView.deselectItem(at: indexPath, animated: true)
        UIView.animate(withDuration: 0.2, delay: 0, options: UIView.AnimationOptions.curveEaseIn, animations: {
            cell.view.backgroundColor = UIColor.color.sunFlower
            cell.typeNameLabel.textColor = #colorLiteral(red: 0.1803680062, green: 0.180406034, blue: 0.1803655922, alpha: 1)
        }) { (completed) in
            UIView.animate(withDuration: 0.2, delay: 0, options: UIView.AnimationOptions.curveEaseOut, animations: {
                  cell.view.backgroundColor = #colorLiteral(red: 0.1803680062, green: 0.180406034, blue: 0.1803655922, alpha: 1)
                  cell.typeNameLabel.textColor = #colorLiteral(red: 0.9791200757, green: 0.7600466609, blue: 0, alpha: 1)
              })
        }
        
        if indexPath.row == 0 {
            present(imagePicker, animated: true, completion: nil)
        }
    }
        
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
                
        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
        
        let totalSpace = flowLayout.sectionInset.left + flowLayout.sectionInset.right + (flowLayout.minimumInteritemSpacing * CGFloat(cellsPerRow - 1))
        
        let size = Int((collectionView.bounds.width - totalSpace) / CGFloat(cellsPerRow))
        
        return CGSize(width: size, height: 140)
        
    }
    
}

extension NewPostViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.editedImage] as! UIImage
                
        NetworkManager.shared.uploadImage(url: "/meme/single", image, resize: CGSize(width: 1024, height: 768), compressionQuality: 0) {
            picker.dismiss(animated: true) {
                print("Meme added")
            }
        }
    }
}
