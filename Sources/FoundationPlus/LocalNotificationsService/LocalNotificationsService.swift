import Combine
import UserNotifications

public protocol LocalNotificationsStatusTracker: AnyObject {

    func localNotificationsService(
        _ service: LocalNotificationsService,
        requestedAuthorizationWithGrantedStatus status: Bool
    )
}

public class LocalNotificationsService {

    private var tracker: LocalNotificationsStatusTracker?
    private lazy var center = UNUserNotificationCenter.current()

    public init(tracker: LocalNotificationsStatusTracker? = nil) {
        self.tracker = tracker
    }
}

public extension LocalNotificationsService {

    func setTracker(_ tracker: LocalNotificationsStatusTracker) {
        self.tracker = tracker
    }

    func requestAuthorization(
        options: UNAuthorizationOptions = [.alert, .badge, .sound],
        completion: @escaping (Bool) -> Void
    ) {
        DispatchQueue.main.async {
            self.center.getNotificationSettings { settings in
                if settings.authorizationStatus == .notDetermined {
                    self.center.requestAuthorization(options: options) { granted, error in
                        self.tracker?.localNotificationsService(self, requestedAuthorizationWithGrantedStatus: granted)
                        completion(true)
                    }
                } else if settings.authorizationStatus == .authorized {
                    completion(true)
                } else {
                    completion(false)
                }
            }
        }
    }

    func requestAuthorization(
        options: UNAuthorizationOptions = [.alert, .badge, .sound]
    ) -> AnyPublisher<Bool, Never> {
        Future { promise in
            self.requestAuthorization(options: options) { granted in
                promise(.success(granted))
            }
        }.eraseToAnyPublisher()
    }
}
