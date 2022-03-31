//
//  ViewController.swift
//  NIR
//
//  Created by Егор Шкарин on 31.03.2022.
//

import UIKit
import CoreImage

class ViewController: UIViewController, ImagePickerDelegate {
    
    
    @IBOutlet weak var imageView: UIImageView!
    private var imagePicker: ImagePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imagePicker = ImagePicker(presentationController: self, delegate: self)
        imageView.image = UIImage(named: "face6")
        detect()
    }
    
    @IBAction func newPhoto(_ sender: UIBarButtonItem) {
        let randNum = Int.random(in: 6...35)
        self.imageView.image = UIImage(named: "face\(randNum)")
        self.detect()
    }
    @IBAction func takePhoto(_ sender: UIBarButtonItem) {
        self.imagePicker.present(from: view)
    }
    
    func detect() {
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.imageView.subviews.forEach({$0.removeFromSuperview()})
            self?.view.layoutIfNeeded()
        }
        
        guard let image = imageView.image, let personciImage = CIImage(image: image) else {
            return
        }
        let imageOptions =  NSDictionary(object: NSNumber(value: 5) as NSNumber, forKey: CIDetectorImageOrientation as NSString)
        let accuracy = [CIDetectorAccuracy: CIDetectorAccuracyHigh]
        let faceDetector = CIDetector(ofType: CIDetectorTypeFace, context: nil, options: accuracy)
        let faces = faceDetector?.features(in: personciImage, options: imageOptions as? [String : AnyObject])
        
        // Добавили конвертацию координат
        let ciImageSize = personciImage.extent.size
        var transform = CGAffineTransform(scaleX: 1, y: -1)
        transform = transform.translatedBy(x: 0, y: -ciImageSize.height)
        
        if let faces = faces as? [CIFaceFeature], !faces.isEmpty {
            for face in faces {
                
                print("Found bounds are \(face.bounds)")
                
                // Добавили вычисление фактического положения faceBox
                var faceViewBounds = face.bounds.applying(transform)
                
                let viewSize = imageView.bounds.size
                
                let scale = min(viewSize.width / ciImageSize.width,
                                viewSize.height / ciImageSize.height)
                
                let offsetX = (viewSize.width - ciImageSize.width * scale) / 2
                
                let offsetY = (viewSize.height - ciImageSize.height * scale) / 2
                
                faceViewBounds = faceViewBounds.applying(CGAffineTransform(scaleX: scale, y: scale))
                faceViewBounds.origin.x += offsetX
                faceViewBounds.origin.y += offsetY
                
                let faceBox = UIView(frame: faceViewBounds)
                
                faceBox.layer.borderWidth = 3
                faceBox.layer.borderColor = UIColor.red.cgColor
                faceBox.backgroundColor = UIColor.clear
                
                UIView.animate(withDuration: 0.3) { [weak self] in
                    self?.imageView.addSubview(faceBox)
                    self?.view.layoutIfNeeded()
                }
                
                if face.hasLeftEyePosition {
                    print("Left eye bounds are \(face.leftEyePosition)")
                }
                
                if face.hasRightEyePosition {
                    print("Right eye bounds are \(face.rightEyePosition)")
                }
            }
        } else {
            let alert = UIAlertController(title: "Лица нет",
                                          message: "Ничего не нашлось",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK",
                                          style: .default,
                                          handler: nil))
            self.present(alert,
                         animated: true,
                         completion: nil)
        }
    }
    func didSelect(image: UIImage?) {
        self.imageView.image = image
        detect()
    }
    
}

