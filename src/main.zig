const std = @import("std");
const memory = @import("./memory.zig");
const uptime = @import("./uptime.zig");

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    const stdout = std.io.getStdOut().writer();

    const memory_info = try memory.fetchInfo(allocator);
    const uptime_info = try uptime.fetchInfo(allocator);

    try stdout.print("Memory: {} MiB\n", .{memory_info.amount_total / 1000});
    try stdout.print("Uptime: {} hours, {} mins\n", .{ uptime_info.active / 60 / 60, uptime_info.active / 60 % 60 });
}
