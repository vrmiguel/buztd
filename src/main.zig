const std = @import("std");

test "imports" {
    _ = @import("pressure.zig");
    _ = @import("daemonize.zig");
    _ = @import("process.zig");
    _ = @import("memory.zig");
    _ = @import("monitor.zig");
    _ = @import("config.zig");
}

const pressure = @import("pressure.zig");
const daemon = @import("daemonize.zig");
const process = @import("process.zig");
const memory = @import("memory.zig");
const monitor = @import("monitor.zig");
const config = @import("config.zig");

pub fn main() anyerror!void {
    if (config.should_daemonize) {
        try daemon.daemonize();
    }

    var buffer: [128]u8 = undefined;

    var m = try monitor.Monitor.new(&buffer);
    try m.poll();
}
