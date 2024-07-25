const std = @import("std");
const Allocator = std.mem.Allocator;
const string = @import("./string.zig");

pub const UptimeInfo = struct {
    active: u32,
    idle: u32,
};

pub fn fetchInfo(allocator: Allocator) !UptimeInfo {
    const uptime_file = try std.fs.openFileAbsolute("/proc/uptime", .{ .mode = .read_only });

    const line = string.stripBack(try uptime_file.reader().readAllAlloc(allocator, 1024));

    const uptime_active = line[0..std.mem.indexOf(u8, line, " ").?];
    const uptime_idle = line[uptime_active.len + 1 ..];

    const uptime_info = UptimeInfo{
        .active = try std.fmt.parseInt(u32, uptime_active[0 .. uptime_active.len - 3], 10),
        .idle = try std.fmt.parseInt(u32, uptime_idle[0 .. uptime_idle.len - 3], 10),
    };

    return uptime_info;
}
