import AVFoundation
import Combine
import UIKit

/**
 A class defining the interface for picking photos from the device's photo library.

 Example usage:
 ```swift
 var myPickPhotoUseCase: PickPhotoFromLibraryUseCase()
 myPickPhotoUseCase
    .pickPhotoPublisher
    .sink {
        ...
    }
    .store(in: &cancellable)

 SeeAlso: ImageOutput, CameraSessionError
 */
class PickPhotoFromLibraryUseCase: NSObject {

    private lazy var picker = UIImagePickerController()
    private let pickPhotoSubject: PassthroughSubject<ImageOutput, CameraSessionError> = PassthroughSubject()

    var pickPhotoPublisher: AnyPublisher<ImageOutput, CameraSessionError> {
        pickPhotoSubject.eraseToAnyPublisher()
    }

    override init() {
        super.init()
        picker.delegate = self
        picker.sourceType = .photoLibrary
    }

    func pickImageFromLibrary(from sourceViewController: UIViewController) {
        sourceViewController.present(picker, animated: true)
    }
}

extension PickPhotoFromLibraryUseCase: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
        if let image = info[.originalImage] as? UIImage {
            pickPhotoSubject.send(ImageOutput(image: image, source: .gallery))
        } else {
            pickPhotoSubject.send(completion: .failure(.cantConvertImage))
        }

        picker.dismiss(animated: true)
    }
}
