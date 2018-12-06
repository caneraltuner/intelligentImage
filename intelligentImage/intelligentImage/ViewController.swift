//
//  ViewController.swift
//  intelligentImage
//
//  Created by akademobi4 on 6.12.2018.
//  Copyright © 2018 enes. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var resultLabel: UILabel!
    var chosenImage = CIImage()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction func changeClicked(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        picker.sourceType = .photoLibrary
        self.present(picker,animated: true,completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
        self.dismiss(animated: true, completion: nil)
        if let ciImage = CIImage(image: imageView.image!) {
            self.chosenImage = ciImage
        }
        recognizeImage(image: chosenImage)
    }
    
    func recognizeImage(image: CIImage) {
        resultLabel.text = "Finding..."
        if let model = try? VNCoreMLModel(for: GoogLeNetPlaces().model) {
            let request = VNCoreMLRequest(model: model) { (vnrequest, error) in
                if let results = vnrequest.results as? [VNClassificationObservation] {
                    let tapResult = results.first
                    DispatchQueue.main.async {
                        let conf = (tapResult?.confidence)! * 100
                        let rounded = Int(conf * 100) / 100
                        self.resultLabel.text = "\(rounded)% it's a \(tapResult!.identifier)"
                    }
                }
            }
            let handler = VNImageRequestHandler(ciImage: image)
            DispatchQueue.global(qos: .userInteractive).async {
                do {
                    try handler.perform([request])
                } catch {
                    print("error")
                }
            }
        }
    }
    
}

