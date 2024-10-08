import AVFoundation
import UIKit

/**
 A custom UIView subclass for displaying the live video preview from an `AVCaptureSession`.

 The `PreviewView` class is designed to display the video feed from an `AVCaptureSession` as a live preview. It uses an `AVCaptureVideoPreviewLayer` as its layer and provides a property for setting the session to be displayed.

 Example usage:
 ```swift
 let previewView = PreviewView()
 previewView.session = yourAVCaptureSession
 SeeAlso: AVCaptureSession, AVCaptureVideoPreviewLayer
 */
open class PreviewView: UIView {

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    open func setup() {
        clipsToBounds  = true
    }

    /*
     Returns the underlying AVCaptureVideoPreviewLayer used for displaying the live video preview.

     This property provides direct access to the AVCaptureVideoPreviewLayer to customize its properties.

     Important: Ensure that the layer is of type AVCaptureVideoPreviewLayer to avoid runtime errors.
     Example usage:
     let previewLayer = previewView.videoPreviewLayer
     previewLayer.videoGravity = .resizeAspect
     Note: If the layer type is not AVCaptureVideoPreviewLayer, a fatal error will be triggered.

     SeeAlso: AVCaptureVideoPreviewLayer
     */
    public var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        guard let layer = layer as? AVCaptureVideoPreviewLayer else {
            fatalError(
             """
             Expected AVCaptureVideoPreviewLayer type for layer.
             Check PreviewView.layerClass implementation.
             """
            )
        }
        return layer
    }

    /**
     @property videoGravity
     @abstract
        A string defining how the video is displayed within an AVCaptureVideoPreviewLayer bounds rect.
     */
    public var videoGravity: AVLayerVideoGravity {
        get {
            videoPreviewLayer.videoGravity
        }
        set {
            videoPreviewLayer.videoGravity = newValue
        }
    }

    /// The AVCaptureSession to be displayed as a live video preview.
    public var session: AVCaptureSession? {
        get {
            videoPreviewLayer.session
        }
        set {
            videoPreviewLayer.session = newValue
        }
    }

    /**
     Returns the layer class to be used for the view.

     This class property specifies the type of layer that should be used for this view. In this case, it should be an AVCaptureVideoPreviewLayer.

     Example usage:
     override class var layerClass: AnyClass {
     AVCaptureVideoPreviewLayer.self
     }
     SeeAlso: AVCaptureVideoPreviewLayer
     */
    public override class var layerClass: AnyClass {
        AVCaptureVideoPreviewLayer.self
    }
}
