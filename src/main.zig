const std = @import("std");
const cli = @import("./cli.zig");
const config = @import("./config.zig");
const sysfetch = @import("./root.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer std.debug.assert(gpa.deinit() == .ok);

    const allocator = gpa.allocator();

    const stdout = std.io.getStdOut().writer();

    const parsing_result = try cli.parse(allocator);

    switch (parsing_result) {
        .help => {
            try stdout.print(
                \\ Usage: sysfetch [OPTIONS]
                \\
                \\ Sysfetch is a Neofetch alternative for Linux written in Zig.
                \\
                \\ OPTIONS:
                \\     DEFAULT      display system information
                \\     --help       display help message
                \\     --version    display version information
                \\
            , .{});
        },
        .version => {
            try stdout.print("sysfetch 0.1.0\n", .{});
        },
        .default => {
            var cpu_info = sysfetch.CPUInfo.init(allocator);
            defer cpu_info.deinit();

            var memory_info = sysfetch.MemoryInfo.init(allocator);
            defer memory_info.deinit();

            var os_info = sysfetch.OSInfo.init(allocator);
            defer os_info.deinit();

            try cpu_info.fetch();
            try memory_info.fetch();
            try os_info.fetch();

            try stdout.print("CPU\n", .{});
            try stdout.print("├─Manufacturer: {?s}\n", .{cpu_info.manufacturer_name});
            try stdout.print("├─Model: {?s}\n", .{cpu_info.model_name});
            try stdout.print("└─No. of cores: {?d}\n", .{cpu_info.cores});
            try stdout.print("  └─No. of threads: {?d}\n", .{cpu_info.threads});
            try stdout.print("Memory\n", .{});
            try stdout.print("└─Total: {?d} KiB\n", .{memory_info.physical_total});
            try stdout.print("  └─Free: {?d} KiB\n", .{memory_info.physical_free});
            try stdout.print("OS\n", .{});
            try stdout.print("├─Name: {?s}\n", .{os_info.name});
            try stdout.print("└─Version: {?s}\n", .{os_info.version});
        },
    }
}
