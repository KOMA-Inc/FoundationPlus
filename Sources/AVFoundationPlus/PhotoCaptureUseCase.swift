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

    private let sessionQueue = DispatchQueue(label: "capture_photo_queue")
    private var photoCapturedSubject: PassthroughSubject<UIImage, CameraSessionError>?

    /**
    A publisher that emits ImageOutput or CameraSessionError upon capturing a photo.

    Returns: A publisher for photo capture results.
    */

    func capturePhoto(with output: AVCapturePhotoOutput, and settings: AVCapturePhotoSettings) -> AnyPublisher<UIImage, CameraSessionError> {
        photoCapturedSubject = PassthroughSubject()

        sessionQueue.async { [weak self] in
            guard let self else { return }
            if output.connections.isEmpty {
                return
            }
            output.capturePhoto(
                with: settings,
                delegate: self
            )
        }

        return photoCapturedSubject?.eraseToAnyPublisher() ?? Fail(outputType: UIImage.self, failure: .cantConvertImage).eraseToAnyPublisher()
    }

    func photoOutput(
        _ output: AVCapturePhotoOutput,
        didFinishProcessingPhoto photo: AVCapturePhoto,
        error: Error?
    ) {
        if let error {
            photoCapturedSubject?.send(
                completion: .failure(CameraSessionError.system(error))
            )
            return
        }

        guard
            let imageData = photo.fileDataRepresentation(),
            let image = UIImage(data: imageData, scale: 1.0)
        else {
            photoCapturedSubject?.send(
                completion: .failure(CameraSessionError.cantConvertImage)
            )
            return
        }

        photoCapturedSubject?.send(image)
    }
}
