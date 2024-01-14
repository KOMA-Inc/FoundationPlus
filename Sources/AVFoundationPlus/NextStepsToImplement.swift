
//Custom AVCapturePhotoSettings settings object to configure snaps from outside

//struct CapturePhotoSettings {
//    var flashMode: AVCaptureDevice.FlashMode = .auto
//    var isHighResolutionEnabled = true
//    var isLivePhotoEnabled = false
//    var photoQualityPrioritization: AVCapturePhotoOutput.QualityPrioritization = .balanced
//
//    // A computed property to get the configured settings.
//    var settings: AVCapturePhotoSettings {
//        let settings = AVCapturePhotoSettings()
//        settings.flashMode = flashMode
//        settings.isHighResolutionPhotoEnabled = isHighResolutionEnabled
//        settings.isLivePhotoEnabled = isLivePhotoEnabled
//        settings.photoQualityPrioritization = photoQualityPrioritization
//        return settings
//    }
//
//    init() { }
//}


// Handle available devices to be able to switch between cameras

//    private lazy var allDeviceTypes: [AVCaptureDevice] = AVCaptureDevice.DiscoverySession(
//        deviceTypes: [
//            .builtInMicrophone,
//            .builtInWideAngleCamera,
//            .builtInTelephotoCamera,
//            .builtInUltraWideCamera,
//            .builtInDualCamera,
//            .builtInTripleCamera,
//            .builtInTrueDepthCamera,
//        ],
//        mediaType: .video,
//        position: .unspecified
//    ).devices

//    private var captureDevice: AVCaptureDevice? {
//        let discoverySession = AVCaptureDevice.DiscoverySession(
//            deviceTypes: [.builtInDualCamera, .builtInWideAngleCamera],
//            mediaType: .video,
//            position: .unspecified
//        )
//
//        return discoverySession.devices.first
//     }
