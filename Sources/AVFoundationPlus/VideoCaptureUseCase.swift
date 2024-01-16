import AVFoundation
import Combine
import UIKit

/**
 A use case for capturing video using AVFoundation and publishing video frames as `CMSampleBuffer` using Combine framework.
 
 This class implements the `VideoCaptureUseCaseProtocol` and provides a way to capture video frames and publish them as `CMSampleBuffer` using the Combine framework. It utilizes AVFoundation for video capture and AVCaptureVideoDataOutputSampleBufferDelegate for handling video output.
 
 Usage:
 1. Create an instance of `VideoCaptureUseCase`.
 2. Implement AVCaptureSession configuration and setup as needed in your application.
 3. Set an object as the delegate for video capture using `AVCaptureVideoDataOutputSampleBufferDelegate`.
 4. Subscribe to the `sampleBufferPublisher` to receive video frames as `CMSampleBuffer` objects.
 5. Handle and process the received video frames in your application.
 
 Example usage:
 ```swift
 // Create a VideoCaptureUseCase instance
 let videoCaptureUseCase = VideoCaptureUseCase()
 
 // Implement AVCaptureSession configuration and setup here...
 
 // Set this instance as the delegate for video capture
 // Assuming you have an AVCaptureVideoDataOutput instance named 'videoDataOutput'
 videoDataOutput.setSampleBufferDelegate(videoCaptureUseCase, queue: DispatchQueue(label: "VideoCaptureQueue"))
 
 // Subscribe to receive video frames
 videoCaptureUseCase.sampleBufferPublisher
 .sink { sampleBuffer in
 // Process and handle the received video frames here...
 }
 .store(in: &cancellable)
 Note: Make sure to properly configure AVCaptureSession, AVCaptureDevice, and AVCaptureVideoDataOutput for your specific use case before using this class.
 */
public class VideoCaptureUseCase: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {

    var sampleBufferPublisher: AnyPublisher<CMSampleBuffer, Never> {
        sampleBufferSubject.eraseToAnyPublisher()
    }

    private var sampleBufferSubject: PassthroughSubject<CMSampleBuffer, Never> = PassthroughSubject()
    
    public func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        sampleBufferSubject.send(sampleBuffer)
    }
}
