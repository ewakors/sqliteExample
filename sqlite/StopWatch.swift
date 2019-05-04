import Foundation
import QuartzCore

public struct Stopwatch {
    private var startTime: TimeInterval
    
    public init() {
        startTime = CACurrentMediaTime()
    }
    
    public func elapsedTimeInterval() -> TimeInterval {
        return CACurrentMediaTime() - startTime
    }
    
    public func elapsedTimeString() -> String {
        let interval = elapsedTimeInterval()
        return NSString(format:"%.1f ms", Double(interval * 1000)) as String
    }
}
