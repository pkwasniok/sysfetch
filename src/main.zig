const std = @import("std");
const cli = @import("cli.zig");
const sysfetch = @import("sysfetch.zig");

pub fn main() !void {
    // Obtain allocator
    const allocator = std.heap.page_allocator;

    // Obtain standard output
    const stdout = std.io.getStdOut().writer();

    // Fetch OS info
    const os_info = try sysfetch.getOSInfo(allocator);

    // Fetch memory info
    const mem_info = try sysfetch.getMemoryInfo(allocator);

    var arguments = try std.process.argsWithAllocator(allocator);
    defer arguments.deinit();

    var argparse = try cli.ArgumentsParser.init(allocator);
    argparse.deinit();

    try argparse.parse(arguments);

    if (argparse.is_existent("--help")) {
        try stdout.print("Usage: sysfetch [options]\n", .{});
        try stdout.print("Options:\n", .{});
        try stdout.print("  --help         Display this information.\n", .{});
        try stdout.print("  --version      Display sysfetch version.\n", .{});
        try stdout.print("  --summary      Display system summary.\n", .{});
    } else if (argparse.is_existent("--version")) {
        try stdout.print("Sysfetch 0.0.1\n", .{});
    } else if (argparse.is_existent("--summary") or argparse.len() == 1) {
        try stdout.print("OS\n", .{});
        try stdout.print("  Hostname: {s}\n", .{os_info.hostname});
        try stdout.print("  Uptime: {} hours, {} mins\n", .{ os_info.uptime / 60 / 60, os_info.uptime / 60 % 60 });
        try stdout.print("Memory\n", .{});
        try stdout.print("  Total: {} KiB\n", .{mem_info.total});
        try stdout.print("  Available: {} KiB\n", .{mem_info.available});
    }
}
