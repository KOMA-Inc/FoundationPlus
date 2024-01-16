import Foundation

/**
 An enumeration representing errors that can occur in a camera session.

 The `CameraSessionError` enum defines different error cases that can arise during camera session operations. It conforms to the `LocalizedError` protocol to provide localized error descriptions.

 Example usage:
 ```swift
 do {
 // Perform camera session operation
 } catch let error as CameraSessionError {
 // Handle specific camera session error cases
 } catch {
 // Handle other system errors
 }
 SeeAlso: LocalizedError
 */
public enum CameraSessionError: LocalizedError {
    /*
     An error indicating that an image couldn't be converted to the expected format.

     This error typically occurs when attempting to convert captured image data into a usable format.

     Example usage:
     throw CameraSessionError.cantConvertImage
     Note: This error should be handled when dealing with image conversion failures.
     */
    case cantConvertImage

    /**
     An error indicating a system-related error that is not specific to the camera session.

     This case is used to wrap other system errors and provide a more generic error type.

     Parameter error: The system error that caused this error case.
     */
    case system(Error)

    /**
     An error indicating a flow when user closed the photo picker without selecting an image.
     */
    case didCancelPickingImage

    /**
     Initializes a CameraSessionError instance from an existing error.

     This initializer allows converting other error types into CameraSessionError.system for uniform error handling.

     Parameter error: The error to be converted into a CameraSessionError.
     */
    public init(from error: Error) {
        self = (error as? CameraSessionError) ?? .system(error)
    }

    /**
     A localized description of the error.

     This computed property provides a human-readable description of the error in the user's preferred language.

     Returns: A localized description of the error.
     */
    public var errorDescription: String? {
        switch self {
        case .cantConvertImage:
            return NSLocalizedString("Unable to convert the captured image.", comment: "")
        case .system(let error):
            return error.localizedDescription
        case .didCancelPickingImage:
            return "Image Picker closed"
        }
    }
}

