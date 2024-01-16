import AVFoundation
import Combine
import UIKit

/**
 A class defining the camera session service.

 This class provides methods and publishers for managing a camera session, capturing images, toggling flash, and handling camera access.
 */
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
        case inputSessionConfigured
        case photoOutputSessionConfigured
        case videoOutputSessionConfigured
    }

    // MARK: - Public properties

    public var isPhotoOutputAvailable = false
    public var isVideoOutputAvailable = false
    public var accessRequested = false

    public let session = AVCaptureSession()
    public var flashMode: AVCaptureDevice.FlashMode = .off

    // MARK: - Private properties

    private let sessionQueue = DispatchQueue(label: "camera_queue")
    private lazy var photoOutput = AVCapturePhotoOutput()
    private lazy var videoOutput = AVCaptureVideoDataOutput()
    private var videoDeviceInput: AVCaptureDeviceInput?
    private var cameraConfigurationSubject: PassthroughSubject<SessionConfigurationResult, Never> = PassthroughSubject()
    private var cameraSetupSubject: PassthroughSubject<Void, Never> = PassthroughSubject()

    @Published private var setupResult: SessionSetupResult?

    // MARK: - Private use cases

    private let photoCaptureUseCase = PhotoCaptureUseCase()
    private let pickPhotoFromLibraryUseCase = PickPhotoFromLibraryUseCase()
    private let videoCaptureUseCase = VideoCaptureUseCase()
    private let cameraAccessTracker: CameraAccessTrackerProtocol?

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

    public init(with cameraAccessTracker: CameraAccessTrackerProtocol? = nil) {
        self.cameraAccessTracker = cameraAccessTracker
    }
}

extension CameraSessionService {

    /// A publisher emitting the current camera configuration result.
    public var configurationResultPublisher: AnyPublisher<SessionConfigurationResult, Never> {
        cameraConfigurationSubject.eraseToAnyPublisher()
    }

    /// A publisher emitting captured video .
    public var videoOutputPublisher: AnyPublisher<CMSampleBuffer, Never> {
        videoCaptureUseCase.sampleBufferPublisher
    }

    /// A publisher emitting the current session setup result.
    public var sessionSetupResultPublisher: AnyPublisher<SessionSetupResult, Never> {
        $setupResult
            .compactMap { $0 }
            .eraseToAnyPublisher()
    }

    /// A Publisher that emits the finished state of camera setup process
    public var cameraSetupFinishedPublisher: AnyPublisher<Void, Never> {
        cameraSetupSubject.eraseToAnyPublisher()
    }

    /**
     Sets up the camera session and checks for camera access authorization.

     This method should be called before using the camera service to ensure that the session is properly configured and camera access is granted.
     */
    public func setupSession() {
        handleAuthorizationStatus { setupResult in
            self.setupResult = setupResult
        }

        sessionQueue.async { [weak self] in
            guard let self else { return }
            configureSession()
            if isPhotoOutputAvailable {
                addPhotoOutput()
            }
            if isVideoOutputAvailable {
                addVideoOutput()
            }
        }

        if session.isRunning { return }
        sessionQueue.async { [weak self] in
            guard let self else { return }
            session.startRunning()
            cameraSetupSubject.send(())
        }
    }

    /**
     Captures an image using the current camera settings.

     This method captures an image using the current camera settings and publishes the result or error via the `imageOutputPublisher`.
     */
    public func captureImage() -> AnyPublisher<UIImage, CameraSessionError> {
        photoCaptureUseCase.capturePhoto(with: photoOutput, and: capturePhotoSettings)
    }

    /**
     Presents an image picker to select an image from the photo library.

     - Parameter from: The view controller from which to present the image picker.
     */
    public func selectImageFromLibrary(
        from viewController: UIViewController
    ) -> AnyPublisher<UIImage, CameraSessionError> {
        pickPhotoFromLibraryUseCase.pickImageFromLibrary(from: viewController)
    }
}

private extension CameraSessionService {

    func requestCameraAccess(completion: @escaping (SessionSetupResult) -> Void) {
        sessionQueue.suspend()
        AVCaptureDevice.requestAccess(for: .video, completionHandler: { [weak self] granted in
            guard let self else { return }
            accessRequested = true
            completion(granted ? .success : .notAuthorized)
            cameraAccessTracker?.track(cameraAccessStatus: granted)
            sessionQueue.resume()
        })
    }

    func handleAuthorizationStatus(completion: @escaping (SessionSetupResult) -> Void) {
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

    func addPhotoOutput() {
        if session.canAddOutput(photoOutput) {
            photoOutput.isHighResolutionCaptureEnabled = true
            photoOutput.isLivePhotoCaptureEnabled = false
            session.addOutput(photoOutput)
            cameraConfigurationSubject.send(.photoOutputSessionConfigured)
        } else {
            configurationFailed(with: .cantAddPhotoOutput)
        }
    }

    func addVideoOutput() {
        if session.canAddOutput(videoOutput) {
            videoOutput.setSampleBufferDelegate(
                videoCaptureUseCase,
                queue: DispatchQueue.global(qos: .userInitiated)
            )

            session.addOutput(videoOutput)
            cameraConfigurationSubject.send(.videoOutputSessionConfigured)
        } else {
            configurationFailed(with: .cantAddVideoOutput)
        }
    }

    func addVideoInput(_ videoDeviceInput: AVCaptureDeviceInput) {
        session.addInput(videoDeviceInput)
        self.videoDeviceInput = videoDeviceInput
        cameraConfigurationSubject.send(.inputSessionConfigured)
    }

    func configurationFailed(with result: SessionConfigurationResult) {
        cameraConfigurationSubject.send(result)
        setupResult = .configurationFailed
    }

    func configureSession() {
        if setupResult != .success { return }
        session.beginConfiguration()
        session.sessionPreset = .photo

        do {
            guard let videoDevice = captureDevice else {
                configurationFailed(with: .defaultVideoDeviceIsUnavailable)
                session.commitConfiguration()
                return
            }
            
            let videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)

            if session.canAddInput(videoDeviceInput) {
                addVideoInput(videoDeviceInput)
            } else {
                configurationFailed(with: .cantAddVideoDeviceToTheSession)
            }
        } catch {
            configurationFailed(with: .cantCreateVideoDeviceInput(error))
        }

        session.commitConfiguration()
    }
}
