Add Package .. 로 https://github.com/Liam201106/QRCodeScanner.git 을 입력하여 사용할 타겟에 추가한다.


- 사용방법

  import QRCodeScanner

        let scannerVC = QRCodeScanner()

	        scannerVC.barcodeTypes = [.qr, .code128, .ean13]

	        scannerVC.didScanQRCode = { qrCode in

	    	print("Scanned QR Code: \(qrCode)")
    
        }

        self.viewController!.present(scannerVC, animated: true)


- barcodeTypes : 스캔할 타입 array 로 추가
- didScanQRCode : 인식한 String 결과값
  
