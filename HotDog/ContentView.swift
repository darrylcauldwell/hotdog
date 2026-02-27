import SwiftUI

struct ContentView: View {
    let demoMode: DemoMode

    @StateObject private var classifier = ImageClassifier()
    @State private var selectedImage: UIImage?
    @State private var showCamera = false
    @State private var showPhotoLibrary = false

    init(demoMode: DemoMode = .none) {
        self.demoMode = demoMode
    }

    private var cameraAvailable: Bool {
        UIImagePickerController.isSourceTypeAvailable(.camera)
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.yellow.opacity(0.3), Color.red.opacity(0.2)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 16) {
                Text("🌭 Hot Dog?")
                    .font(.system(size: 36, weight: .black, design: .rounded))

                if let image = selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(radius: 8)
                        .padding(.horizontal)
                } else {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.gray.opacity(0.2))
                        .overlay(
                            VStack(spacing: 12) {
                                Image(systemName: "photo.on.rectangle.angled")
                                    .font(.system(size: 50))
                                    .foregroundColor(.gray)
                                Text("Take or choose a photo")
                                    .foregroundColor(.gray)
                            }
                        )
                        .padding(.horizontal)
                }

                if classifier.isProcessing {
                    ProgressView("Analyzing...")
                }

                if let result = classifier.result {
                    ResultView(result: result)
                        .transition(.scale.combined(with: .opacity))
                }

                Spacer(minLength: 0)

                HStack(spacing: 16) {
                    Button {
                        showCamera = true
                    } label: {
                        Label("Camera", systemImage: "camera.fill")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.accentColor)
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .disabled(!cameraAvailable)

                    Button {
                        showPhotoLibrary = true
                    } label: {
                        Label("Photos", systemImage: "photo.fill")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.accentColor)
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .sheet(isPresented: $showCamera) {
            ImagePicker(image: $selectedImage, sourceType: .camera)
                .ignoresSafeArea()
        }
        .sheet(isPresented: $showPhotoLibrary) {
            ImagePicker(image: $selectedImage, sourceType: .photoLibrary)
                .ignoresSafeArea()
        }
        .onChange(of: selectedImage) { newImage in
            guard demoMode == .none, let newImage else { return }
            classifier.classify(image: newImage)
        }
        .onAppear {
            loadDemoContent()
        }
    }

    private func loadDemoContent() {
        switch demoMode {
        case .none, .empty:
            break
        case .hotdog:
            if let image = UIImage(named: "DemoHotdog") {
                selectedImage = image
                classifier.result = .hotdog(confidence: 0.95)
            }
        case .notHotdog:
            if let image = UIImage(named: "DemoNotHotdog") {
                selectedImage = image
                classifier.result = .notHotdog(topLabel: "pizza", confidence: 0.88)
            }
        }
    }
}
