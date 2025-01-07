// The Swift Programming Language
// https://docs.swift.org/swift-book

import UIKit
import AVFoundation

public class QRCodeScanner: UIViewController, AVCaptureMetadataOutputObjectsDelegate, AVCapturePhotoCaptureDelegate  {
    
    private var captureSession: AVCaptureSession!
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    private let photoOutput = AVCapturePhotoOutput()
    
    @IBOutlet weak var scannerView: UIView!
    @IBOutlet weak var cancelButton: UIButton!
    
    // 스캔된 QR 코드 문자열과 이미지를 반환할 클로저
    public var didScanQRCode: ((String) -> Void)?
    private var lastScannedCode: String?
    
    // 바코드 형식을 배열로 받아서 설정
    public var barcodeTypes: [AVMetadataObject.ObjectType] = [.qr, .code128]
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        // XIB 파일 로드
        let nib = UINib(nibName: "QRCodeScannerView", bundle: Bundle.module)
        guard nib.instantiate(withOwner: self, options: nil).first is UIView else {
           fatalError("Could not load QRCodeScannerView from XIB")
        }
        
        setupScanner()
    }

    override public func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        videoPreviewLayer!.frame = view.bounds // 화면 크기에 맞게 프레임 업데이트
        
        // 화면 방향에 맞게 미리보기 회전 처리
        if let connection = videoPreviewLayer?.connection {
            if connection.isVideoOrientationSupported {
                switch UIDevice.current.orientation {
                case .portrait:
                    connection.videoOrientation = .portrait
                case .landscapeLeft:
                    connection.videoOrientation = .landscapeRight
                case .landscapeRight:
                    connection.videoOrientation = .landscapeLeft
                case .portraitUpsideDown:
                    connection.videoOrientation = .portraitUpsideDown
                default:
                    connection.videoOrientation = .portrait
                }
            }
        }
    }
    
    private func setupScanner() {
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video),
              let videoDeviceInput = try? AVCaptureDeviceInput(device: videoCaptureDevice) else { return }

        captureSession = AVCaptureSession()

        if (captureSession?.canAddInput(videoDeviceInput) == true) {
            captureSession?.addInput(videoDeviceInput)
        } else {
            return
        }

        let metadataOutput = AVCaptureMetadataOutput()
        if (captureSession?.canAddOutput(metadataOutput) == true) {
            captureSession?.addOutput(metadataOutput)
            captureSession.addOutput(photoOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            // 스캔할 바코드 형식들을 배열로 받음
            metadataOutput.metadataObjectTypes = barcodeTypes
        } else {
            return
        }

        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
        videoPreviewLayer?.frame = view.layer.bounds
        videoPreviewLayer?.videoGravity = .resizeAspectFill
        scannerView.layer.addSublayer(videoPreviewLayer!)

        // startRunning을 백그라운드 스레드에서 호출
        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession.startRunning()
        }
    }

    public func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            captureSession?.stopRunning()
            
            self.didScanQRCode?(stringValue)
            dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        captureSession?.stopRunning()
        dismiss(animated: true, completion: nil)
    }
}
