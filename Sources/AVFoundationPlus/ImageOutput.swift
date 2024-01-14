import UIKit

/**
 A struct representing an output image along with its source.

 The `ImageOutput` struct is used to encapsulate an image and specify its source, whether it was captured from the camera or selected from the photo gallery.

 Example usage:
 ```swift
 let cameraImage = ImageOutput(image: capturedImage, source: .camera)
 let galleryImage = ImageOutput(image: selectedImage, source: .gallery)
SeeAlso: UIImage, PhotoCaptureUseCaseProtocol, PickPhotoFromLibraryUseCaseProtocol
*/

public struct ImageOutput {
    /*
     An enumeration representing the source of the image.

     camera: The image was captured using the device's camera.

     gallery: The image was selected from the device's photo gallery.
     */
    public enum ImageSource {
        /// The image was captured using the device's camera.
        case camera

        /// The image was selected from the device's photo gallery.
        case gallery
    }

    /// The captured or selected image.
    public let image: UIImage

    /// The source of the image, indicating whether it came from the camera or gallery.
    public let source: ImageSource
}
