const std = @import("std");
const sysfetch = @import("root.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer std.debug.assert(gpa.deinit() == .ok);

    const allocator = gpa.allocator();

    const stdout = std.io.getStdOut().writer();

    var cpuinfo = sysfetch.CPUInfo.init(allocator);
    defer cpuinfo.deinit();

    try cpuinfo.fetch();

    try stdout.print("CPU\n", .{});
    try stdout.print(" ├─ Manufacturer: {?s}\n", .{cpuinfo.manufacturer_name});
    try stdout.print(" ├─ Model: {?s}\n", .{cpuinfo.model_name});
    try stdout.print(" └─ No. of cores: {?d}\n", .{cpuinfo.cores});
    try stdout.print("    └─ No. of threads: {?d}\n", .{cpuinfo.threads});
}
