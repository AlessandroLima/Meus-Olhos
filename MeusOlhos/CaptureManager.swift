
import Foundation
import AVKit

class CaptureManager{
    
    lazy var captureSession: AVCaptureSession = {
        let captureSession = AVCaptureSession()
        captureSession.sessionPreset = .photo
        return captureSession
    }()
    
    weak var videoBufferDelegate: AVCaptureVideoDataOutputSampleBufferDelegate?
    
    init(){
        
    }
    
    func startCameraCapture() -> AVCaptureVideoPreviewLayer?{
        if askForPermition(){
            
            guard let captureDevice = AVCaptureDevice.default(for: .video) else{return nil}
            
            do{
                let imput =  try AVCaptureDeviceInput(device: captureDevice)
                captureSession.addInput(imput)
            }catch{
                print(error.localizedDescription)
                return nil
            }
            captureSession.startRunning()
            
            let videoDataOutput = AVCaptureVideoDataOutput()
            videoDataOutput.setSampleBufferDelegate(self.videoBufferDelegate, queue: DispatchQueue(label: "cameraQueue"))
            captureSession.addOutput(videoDataOutput)
            
            let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            return previewLayer
        }else{
            return nil
        }
        
    }
    
    func askForPermition() -> Bool{
        var hasPermission:Bool = true
        
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            hasPermission = true
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { success in
                hasPermission = success
            }
        case .restricted, .denied:
            hasPermission = false
        }
        
        return hasPermission
    }
}
