const std = @import("std");
const memory = @import("./memory.zig");
const uptime = @import("./uptime.zig");
const os = @import("./os.zig");

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    const stdout = std.io.getStdOut().writer();

    const memory_info = try memory.fetchInfo(allocator);
    const uptime_info = try uptime.fetchInfo(allocator);
    const os_info = try os.fetchOSInfo(allocator);

    try stdout.print("Memory: {} MiB\n", .{memory_info.amount_total / 1000});
    try stdout.print("Uptime: {} hours, {} mins\n", .{ uptime_info.active / 60 / 60, uptime_info.active / 60 % 60 });
    try stdout.print("Hostname: {s}\n", .{os_info.host_name});
}
