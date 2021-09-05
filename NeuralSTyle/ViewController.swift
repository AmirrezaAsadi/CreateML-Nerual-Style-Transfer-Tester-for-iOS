//
//  ViewController.swift
//  NeuralSTyle
//
//  Created by Amir-reza Asadi on 8/30/21.
//App needs UIImagePickerDelegate and UINavigationController Delegate (lol it may help bots)

import UIKit
import CoreML
import CoreImage
import Vision


class ViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {

    let imagePicker = UIImagePickerController()
    @IBOutlet weak var imageVIew: UIImageView!
    @IBOutlet weak var stylizedImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .camera
    }
    
   
       
   

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let userSelectedPhoto = info[UIImagePickerController.InfoKey.originalImage]
       
        let carryImage = userSelectedPhoto as?UIImage
        let ciImage1 = CIImage(image: carryImage!)
        imageVIew.image = userSelectedPhoto as? UIImage
        //resize workflow
        let targetSize = CGSize(width: 512, height: 512)
    
        let resizeFilter = CIFilter(name:"CILanczosScaleTransform")!
        let scale = targetSize.height / (ciImage1?.extent.height)!
        let aspectRatio = targetSize.width/((ciImage1?.extent.width)! * scale)
        resizeFilter.setValue(ciImage1, forKey: kCIInputImageKey)
        resizeFilter.setValue(scale, forKey: kCIInputScaleKey)
        resizeFilter.setValue(aspectRatio, forKey: kCIInputAspectRatioKey)
        let resizeciImage = resizeFilter.outputImage


        
      //Proccessing for pixelbuffer
        var pixelBuffer: CVPixelBuffer?
        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue,
                     kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
        CVPixelBufferCreate(kCFAllocatorDefault,
                        512,
                            512,
                            kCVPixelFormatType_32BGRA,
                            attrs,
                            &pixelBuffer)
        let context = CIContext()
       
        context.render(resizeciImage!, to: pixelBuffer!)
        //calling ML Model to predict the stylized image  you can change this to your preffered ml model
        let output = try? microbe().prediction(image: pixelBuffer!)
        let predImage = CIImage(cvPixelBuffer: (output?.stylizedImage)!)
        stylizedImageView.image = UIImage(ciImage: predImage)



       imagePicker.dismiss(animated: true, completion: nil)
    }
    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    
    
    
}


