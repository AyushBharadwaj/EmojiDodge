import Foundation
import QuartzCore

/// Drives a frame callback on the main run loop using `CADisplayLink`.
final class GameLoopController: NSObject {
    private var displayLink: CADisplayLink?
    private var lastTimestamp: CFTimeInterval?

    var onTick: ((TimeInterval) -> Void)?

    func start() {
        stop()
        lastTimestamp = nil
        let link = CADisplayLink(target: self, selector: #selector(step))
        link.add(to: .main, forMode: .common)
        displayLink = link
    }

    func stop() {
        displayLink?.invalidate()
        displayLink = nil
        lastTimestamp = nil
    }

    @objc private func step(link: CADisplayLink) {
        let now = link.timestamp
        let dt: TimeInterval
        if let last = lastTimestamp {
            dt = now - last
        } else {
            dt = link.duration
        }
        lastTimestamp = now
        onTick?(max(dt, 0))
    }

    deinit {
        stop()
    }
}
