import AVFoundation
import Combine
import UIKit

/**
 A protocol defining the interface for a camera session service.

 This protocol provides methods and publishers for managing a camera session, capturing images, toggling flash, and handling camera access.

 Conforming types should implement the required methods and provide publishers for accessing camera session-related information.
 */
public protocol CameraSessionServiceProtocol {
    
    /// A publisher emitting the current AVCaptureSession.
    var cameraSessionPublisher: AnyPublisher<AVCaptureSession, Never> { get }

    /// A publisher emitting the current flash mode state.
    var isFlashEnabledPublisher: AnyPublisher<Bool, Never> { get }

    /// A publisher emitting the current session setup result.
    var sessionSetupResultPublisher: AnyPublisher<CameraSessionService.SessionSetupResult, Never> { get }

    /// A publisher emitting the current camera configuration result.
    var configurationResultPublisher: AnyPublisher<CameraSessionService.SessionConfigurationResult, Never> { get }

    /// A publisher emitting captured images or errors during image capture.
    var photoOutputPublisher: AnyPublisher<ImageOutput, CameraSessionError> { get }

    /// A publisher emitting captured video .
    var videoOutputPublisher: AnyPublisher<CMSampleBuffer, Never> { get }

    /// A publisher emitting the current camera access status.
    var cameraAccessPublisher: AnyPublisher<Bool, Never> { get }

    /**
     Sets up the camera session and checks for camera access authorization.

     This method should be called before using the camera service to ensure that the session is properly configured and camera access is granted.
     */
    func setUpSession()

    /**
     Captures an image using the current camera settings.

     This method captures an image using the current camera settings and publishes the result or error via the `imageOutputPublisher`.
     */
    func captureImage()

    /**
     Presents an image picker to select an image from the photo library.

     - Parameter from: The view controller from which to present the image picker.
     */
    func selectImageFromLibrary(from: UIViewController)

    /**
     Toggles the flash mode of the camera.

     This method toggles the flash mode between on and off.
     */
    func toggleFlash()

    /**
     Configures the output options for the capture session.

     - Parameters:
     - addPhotoOutput: A boolean value indicating whether to add a photo output to the capture session.
     - addVideoOutput: A boolean value indicating whether to add a video output to the capture session.

     Use this function to customise the output configuration of a capture session. Set `addPhotoOutput` to `true` if you want to include photo capture capabilities in the session, and set `addVideoOutput` to `true` if you want to include video capture capabilities. You can selectively enable or disable these options based on your application's requirements.

     Example usage:
     ```swift
     configureOutput(addPhotoOutput: true, addVideoOutput: true)
     */
    func configureOutput(addPhotoOutput: Bool, addVideoOutput: Bool)
}


public class CameraSessionService {

    /**
     An enumeration representing the possible results of setting up a camera session.

     - `success`: The camera session setup was successful.
     - `notAuthorized`: The user has not authorized access to the camera.
     - `configurationFailed`: The configuration of the camera session failed.

     Use this enumeration to check the result of the camera session setup and handle different scenarios accordingly.
     */
    public enum SessionSetupResult {
        /// The camera session setup was successful.
        case success

        /// The user has not authorized access to the camera.
        case notAuthorized

        /// The configuration of the camera session failed.
        case configurationFailed
    }

    /**
     Enum representing various session configuration request types for managing video and photo capture sessions.

     - `defaultVideoDeviceIsUnavailable`: Indicates that the default video device is unavailable for use.
     - `cantAddVideoDeviceToTheSession`: Indicates that a video device cannot be added to the capture session.
     - `cantCreateVideoDeviceInput(Error)`: Indicates that a video device input cannot be created, along with an associated error.
     - `cantAddPhotoOutput`: Indicates that a photo output cannot be added to the capture session.
     - `cantAddVideoOutput`: Indicates that a video output cannot be added to the capture session.

     Use these cases to handle different configuration request scenarios when working with AVCaptureSession or similar frameworks for audio and video capture in your iOS or macOS application.
     */
    public enum SessionConfigurationResult {
        case defaultVideoDeviceIsUnavailable
        case cantAddVideoDeviceToTheSession
        case cantCreateVideoDeviceInput(Error)
        case cantAddPhotoOutput
        case cantAddVideoOutput
        case sessionConfigured
    }

    // MARK: - Private properties

    public var addPhotoOutput = false
    public var addVideoOutput = false
    private let sessionQueue = DispatchQueue(label: "camera_queue")
    private let photoOutput = AVCapturePhotoOutput()
    private let videoOutput = AVCaptureVideoDataOutput()
    private var videoDeviceInput: AVCaptureDeviceInput?
    private var cameraAccessSubject: PassthroughSubject<Bool, Never> = PassthroughSubject()
    private var cameraConfigurationSubject: PassthroughSubject<SessionConfigurationResult, Never> = PassthroughSubject()

    @Published private var session = AVCaptureSession()
    @Published private var isFlashEnabled = false
    @Published private var setupResult: SessionSetupResult?

    // MARK: - Private use cases

    private let photoCaptureUseCase: PhotoCaptureUseCaseProtocol = PhotoCaptureUseCase()
    private let pickPhotoFromLibraryUseCase: PickPhotoFromLibraryUseCaseProtocol = PickPhotoFromLibraryUseCase()
    private let videoCaptureUseCase: VideoCaptureUseCaseProtocol = VideoCaptureUseCase()

    private var flashMode: AVCaptureDevice.FlashMode {
        (captureDevice?.hasFlash == true && isFlashEnabled) ? .on : .off
    }

