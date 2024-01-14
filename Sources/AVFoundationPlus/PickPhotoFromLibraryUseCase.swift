import AVFoundation
import Combine
import UIKit

/**
 A protocol defining the interface for picking photos from the device's photo library.

 Conforming types should implement this protocol to provide the ability to pick photos from the device's photo library and publish the selected photos or errors.

 Example usage:
 ```swift
 class MyPickPhotoUseCase: PickPhotoFromLibraryUseCaseProtocol {
 // Implement the required methods and properties here.
 }
 SeeAlso: ImageOutput, CameraSessionError
 */

protocol PickPhotoFromLibraryUseCaseProtocol {

    /// A publisher that emits ImageOutput or CameraSessionError upon picking a photo from the library.
    var pickPhotoPublisher: AnyPublisher<ImageOutput, CameraSessionError> { get }

    /**
    Picks an image from the device's photo library.

    Parameter sourceViewController: The view controller from which the photo library picker is presented.
    */
    func pickImageFromLibrary(
        from sourceViewController: UIViewController
    )
}

class PickPhotoFromLibraryUseCase: NSObject, PickPhotoFromLibraryUseCaseProtocol {

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
