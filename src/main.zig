const std = @import("std");
const sysfetch = @import("root.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer std.debug.assert(gpa.deinit() == .ok);

    const allocator = gpa.allocator();

    var cpuinfo = sysfetch.CPUInfo.init(allocator);
    defer cpuinfo.deinit();

    try cpuinfo.fetch();

    std.debug.print("Manufacturer: {?s}\n", .{cpuinfo.manufacturer_name});
    std.debug.print("Model: {?s}\n", .{cpuinfo.model_name});
    std.debug.print("Cores: {?d}\n", .{cpuinfo.cores});
    std.debug.print("Threads: {?d}\n", .{cpuinfo.threads});
}
