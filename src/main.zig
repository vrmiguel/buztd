const std = @import("std");
const c = std.c;
const libc = @import("libc");

test "daemonize.zig" {
    _ = @import("daemonize.zig");
}

test "process.zig" {
    _ = @import("process.zig");
}

const daemon = @import("daemonize.zig");
const process = @import("process.zig");

pub fn main() anyerror!void {
    // TODO: argparse
    // const should_daemonize = true;

    // if (should_daemonize) {
    //     try daemon.daemonize();
    // }

    _ = try process.findVictimProcess();
}
