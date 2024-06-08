import SwiftUI
import AVFoundation

public struct CameraView: UIViewControllerRepresentable {
    @Binding private var image: UIImage?
    @Environment(\.dismiss) private var dismiss

    public init(image: Binding<UIImage?>) {
        self._image = image
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    public func makeUIViewController(context: Context) -> UIViewController {
        let viewController = CameraViewController()
        viewController.delegate = context.coordinator
        return viewController
    }

    public func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

extension CameraView {
    public class Coordinator: NSObject, AVCapturePhotoCaptureDelegate {
        let parent: CameraView

        init(_ parent: CameraView) {
            self.parent = parent
        }

        public func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
            guard let data = photo.fileDataRepresentation(),
                  let uiImage = UIImage(data: data) else {
                return
            }
            DispatchQueue.main.async {
                self.parent.image = uiImage
                self.parent.dismiss()
            }
        }
    }
}

class CameraViewController: UIViewController, AVCapturePhotoCaptureDelegate {
    var captureSession: AVCaptureSession!
    var photoOutput: AVCapturePhotoOutput!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var delegate: AVCapturePhotoCaptureDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        checkCameraAuthorization { authorized in
            if authorized {
                self.setupCamera()
            } else {
                self.showSettingsAlert()
            }
        }

        let overlay = createSquareOverlay()
        view.addSubview(overlay)

        let takePhotoButton = UIButton(frame: CGRect(x: (view.bounds.width - 70) / 2, y: view.bounds.height - 100, width: 70, height: 70))
        takePhotoButton.layer.cornerRadius = 35
        takePhotoButton.backgroundColor = UIColor.clear
        takePhotoButton.layer.borderColor = UIColor.white.cgColor
        takePhotoButton.layer.borderWidth = 5
        takePhotoButton.addTarget(self, action: #selector(takePicture), for: .touchUpInside)
        overlay.addSubview(takePhotoButton)

        let cancelButton = UIButton(frame: CGRect(x: 20, y: view.bounds.height - 80, width: 120, height: 50))
        cancelButton.setTitle("キャンセル", for: .normal)
        cancelButton.setTitleColor(UIColor.white, for: .normal)
        cancelButton.addTarget(self, action: #selector(cancel), for: .touchUpInside)
        overlay.addSubview(cancelButton)
    }

    @objc func takePicture() {
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: delegate ?? self)
    }

    @objc func cancel() {
        self.dismiss(animated: true, completion: nil)
    }

    func createSquareOverlay() -> UIView {
        let overlay = UIView(frame: view.bounds)
        overlay.backgroundColor = UIColor.clear

        let squareSideLength = min(overlay.bounds.width, overlay.bounds.width)
        let squareRect = CGRect(x: (overlay.bounds.width - squareSideLength) / 2,
                                y: (overlay.bounds.height - squareSideLength) / 2,
                                width: squareSideLength,
                                height: squareSideLength)

        let path = UIBezierPath(rect: overlay.bounds)
        let rectPath = UIBezierPath(rect: squareRect)
        path.append(rectPath)
        path.usesEvenOddFillRule = true

        let fillLayer = CAShapeLayer()
        fillLayer.path = path.cgPath
        fillLayer.fillRule = .evenOdd
        fillLayer.fillColor = UIColor.black.withAlphaComponent(0.5).cgColor
        overlay.layer.addSublayer(fillLayer)

        let borderLayer = CAShapeLayer()
        borderLayer.path = rectPath.cgPath
        borderLayer.strokeColor = UIColor.white.cgColor
        borderLayer.lineWidth = 2.0
        borderLayer.fillColor = UIColor.clear.cgColor
        overlay.layer.addSublayer(borderLayer)

        return overlay
    }

    private func checkCameraAuthorization(completion: @escaping (Bool) -> Void) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            completion(true)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    completion(granted)
                }
            }
        case .denied, .restricted:
            completion(false)
        @unknown default:
            completion(false)
        }
    }

    private func setupCamera() {
        captureSession = AVCaptureSession()
        captureSession.beginConfiguration()

        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice),
              captureSession.canAddInput(videoDeviceInput) else {
            return
        }
        captureSession.addInput(videoDeviceInput)

        photoOutput = AVCapturePhotoOutput()
        guard captureSession.canAddOutput(photoOutput) else {
            return
        }
        captureSession.addOutput(photoOutput)
        captureSession.commitConfiguration()

        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = view.bounds
        view.layer.addSublayer(previewLayer)

        DispatchQueue.global(qos: .background).async {
            self.captureSession.startRunning()
        }
    }

    private func showSettingsAlert() {
        let alertController = UIAlertController(
            title: "カメラへのアクセスが許可されていません",
            message: "カメラの使用を許可するには、設定に移動してください。",
            preferredStyle: .alert
        )
        let settingsAction = UIAlertAction(title: "設定へ", style: .default) { _ in
            if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsUrl)
            }
        }
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel) { _ in
            self.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(settingsAction)
        alertController.addAction(cancelAction)
        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
        }
    }
}
