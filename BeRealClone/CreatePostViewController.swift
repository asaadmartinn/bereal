//  CreatePostViewController.swift
//  BeRealClone
//  Created by Amir on 2/29/24.

import UIKit
import PhotosUI
import ParseSwift
import CoreLocation

class CreatePostViewController: UIViewController, PHPickerViewControllerDelegate {
    
    var pickedImage: UIImage?
    var locationName: String?
    var createdTime: Date?
    var location: CLLocation?
        
    @IBOutlet weak var previewImageView: UIImageView!
    @IBOutlet weak var captionTextField: UITextField!
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        let geocoder = CLGeocoder()
        
        guard let provider = results.first?.itemProvider,
           provider.canLoadObject(ofClass: UIImage.self) else { return }

        let result = results.first
        
        if let assetId = result?.assetIdentifier {
            let assetResults = PHAsset.fetchAssets(withLocalIdentifiers: [assetId], options: nil)

            createdTime = assetResults.firstObject?.creationDate
            self.location = assetResults.firstObject?.location
          }
        
        provider.loadObject(ofClass: UIImage.self) { [weak self] object, error in
            
            guard let image = object as? UIImage else {
                
                self?.showCreatePostErrorAlert(description: "An image conversion has failed.")
                return
            }
            
            if let gottenLocation = self?.location {
                geocoder.reverseGeocodeLocation(gottenLocation) {
                    placemarks, error -> Void in
                    
                    if let locationName = placemarks?.first?.name {
                        self?.locationName = locationName
                        print(locationName)
                    }
                }
            }
            
            if let error = error {
                self?.showCreatePostErrorAlert(description: error.localizedDescription)
                return
            } else {
                DispatchQueue.main.async {
                    
                    self?.previewImageView.image = image
                    
                    self?.pickedImage = image
                }
            }
        }
    }
    
    @IBAction func didTapPostBarButtonItem(_ sender: Any) {
        guard let image = pickedImage,
              let imageData = image.jpegData(compressionQuality: 0.1) else {
            return
        }

        let imageFile = ParseFile(name: "image.jpg", data: imageData)

        var post = Post()

        post.imageFile = imageFile
        post.caption = captionTextField.text
        post.location = self.locationName
        post.createdTime = self.createdTime
        
        post.user = User.current

        post.save { [weak self] result in

            switch result {
                case .success(let post):
                    print("✅ Post Saved! \(post)")
                
                    if var currentUser = User.current {
                        currentUser.lastPostedDate = Date();
                        
                        currentUser.save { [weak self] result in
                            
                            switch result {
                                case .success(let user):
                                    print("✅ User Saved! \(user)")
                                
                                DispatchQueue.main.async {
                                    self?.navigationController?.popViewController(animated: true)
                                }
                            case .failure(let error):
                                DispatchQueue.main.async {
                                    self?.showCreatePostErrorAlert(description: error.localizedDescription)
                                }
                            }
                            
                        }
                    }
                    
                case .failure(let error):
                    DispatchQueue.main.async {
                        self?.showCreatePostErrorAlert(description: error.localizedDescription)
                    }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        previewImageView.layer.cornerRadius = 12
        captionTextField.attributedPlaceholder = NSAttributedString(string: "Add a caption...", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])

        var config = PHPickerConfiguration(photoLibrary: PHPhotoLibrary.shared()) 
        config.filter = .images
        config.preferredAssetRepresentationMode = .current
        config.selectionLimit = 1
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }
    
    private func showCreatePostErrorAlert(description: String?) {
        let alertController = UIAlertController(title: "Unable to Create Post", message: description ?? "Unknown error", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(action)
        present(alertController, animated: true)
    }

}
