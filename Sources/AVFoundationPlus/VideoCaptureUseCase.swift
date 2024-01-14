import AVFoundation
import Combine
import UIKit

public protocol VideoCaptureUseCaseProtocol: AVCaptureVideoDataOutputSampleBufferDelegate {
    var sampleBufferPublisher: AnyPublisher<CMSampleBuffer, Never> { get }
}

public class VideoCaptureUseCase: NSObject {

    private var sampleBufferSubject: PassthroughSubject<CMSampleBuffer, Never> = PassthroughSubject()
}

extension VideoCaptureUseCase: VideoCaptureUseCaseProtocol {
    public var sampleBufferPublisher: AnyPublisher<CMSampleBuffer, Never> {
        sampleBufferSubject.eraseToAnyPublisher()
    }

    public func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        sampleBufferSubject.send(sampleBuffer)
    }
}
