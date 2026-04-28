import SwiftUI
import AVFoundation

struct FoodCameraView: View {
    @Environment(\.dismiss) private var dismiss
    let onCapture: (Data) -> Void

    @State private var capturedImageData: Data?
    @State private var showConfirm: Bool = false

    var body: some View {
        ZStack {
            #if targetEnvironment(simulator)
            CameraUnavailablePlaceholder(onDismiss: { dismiss() })
            #else
            if AVCaptureDevice.default(for: .video) != nil {
                FoodCameraCaptureView(
                    onCapture: { data in
                        capturedImageData = data
                        showConfirm = true
                    }
                )
                .ignoresSafeArea()
                .overlay(alignment: .top) {
                    cameraOverlayTop
                }
                .overlay(alignment: .bottom) {
                    cameraOverlayBottom
                }
            } else {
                CameraUnavailablePlaceholder(onDismiss: { dismiss() })
            }
            #endif

            if showConfirm, let data = capturedImageData {
                foodPreviewOverlay(data)
            }
        }
        .statusBarHidden()
    }

    private var cameraOverlayTop: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(.white)
                    .frame(width: 40, height: 40)
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
            }
            Spacer()
            VStack(spacing: 4) {
                Image(systemName: "fork.knife")
                    .font(.caption.weight(.bold))
                Text("Point at food")
                    .font(.caption2.weight(.semibold))
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(.ultraThinMaterial)
            .clipShape(Capsule())
            Spacer()
            Color.clear.frame(width: 40, height: 40)
        }
        .padding(.horizontal, 20)
        .padding(.top, 60)
    }

    private var cameraOverlayBottom: some View {
        Color.clear.frame(height: 1)
    }

    private func foodPreviewOverlay(_ data: Data) -> some View {
        ZStack {
            Color.black.opacity(0.85).ignoresSafeArea()

            VStack(spacing: 24) {
                if let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxHeight: 400)
                        .clipShape(.rect(cornerRadius: 20))
                        .shadow(color: .black.opacity(0.5), radius: 20)
                }

                HStack(spacing: 16) {
                    Button {
                        showConfirm = false
                        capturedImageData = nil
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "arrow.counterclockwise")
                            Text("Retake")
                        }
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(.ultraThinMaterial)
                        .clipShape(.rect(cornerRadius: 14))
                    }

                    Button {
                        onCapture(data)
                        dismiss()
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "sparkles")
                            Text("Analyze Food")
                        }
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(
                            LinearGradient(
                                colors: [Color(hex: "#22C55E"), Color(hex: "#16A34A")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(.rect(cornerRadius: 14))
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
}

struct CameraUnavailablePlaceholder: View {
    var onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "camera.fill")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text("Camera Preview")
                .font(.title2)
                .fontWeight(.semibold)
            Text("Install this app on your device\nvia the Rork App to use the camera.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Button("Go Back") { onDismiss() }
                .font(.headline)
                .padding(.top, 8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }
}

struct FoodCameraCaptureView: UIViewControllerRepresentable {
    let onCapture: (Data) -> Void

    func makeUIViewController(context: Context) -> FoodCameraCaptureController {
        let vc = FoodCameraCaptureController()
        vc.onCapture = onCapture
        return vc
    }

    func updateUIViewController(_ uiViewController: FoodCameraCaptureController, context: Context) {}
}

class FoodCameraCaptureController: UIViewController {
    var onCapture: ((Data) -> Void)?

    private let captureSession = AVCaptureSession()
    private let photoOutput = AVCapturePhotoOutput()
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private let sessionQueue = DispatchQueue(label: "foodCameraSession")

    private lazy var shutterButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.translatesAutoresizingMaskIntoConstraints = false
        let config = UIImage.SymbolConfiguration(pointSize: 70, weight: .light)
        btn.setImage(UIImage(systemName: "circle.inset.filled", withConfiguration: config), for: .normal)
        btn.tintColor = .white
        btn.addTarget(self, action: #selector(capturePhoto), for: .touchUpInside)
        return btn
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupCamera()
        setupUI()
    }

    private func setupCamera() {
        sessionQueue.async { [weak self] in
            guard let self else { return }
            captureSession.beginConfiguration()
            captureSession.sessionPreset = .photo

            guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
                  let input = try? AVCaptureDeviceInput(device: camera),
                  captureSession.canAddInput(input) else {
                captureSession.commitConfiguration()
                return
            }
            captureSession.addInput(input)

            if captureSession.canAddOutput(photoOutput) {
                captureSession.addOutput(photoOutput)
            }

            captureSession.commitConfiguration()
            captureSession.startRunning()

            DispatchQueue.main.async {
                let layer = AVCaptureVideoPreviewLayer(session: self.captureSession)
                layer.videoGravity = .resizeAspectFill
                layer.frame = self.view.bounds
                self.view.layer.insertSublayer(layer, at: 0)
                self.previewLayer = layer
            }
        }
    }

    private func setupUI() {
        view.addSubview(shutterButton)
        NSLayoutConstraint.activate([
            shutterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            shutterButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            shutterButton.widthAnchor.constraint(equalToConstant: 80),
            shutterButton.heightAnchor.constraint(equalToConstant: 80)
        ])
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = view.bounds
    }

    @objc private func capturePhoto() {
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sessionQueue.async { [weak self] in
            self?.captureSession.stopRunning()
        }
    }
}

extension FoodCameraCaptureController: AVCapturePhotoCaptureDelegate {
    nonisolated func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let data = photo.fileDataRepresentation() else { return }
        let compressed = UIImage(data: data)?
            .jpegData(compressionQuality: 0.7)
        Task { @MainActor in
            onCapture?(compressed ?? data)
        }
    }
}
