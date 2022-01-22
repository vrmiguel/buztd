const std = @import("std");

const memory = @import("memory.zig");
const pressure = @import("pressure.zig");

const MemoryStatusTag = enum {
    ok,
    near_terminal,
};

const MemoryStatus = union(MemoryStatusTag) {
    /// Memory is "okay": basically no risk of memory thrashing 
    ok: void,
    /// Nearing the terminal PSI cutoff: memory thrashing is occurring or close to it.
    /// Holds the current PSI value.
    near_terminal: f32
};

pub const Monitor = struct {
    mem_info: memory.MemoryInfo,
    /// Memory status as of last checked
    status: MemoryStatus,
    /// The cutoff PSI on which larger values are to be considered terminal
    cutoff_psi: f32,
    /// A buffer of at least 128 bytes
    buffer: []u8,
    const Self = @This();

    pub fn new(cutoff_psi: f32, buffer: []u8) !Self {
        const mem_info = try memory.MemoryInfo.new();
        const status: MemoryStatus = blk: {
            if (mem_info.available_ram_percent <= 15) {
                const psi = try pressure.pressureSomeAvg10(buffer);
                break :blk MemoryStatus { .near_terminal = psi };
            } else {
                break :blk MemoryStatus.ok;
            }
        };

        return Self {
            .mem_info = mem_info,
            .cutoff_psi = cutoff_psi,
            .status = status,
            .buffer = buffer,
        };
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