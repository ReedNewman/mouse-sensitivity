// Watches for screen unlock and network changes, then runs mouse-sensitivity.sh
import Cocoa
import Network

let script = "\(NSHomeDirectory())/.config/mouse-sensitivity/mouse-sensitivity.sh"

func runScript() {
    let task = Process()
    task.launchPath = "/bin/bash"
    task.arguments = [script]
    try? task.run()
}

// Run on launch
runScript()

// Run on screen unlock
DistributedNotificationCenter.default().addObserver(
    forName: NSNotification.Name("com.apple.screenIsUnlocked"),
    object: nil, queue: .main
) { _ in runScript() }

// Run on network change
let monitor = NWPathMonitor()
monitor.pathUpdateHandler = { _ in runScript() }
monitor.start(queue: DispatchQueue.global())

// Keep running
RunLoop.main.run()
