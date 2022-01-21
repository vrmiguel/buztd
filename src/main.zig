const std = @import("std");
const c = std.c;
const libc = @import("libc");
const unistd = @cImport({
    @cInclude("unistd.h");
});

const signal = @cImport({
    @cInclude("signal.h");
});

const stat = @cImport({
    @cInclude("sys/stat.h");
});

const os = std.os;

pub fn main() anyerror!void {
    try daemonize();
}

const DaemonizeError = error {
    FailedToSetSessionId
} || os.ForkError;

const SignalHandler = struct {
    fn ignore(sig: i32, info: *const os.siginfo_t, ctx_ptr: ?*const anyopaque) callconv(.C) void {
        // Ignore the signal received
        _ = sig;
        _ = ctx_ptr;
        _ = info;
        _ = ctx_ptr;
    }
};

// forks the current process and exits
// the parent process
fn fork_and_keep_child() os.ForkError!void {
    const is_parent_proc = (try os.fork()) > 0;
    // Exit off of the parent process
    if (is_parent_proc) {
        os.exit(0);
    }
}

fn daemonize() DaemonizeError!void {
    try fork_and_keep_child();

    if (unistd.setsid() < 0) {
        return error.FailedToSetSessionId;
    }

    // Setup signal handling
    var act = os.Sigaction{
        .handler = .{ .sigaction = SignalHandler.ignore },
        .mask = os.empty_sigset,
        .flags = (os.SA.SIGINFO | os.SA.RESTART | os.SA.RESETHAND),
    };
    os.sigaction(signal.SIGCHLD, &act, null);
    os.sigaction(signal.SIGHUP, &act, null);

    // Fork yet again and keep only the child process
    try fork_and_keep_child();

    // Set new file permissions
    _ = stat.umask(0);

    var fd: u8 = 0;
    // The maximum number of files a process can have open
    // at any time
    const max_files_opened = unistd.sysconf(unistd._SC_OPEN_MAX);
    while (fd < max_files_opened) : (fd += 1) {
        _ = unistd.close(fd);
    }
}