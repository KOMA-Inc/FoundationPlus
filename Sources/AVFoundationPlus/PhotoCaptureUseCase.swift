import AVFoundation
import Combine
import UIKit

/**
 A class defining the interface for a photo capture use case.


 - Note: This class inherits from `AVCapturePhotoCaptureDelegate` to handle photo capture events.

 Example usage:
 ```swift
 var myPhotoCaptureUseCase: PhotoCaptureUseCase()
 myPickPhotoUseCase
    .photoCapturedPublisher
    .sink {
        ...
    }
    .store(in: &cancellable)

SeeAlso: AVCapturePhotoCaptureDelegate, ImageOutput, CameraSessionError
*/
class PhotoCaptureUseCase: NSObject, AVCapturePhotoCaptureDelegate {

    private let photoCapturedSubject: PassthroughSubject<ImageOutput, CameraSessionError> = PassthroughSubject()
}

extension PhotoCaptureUseCase {

    /**
    A publisher that emits ImageOutput or CameraSessionError upon capturing a photo.

    Returns: A publisher for photo capture results.
    */
    public var photoCapturedPublisher: AnyPublisher<ImageOutput, CameraSessionError> {
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
