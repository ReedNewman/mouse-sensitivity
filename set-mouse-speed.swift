// Sets mouse acceleration via IOKit — takes effect immediately without logout
import Foundation
import IOKit
import IOKit.hid

guard CommandLine.arguments.count > 1, let speed = Double(CommandLine.arguments[1]) else {
    fputs("Usage: set-mouse-speed <value>\n", stderr)
    exit(1)
}

let matching = IOServiceMatching("IOHIDSystem")
let service = IOServiceGetMatchingService(kIOMainPortDefault, matching)
guard service != IO_OBJECT_NULL else {
    fputs("ERROR: Could not find IOHIDSystem\n", stderr)
    exit(1)
}

var connect: io_connect_t = 0
let kr = IOServiceOpen(service, mach_task_self_, UInt32(kIOHIDParamConnectType), &connect)
IOObjectRelease(service)

guard kr == KERN_SUCCESS else {
    fputs("ERROR: Could not open IOHIDSystem: \(kr)\n", stderr)
    exit(1)
}

IOHIDSetAccelerationWithKey(connect, kIOHIDMouseAccelerationType as CFString, speed)
IOServiceClose(connect)
