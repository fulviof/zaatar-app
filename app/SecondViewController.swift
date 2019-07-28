//
//  SecondViewController.swift
//  app
//
//  Created by Fulvio Fanelli on 13/07/19.
//  Copyright © 2019 zaatar. All rights reserved.
//

import UIKit
import Alamofire

class SecondViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    var imagePicker: UIImagePickerController!
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var label: UITextField!
    
    @IBAction func uploadPhoto(_ sender: Any) {
        
        if let name = label.text {
            if var img = imageView.image {
                img = fixOrientation(img: img)
                uploadImage(userImage: img, name: name)
            }
            else {
                print("Tire uma foto")
            }
        }
        else {
            print("Preencha o nome")
        }
        
        self.view.endEditing(true)
    }
    
    @IBAction func takePhoto(_ sender: Any) {
        
        imagePicker =  UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imagePicker.dismiss(animated: true, completion: nil)
        imageView.image = info[.originalImage] as? UIImage
    }
    
    func uploadImage(userImage: UIImage, name: String) {
        
        let base64 = convertToBase64(image: userImage)
        
        let url = "https://zaatar-api.herokuapp.com/photos" // This will be your link
        let parameters: Parameters = ["img": base64, "name": name]      //This will be your parameter
        
        Alamofire.request(url, method: .post, parameters: parameters).responseJSON { response in
            print("Upload completed!")
            
            self.tabBarController?.selectedIndex = 0
        }
    }
    
    func convertToBase64(image: UIImage) -> String {
        return image.jpegData(compressionQuality: 0.1)!
            .base64EncodedString()
    }
    
    func fixOrientation(img: UIImage) -> UIImage {
        if (img.imageOrientation == .up) {
            return img
        }
        
        UIGraphicsBeginImageContextWithOptions(img.size, false, img.scale)
        let rect = CGRect(x: 0, y: 0, width: img.size.width, height: img.size.height)
        img.draw(in: rect)
        
        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return normalizedImage
    }

}