    private var capturePhotoSettings: AVCapturePhotoSettings {
        let settings = AVCapturePhotoSettings()
        settings.flashMode = flashMode
        return settings
    }

    private var captureDevice: AVCaptureDevice? {
        if let dualCameraDevice = AVCaptureDevice.default(.builtInDualCamera, for: .video, position: .back) {
            dualCameraDevice
        } else if let backCameraDevice = AVCaptureDevice.default(
            .builtInWideAngleCamera,
            for: .video,
            position: .back
        ) {
            backCameraDevice
        } else if let frontCameraDevice = AVCaptureDevice.default(
            .builtInWideAngleCamera,
            for: .video,
            position: .front
        ) {
            frontCameraDevice
        } else {
            nil
        }
    }

    public init() { }
}

extension CameraSessionService: CameraSessionServiceProtocol {

    public var configurationResultPublisher: AnyPublisher<SessionConfigurationResult, Never> {
        cameraConfigurationSubject.eraseToAnyPublisher()
    }

    public var isFlashEnabledPublisher: AnyPublisher<Bool, Never> {
        $isFlashEnabled.eraseToAnyPublisher()
    }
    
    public var photoOutputPublisher: AnyPublisher<ImageOutput, CameraSessionError> {
        Publishers.Merge(
            photoCaptureUseCase.photoCapturedPublisher,
            pickPhotoFromLibraryUseCase.pickPhotoPublisher
        )
        .eraseToAnyPublisher()
    }

    public var videoOutputPublisher: AnyPublisher<CMSampleBuffer, Never> {
        videoCaptureUseCase.sampleBufferPublisher
    }

    public var cameraSessionPublisher: AnyPublisher<AVCaptureSession, Never> {
        $session.eraseToAnyPublisher()
    }

    public var cameraAccessPublisher: AnyPublisher<Bool, Never> {
        cameraAccessSubject.eraseToAnyPublisher()
    }

    public func toggleFlash() {
        isFlashEnabled.toggle()
    }

    public var sessionSetupResultPublisher: AnyPublisher<SessionSetupResult, Never> {
        $setupResult
            .compactMap { $0 }
            .eraseToAnyPublisher()
    }
    
    public func setUpSession() {
        handleAuthorizationStatus { setupResult in
            self.setupResult = setupResult
        }

        sessionQueue.async { [weak self] in
            self?.configureSession()
        }

        if session.isRunning { return }
        sessionQueue.async { [weak self] in
            guard let self else { return }
            session.startRunning()
        }
    }

    public func captureImage() {
        sessionQueue.async { [weak self] in
            guard let self else { return }
            if photoOutput.connections.isEmpty { return }
            photoOutput.capturePhoto(
                with: capturePhotoSettings,
                delegate: photoCaptureUseCase
            )
        }
    }

    public func selectImageFromLibrary(from viewController: UIViewController) {
        pickPhotoFromLibraryUseCase.pickImageFromLibrary(from: viewController)
    }

    public func configureOutput(addPhotoOutput: Bool, addVideoOutput: Bool) {
        self.addPhotoOutput = addPhotoOutput
        self.addVideoOutput = addVideoOutput
    }
}

private extension CameraSessionService {

    private func requestCameraAccess(completion: @escaping (SessionSetupResult) -> Void) {
        sessionQueue.suspend()
        AVCaptureDevice.requestAccess(for: .video, completionHandler: { [weak self] granted in
            guard let self else { return }
            cameraAccessSubject.send(granted)
            completion(granted ? .success : .notAuthorized)
            sessionQueue.resume()
        })
    }

    private func handleAuthorizationStatus(completion: @escaping (SessionSetupResult) -> Void) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            completion(.success)

        case .notDetermined:
            requestCameraAccess(completion: completion)

        case .restricted,
                .denied:
            completion(.notAuthorized)

        @unknown default:
            completion(.notAuthorized)
        }
    }

    private func configureSession() {
        if setupResult != .success { return }
        session.beginConfiguration()
        session.sessionPreset = .photo

        do {
            guard let videoDevice = captureDevice else {
                cameraConfigurationSubject.send(.defaultVideoDeviceIsUnavailable)
                setupResult = .configurationFailed
                session.commitConfiguration()
                return
            }
            let videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)

            if session.canAddInput(videoDeviceInput) {
                session.addInput(videoDeviceInput)
                self.videoDeviceInput = videoDeviceInput

            } else {
                cameraConfigurationSubject.send(.cantAddVideoDeviceToTheSession)
                setupResult = .configurationFailed
                session.commitConfiguration()
                return
            }
        } catch {
            cameraConfigurationSubject.send(.cantCreateVideoDeviceInput(error))
            setupResult = .configurationFailed
            session.commitConfiguration()
            return
        }

        if addPhotoOutput {
            if session.canAddOutput(photoOutput) {
                session.addOutput(photoOutput)
                photoOutput.isHighResolutionCaptureEnabled = true
                photoOutput.isLivePhotoCaptureEnabled = false
            } else {
                cameraConfigurationSubject.send(.cantAddPhotoOutput)
                setupResult = .configurationFailed
                session.commitConfiguration()
                return
            }
        }

        if addVideoOutput {
            if session.canAddOutput(videoOutput) {
                videoOutput.setSampleBufferDelegate(
                    videoCaptureUseCase,
                    queue: DispatchQueue.global(qos: .userInitiated)
                )

                session.addOutput(videoOutput)
            } else {
                cameraConfigurationSubject.send(.cantAddVideoOutput)
                setupResult = .configurationFailed
                session.commitConfiguration()
                return
            }
        }

        cameraConfigurationSubject.send(.sessionConfigured)
        session.commitConfiguration()
    }
}
