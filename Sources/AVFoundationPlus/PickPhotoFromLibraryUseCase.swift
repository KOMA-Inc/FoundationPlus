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
    private var pickPhotoSubject: PassthroughSubject<UIImage, CameraSessionError>?

    override init() {
        super.init()
        picker.delegate = self
        picker.sourceType = .photoLibrary
    }

    func pickImageFromLibrary(
        from sourceViewController: UIViewController
    ) -> AnyPublisher<UIImage, CameraSessionError> {
        pickPhotoSubject = PassthroughSubject()
        sourceViewController.present(picker, animated: true)
        return pickPhotoSubject?.eraseToAnyPublisher() ?? Fail(outputType: UIImage.self, failure: .cantConvertImage).eraseToAnyPublisher()
    }
}

extension PickPhotoFromLibraryUseCase: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
        if let image = info[.originalImage] as? UIImage {
            pickPhotoSubject?.send(image)
        } else {
            pickPhotoSubject?.send(completion: .failure(.cantConvertImage))
        }

        picker.dismiss(animated: true)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
        pickPhotoSubject?.send(completion: .failure(.didCancelPickingImage))
    }
}
