public protocol CameraAccessTrackerProtocol: AnyObject {
    func track(cameraAccessStatus status: Bool)
}
