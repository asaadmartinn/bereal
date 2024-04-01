//  PostViewController.swift
//  BeReal Clone
//  Created by Amir on 2/29/24.

import UIKit
import PhotosUI
import ParseSwift

class PostViewController: UIViewController {
    
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var captionTextField: UITextField!
    @IBOutlet weak var previewImageView: UIImageView!
    
    private var pickedImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func onPickedImageTapped(_ sender: UIButton) {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.preferredAssetRepresentationMode = .current
        config.selectionLimit = 1
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }
    @IBAction func onSharetapped(_ sender: Any) {
        view.endEditing(true)
        guard let image = pickedImage,
              let imageData = image.jpegData(compressionQuality: 0.1) else {
            return
    }
        let imageFile = ParseFile(name: "image.jpg", data: imageData)
        var post = Post()
        post.imageFile = imageFile
        post.caption = captionTextField.text
        post.user = User.current
        post.save { [weak self] result in
            if var currentUser = User.current {
                currentUser.lastPostedDate = Date()
                currentUser.save { [weak self] result in
                    switch result {
                    case .success(let user):
                        print("✅ User Saved! \(user)")
                        DispatchQueue.main.async {
                            self?.navigationController?.popViewController(animated: true)
                        }
                        
                    case .failure(let error):
                        self?.showAlert(description: error.localizedDescription)
                    }
                }
            }
        }
    }
    
    
    @IBAction func onTakePhotoTapped(_ sender: Any) {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            print("❌📷 Camera not available")
            return
        }
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        present(imagePicker, animated: true)
    }
    
    
    @IBAction func onViewTapped(_ sender: Any) {
        view.endEditing(true)
    }
    private func showAlert(description: String? = nil) {
        let alertController = UIAlertController(title: "Oops...", message: "\(description ?? "Please try again...")", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(action)
        present(alertController, animated: true)
    }
}
extension PostViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        guard let provider = results.first?.itemProvider,
           provider.canLoadObject(ofClass: UIImage.self) else { return }
        provider.loadObject(ofClass: UIImage.self) { [weak self] object, error in
           guard let image = object as? UIImage else {
              self?.showAlert()
              return
           }
            if let error = error {
                self?.showAlert(description:error.localizedDescription)
              return
           } else {
              DispatchQueue.main.async {
                 self?.previewImageView.image = image
                 self?.pickedImage = image
              }
           }
        }
    }
}
extension PostViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
            guard let image = info[.editedImage] as? UIImage else {
                print("❌📷 Unable to get image")
                return
            }
            previewImageView.image = image
            pickedImage = image
    }

}

