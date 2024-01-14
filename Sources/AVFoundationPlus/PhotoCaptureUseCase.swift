import AVFoundation
import Combine
import UIKit

/**
 A protocol defining the interface for a photo capture use case.

 Conforming types should implement this protocol to handle AVCapturePhoto capture events and provide a publisher for photo capture results.

 - Note: This protocol inherits from `AVCapturePhotoCaptureDelegate` to handle photo capture events.

 Example usage:
 ```swift
 class MyPhotoCaptureUseCase: NSObject, PhotoCaptureUseCaseProtocol {
     // Implement the required methods and properties here.
 }
SeeAlso: AVCapturePhotoCaptureDelegate, ImageOutput, CameraSessionError
*/

protocol PhotoCaptureUseCaseProtocol: AVCapturePhotoCaptureDelegate {

    /**
    A publisher that emits ImageOutput or CameraSessionError upon capturing a photo.

    Returns: A publisher for photo capture results.
    */
    var photoCapturedPublisher: AnyPublisher<ImageOutput, CameraSessionError> { get }
}

class PhotoCaptureUseCase: NSObject, AVCapturePhotoCaptureDelegate {

    private let photoCapturedSubject: PassthroughSubject<ImageOutput, CameraSessionError> = PassthroughSubject()
}

extension PhotoCaptureUseCase: PhotoCaptureUseCaseProtocol {
    var photoCapturedPublisher: AnyPublisher<ImageOutput, CameraSessionError> {
        photoCapturedSubject
            .eraseToAnyPublisher()
    }

    func photoOutput(
        _ output: AVCapturePhotoOutput,
        didFinishProcessingPhoto photo: AVCapturePhoto,
        error: Error?
    ) {
        if let error {
            photoCapturedSubject.send(
                completion: .failure(CameraSessionError.system(error))
            )
            return
        }

        guard
            let imageData = photo.fileDataRepresentation(),
            let image = UIImage(data: imageData, scale: 1.0)
        else {
            photoCapturedSubject.send(
                completion: .failure(CameraSessionError.cantConvertImage)
            )
            return
        }

        photoCapturedSubject.send(ImageOutput(image: image, source: .camera))
    }
}
