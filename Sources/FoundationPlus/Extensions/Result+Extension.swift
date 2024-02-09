public extension Swift.Result where Success == Void {
    static func success() -> Self {
        .success(())
    }
}
