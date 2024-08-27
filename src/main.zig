const std = @import("std");
const sysfetch = @import("root.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer std.debug.assert(gpa.deinit() == .ok);

    const allocator = gpa.allocator();

    const stdout = std.io.getStdOut().writer();

    var cpu_info = sysfetch.CPUInfo.init(allocator);
    defer cpu_info.deinit();

    var memory_info = sysfetch.MemoryInfo.init(allocator);
    defer memory_info.deinit();

    try cpu_info.fetch();
    try memory_info.fetch();

    try stdout.print("CPU\n", .{});
    try stdout.print(" ├─ Manufacturer: {?s}\n", .{cpu_info.manufacturer_name});
    try stdout.print(" ├─ Model: {?s}\n", .{cpu_info.model_name});
    try stdout.print(" └─ No. of cores: {?d}\n", .{cpu_info.cores});
    try stdout.print("    └─ No. of threads: {?d}\n", .{cpu_info.threads});
}
