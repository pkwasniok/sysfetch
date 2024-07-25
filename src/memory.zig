const std = @import("std");
const Allocator = std.mem.Allocator;
const string = @import("./string.zig");

pub const MemoryInfo = struct {
    amount_total: u32,
    amount_available: u32,
};

pub fn fetchInfo(allocator: Allocator) !MemoryInfo {
    const meminfo_file = try std.fs.openFileAbsolute("/proc/meminfo", .{ .mode = .read_only });

    var memory_info = MemoryInfo{
        .amount_total = 0,
        .amount_available = 0,
    };

    while (try meminfo_file.reader().readUntilDelimiterOrEofAlloc(allocator, '\n', 1024)) |line| {
        const key = line[0..std.mem.indexOf(u8, line, ":").?];
        const value = string.stripFront(line[key.len + 1 ..]);

        if (std.mem.eql(u8, key, "MemTotal")) {
            const amount_total = try std.fmt.parseInt(u32, value[0 .. value.len - 3], 10);
            memory_info.amount_total = amount_total;
        } else if (std.mem.eql(u8, key, "MemAvailable")) {
            const amount_available = try std.fmt.parseInt(u32, value[0 .. value.len - 3], 10);
            memory_info.amount_available = amount_available;
        }
    }

    return memory_info;
}
