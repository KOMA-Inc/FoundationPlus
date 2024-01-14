import AVFoundation
import Combine
import UIKit

/**
 A protocol for defining the interface of a video capture use case.
 
 This protocol extends `AVCaptureVideoDataOutputSampleBufferDelegate` to provide a way to capture video frames and publish them as `CMSampleBuffer` objects using Combine framework. It's intended to be adopted by classes or structures that handle video capture and want to expose a standardized interface for publishing video frames.
 
 - Note: Classes conforming to this protocol should implement the `AVCaptureVideoDataOutputSampleBufferDelegate` methods for video frame handling.
 
 Example usage:
 ```swift
 class MyVideoCaptureHandler: AVCaptureVideoDataOutputSampleBufferDelegate, VideoCaptureUseCaseProtocol {
 var sampleBufferPublisher: AnyPublisher<CMSampleBuffer, Never> {
 // Implement the publisher logic here...
 }
 
 // Implement AVCaptureVideoDataOutputSampleBufferDelegate methods here...
 }
 public protocol VideoCaptureUseCaseProtocol: AVCaptureVideoDataOutputSampleBufferDelegate {
 var sampleBufferPublisher: AnyPublisher<CMSampleBuffer, Never> { get }
 }
 Conforming classes or structures must implement the sampleBufferPublisher property to provide a publisher for video frames.
 */

public protocol VideoCaptureUseCaseProtocol: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    /*
     A publisher that emits CMSampleBuffer objects representing video frames.
     Subscribing to this publisher allows you to receive video frames as `CMSampleBuffer` objects in your application.
     */
    var sampleBufferPublisher: AnyPublisher<CMSampleBuffer, Never> { get }
}

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
 .store(in: &cancellables)
 Note: Make sure to properly configure AVCaptureSession, AVCaptureDevice, and AVCaptureVideoDataOutput for your specific use case before using this class.
 */
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

