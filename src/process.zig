const std = @import("std");
const fs = std.fs;
const fmt = std.fmt;
const mem = std.mem;
const os = std.os;

/// Global buffer used whenever we need a buffer.
/// bustd is single-threaded so this should be fine.
pub var buffer: [128]u8 = undefined;

pub const Process = struct {
    pid: u32,
    oom_score: i16,

    const Self = @This();

    const ProcessError = error{MalformedOomScore, MalformedOomScoreAdj};

    fn fromPid(pid: u32) !Self {
        const oom_score = try oomScoreFromPid(pid);

        return Self{ .pid = pid, .oom_score = oom_score };
    }

    fn oomScoreFromPid(pid: u32) !i16 {
        const path = try fmt.bufPrint(&buffer, "/proc/{}/oom_score", .{pid});

        // The file descriptor for the oom_score file of this process
        const oom_score_fd = try os.open(path, os.O.RDONLY, 0);
        defer os.close(oom_score_fd);

        const bytes_read = try os.read(oom_score_fd, &buffer);

        const oom_score = parse(i16, buffer[0 .. bytes_read - 1]) orelse return error.MalformedOomScore;

        return oom_score;
    }

    pub fn oomScoreAdj(self: *const Self) !i16 {
        const path = try fmt.bufPrint(&buffer, "/proc/{}/oom_score_adj", .{self.pid});

        // The file descriptor for the oom_score file of this process
        const oom_score_adj_fd = try os.open(path, os.O.RDONLY, 0);
        defer os.close(oom_score_adj_fd);

        const bytes_read = try os.read(oom_score_adj_fd, &buffer);

        const oom_score_adj = parse(i16, buffer[0 .. bytes_read - 1]) orelse return error.MalformedOomScoreAdj;

        return oom_score_adj;
    }
};

/// Wrapper over fmt.parseInt which returns null
/// in failure instead of an error
fn parse(comptime T: type, buf: []const u8) ?T {
    return fmt.parseInt(T, buf, 10) catch null;
}

/// Used to try to tell LLVM to predict the other branch.
///
/// I have no idea how effective this is in practice.
fn coldNoOp() void {
    @setCold(true);
}

/// Searches for a process to kill in order to
/// free up memory
pub fn findVictimProcess() !?Process {
    var victim: ?Process = null;
    var victim_vm_rss: ?i16 = null;
    var proc_dir = try fs.cwd().openDir("/proc", .{ .access_sub_paths = false, .iterate = true });
    var proc_it = proc_dir.iterate();

    while (try proc_it.next()) |proc_entry| {
        // We're only interested in directories of /proc
        if (proc_entry.kind != .Directory) {
            continue;
        } else {
            // `/proc` usually has much more directories than it has files
            coldNoOp();
        }

        // But we're not interested in files that don't relate to a PID
        const pid = parse(u32, proc_entry.name) orelse continue;

        // Don't consider killing the init system
        if (pid <= 1) {
            coldNoOp();
            continue;
        }

        const process = try Process.fromPid(pid);

        if (victim == null) {
            // We're still reading the first process
            coldNoOp();
            victim = process;
            std.log.info("First victim set");
        }



        // std.log.info("Found PID: {} with OOM score {}, OOM score adj. {}", .{ pid, oom_score, oom_score_adj });
    }

    return victim;
}
