const std = @import("std");

const MemoryStatusTag = enum {
    ok,
    near_terminal,
};

const MemoryStatus = union(MemoryStatusTag) {
    /// Memory is "okay": basically no risk of memory thrashing 
    ok: void,
    /// Nearing the terminal PSI cutoff: memory thrashing is occurring or close to it.
    /// Holds the current PSI value.
    near_terminal: u8
};

pub const Monitor = struct {
    /// Memory status as of last checked
    status: MemoryStatus,
    /// The cutoff PSI on which larger values are to be considered terminal
    cutoff_psi: f32,
    const Self = @This();

    pub fn new() Self {

    }

    pub fn poll(self: Self) !void {
        std.log.warn("isMemoryLow = {}", .{self.isMemoryLow()});
    }

    fn isMemoryLow(self: *const Self) bool {
        return switch (self.status) {
            MemoryStatusTag.ok => false,
            MemoryStatusTag.near_terminal => |psi| psi >= self.cutoff_psi,
        };
    }
};