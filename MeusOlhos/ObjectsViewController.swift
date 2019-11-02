import UIKit
import AVKit
import Vision

class ObjectsViewController: UIViewController {
    
    @IBOutlet weak var viCamera: UIView!
    @IBOutlet weak var lbIdentifier: UILabel!
    @IBOutlet weak var lbConfidence: UILabel!
    
    lazy var caputureMananger:CaptureManager = {
        let caputureMananger = CaptureManager()
        caputureMananger.videoBufferDelegate = self
        return caputureMananger
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.lbIdentifier.text = ""
        self.lbConfidence.text = ""
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard let previewLayer = caputureMananger.startCameraCapture() else {return}
        previewLayer.frame = viCamera.bounds
        viCamera.layer.addSublayer(previewLayer)
        
    
    }
    
    @IBAction func analyse(_ sender: UIButton) {
        
        var component = ""
        var message = ""
        if let word = lbIdentifier.text{
            component = word.components(separatedBy: ", ").first!
            if let percent = lbConfidence.text{
                message = "I am \(percent) confident that this is a \(component)"
            }
            
        }
        
        let utterance = AVSpeechUtterance(string: message)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        let synthetizer = AVSpeechSynthesizer()
        synthetizer.speak(utterance)
    }
}

extension ObjectsViewController: AVCaptureVideoDataOutputSampleBufferDelegate{
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        guard let pixelBuffer:CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        //recupero modelo
        guard let model = try? VNCoreMLModel(for: VGG16().model) else { return }
        
        //recupero os resultados
        let request = VNCoreMLRequest(model: model) { [weak self] request, error in
            if error == nil {
                
                guard let results = request.results as? [VNClassificationObservation] else { return }
                
                for i in 0...5{
                    print(results[i].identifier , results[i].confidence)
                   
                }
                 print("============================================")
                
                guard let firstObservation = results.first else { return }
                DispatchQueue.main.async {
                    self?.lbIdentifier.text = firstObservation.identifier
                    self?.lbConfidence.text = "\(round(firstObservation.confidence * 1000) / 10)%"
                }
            }else{
                print(error?.localizedDescription)
                return
            }
        }
        
        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
    }
}
