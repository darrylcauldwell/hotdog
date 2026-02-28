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
            AppColors.cardBackground
                .ignoresSafeArea()

            VStack(spacing: Spacing.lg) {
                // Header
                VStack(spacing: Spacing.xs) {
                    Text("SeeFood")
                        .font(.largeTitle.bold())
                        .foregroundStyle(AppColors.primary)
                    Text("Shazam, But For Food")
                        .font(.subheadline)
                        .foregroundStyle(AppColors.neutralGray)
                }
                .padding(.top, Spacing.sm)

                // Image area
                Group {
                    if let image = selectedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.xl, style: .continuous))
                    } else {
                        RoundedRectangle(cornerRadius: CornerRadius.xl, style: .continuous)
                            .fill(AppColors.elevatedSurface)
                            .overlay(
                                VStack(spacing: Spacing.md) {
                                    Image(systemName: "fork.knife.circle")
                                        .font(.system(size: 50))
                                        .foregroundStyle(AppColors.primary.opacity(0.4))
                                    Text("Take or choose a photo")
                                        .font(.subheadline)
                                        .foregroundStyle(AppColors.neutralGray)
                                }
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: CornerRadius.xl, style: .continuous)
                                    .stroke(AppColors.primary.opacity(0.1), lineWidth: BorderWidth.subtle)
                            )
                    }
                }
                .standardShadow(Shadow.glass)
                .padding(.horizontal)

                // Result
                if classifier.isProcessing {
                    ProgressView("Analyzing...")
                        .foregroundStyle(AppColors.primary)
                }

                if let result = classifier.result {
                    ResultView(result: result)
                        .transition(.scale.combined(with: .opacity))
                }

                Spacer(minLength: 0)

                // Action buttons
                HStack(spacing: Spacing.lg) {
                    Button {
                        showCamera = true
                    } label: {
                        Label("Camera", systemImage: "camera.fill")
                            .font(.headline)
                            .foregroundStyle(AppColors.primary)
                    }
                    .buttonStyle(GlassButtonStyle())
                    .disabled(!cameraAvailable)

                    Button {
                        showPhotoLibrary = true
                    } label: {
                        Label("Photos", systemImage: "photo.fill")
                            .font(.headline)
                            .foregroundStyle(AppColors.primary)
                    }
                    .buttonStyle(GlassButtonStyle())
                }
                .padding(.horizontal)
                .padding(.bottom, Spacing.sm)
            }
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
