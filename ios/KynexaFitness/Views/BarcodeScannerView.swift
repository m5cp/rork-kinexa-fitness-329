import SwiftUI
import AVFoundation
import Vision

struct BarcodeScannerView: View {
    @Environment(\.dismiss) private var dismiss
    let onScan: (String) -> Void

    @State private var scannedCode: String?
    @State private var isScanning: Bool = true

    var body: some View {
        ZStack {
            #if targetEnvironment(simulator)
            simulatorFallback
            #else
            if AVCaptureDevice.default(for: .video) != nil {
                BarcodeScannerCaptureView(
                    onCodeScanned: { code in
                        guard isScanning else { return }
                        isScanning = false
                        scannedCode = code
                        onScan(code)
                        dismiss()
                    }
                )
                .ignoresSafeArea()

                scannerOverlay
            } else {
                simulatorFallback
            }
            #endif
        }
        .statusBarHidden()
    }

    private var scannerOverlay: some View {
        ZStack {
            VStack {
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
                }
                .padding(.horizontal, 20)
                .padding(.top, 60)

                Spacer()

                VStack(spacing: 12) {
                    Image(systemName: "barcode.viewfinder")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(.white)
                        .symbolEffect(.pulse, options: .repeating.speed(0.5))

                    Text("Point at a barcode")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(.white)

                    Text("We'll look up the nutrition info automatically")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.7))
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
                .background(.ultraThinMaterial)
                .clipShape(.rect(cornerRadius: 16))

                Spacer()

                RoundedRectangle(cornerRadius: 4)
                    .stroke(.white, style: StrokeStyle(lineWidth: 3, dash: [20, 10]))
                    .frame(width: 280, height: 160)
                    .shadow(color: Color(hex: "#22C55E").opacity(0.5), radius: 10)

                Spacer()
                Spacer()
            }
        }
    }

    private var simulatorFallback: some View {
        VStack(spacing: 20) {
            Image(systemName: "barcode.viewfinder")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text("Barcode Scanner")
                .font(.title2.weight(.semibold))
            Text("Install this app on your device\nvia the Rork App to scan barcodes.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Button("Go Back") { dismiss() }
                .font(.headline)
                .padding(.top, 8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }
}

struct BarcodeScannerCaptureView: UIViewControllerRepresentable {
    let onCodeScanned: (String) -> Void

    func makeUIViewController(context: Context) -> BarcodeScannerController {
        let vc = BarcodeScannerController()
        vc.onCodeScanned = onCodeScanned
        return vc
    }

    func updateUIViewController(_ uiViewController: BarcodeScannerController, context: Context) {}
}

class BarcodeScannerController: UIViewController {
    var onCodeScanned: ((String) -> Void)?

    private let captureSession = AVCaptureSession()
    private let metadataOutput = AVCaptureMetadataOutput()
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private let sessionQueue = DispatchQueue(label: "barcodeSession")

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupCamera()
    }

    private func setupCamera() {
        sessionQueue.async { [weak self] in
            guard let self else { return }
            captureSession.beginConfiguration()

            guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
                  let input = try? AVCaptureDeviceInput(device: camera),
                  captureSession.canAddInput(input) else {
                captureSession.commitConfiguration()
                return
            }
            captureSession.addInput(input)

            if captureSession.canAddOutput(metadataOutput) {
                captureSession.addOutput(metadataOutput)
                metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
                metadataOutput.metadataObjectTypes = [.ean8, .ean13, .upce, .code128, .code39, .code93, .qr]
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

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = view.bounds
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sessionQueue.async { [weak self] in
            self?.captureSession.stopRunning()
        }
    }
}

extension BarcodeScannerController: AVCaptureMetadataOutputObjectsDelegate {
    nonisolated func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard let object = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
              let code = object.stringValue else { return }
        Task { @MainActor in
            onCodeScanned?(code)
        }
    }
}
