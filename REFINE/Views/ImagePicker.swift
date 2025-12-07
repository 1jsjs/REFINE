import SwiftUI
import PhotosUI

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImages: [Data]
    let maxSelection: Int
    @Environment(\.presentationMode) var presentationMode

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration(photoLibrary: .shared())
        config.filter = .images
        config.selectionLimit = maxSelection
        config.preferredAssetRepresentationMode = .current

        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            parent.presentationMode.wrappedValue.dismiss()

            guard !results.isEmpty else { return }

            var images: [Data] = []
            let group = DispatchGroup()

            for result in results {
                group.enter()
                result.itemProvider.loadObject(ofClass: UIImage.self) { (object, error) in
                    defer { group.leave() }

                    if let error = error {
                        print("Error loading image: \(error)")
                        return
                    }

                    if let image = object as? UIImage,
                       let data = image.jpegData(compressionQuality: 0.8) {
                        images.append(data)
                    }
                }
            }

            group.notify(queue: .main) {
                self.parent.selectedImages = images
            }
        }
    }
}
