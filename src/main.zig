const std = @import("std");
const c = std.c;
const libc = @import("libc");

test "daemonize.zig" {
    _ = @import("daemonize.zig");
}

test "process.zig" {
    _ = @import("process.zig");
}

test "monitor.zig" {
    _ = @import("monitor.zig");
}

const pressure = @import("pressure.zig");
const daemon = @import("daemonize.zig");
const process = @import("process.zig");
const memory = @import("memory.zig");
const monitor = @import("monitor.zig");

pub fn main() anyerror!void {
    // TODO: argparse
    const should_daemonize = false;

    if (should_daemonize) {
        try daemon.daemonize();
    }

    var buffer: [128]u8 = undefined;

    _ = try pressure.pressureSomeAvg10(&buffer);

    _ = try process.findVictimProcess();

    _ = try memory.MemoryInfo.new();

    _ = try monitor.Monitor.new(5.0, &buffer);
}
