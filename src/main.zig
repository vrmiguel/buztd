const std = @import("std");
const c = std.c;
const libc = @import("libc");

test "daemonize.zig" {
    _ = @import("daemonize.zig");
}

const daemon = @import("daemonize.zig");

pub fn main() anyerror!void {
    // TODO: argparse
    const should_daemonize = true;

    if (should_daemonize) {
        try daemon.daemonize();
    }
}