const std = @import("std");

// This parser only provides very basic functionality
// It's work in progress
// Don't judge

pub const ParsingResult = enum { default, help, version };

pub fn parse(allocator: std.mem.Allocator) !ParsingResult {
    // std.process.args() only works on Linux
    // std.process.argsWithAllocator() should be used to achieve cross-platform compatibility
    // sysfetch only works on Linux so whatever, using .args dosn't require calling .deinit()
    var args = std.process.args();

    var arguments = std.ArrayList([]const u8).init(allocator);
    defer arguments.deinit();

    var options = std.ArrayList([]const u8).init(allocator);
    defer options.deinit();

    var flags = std.ArrayList(u8).init(allocator);
    defer flags.deinit();

    while (args.next()) |arg| {
        if (std.mem.startsWith(u8, arg, "--")) {
            try options.append(arg[2..]);
        } else if (std.mem.startsWith(u8, arg, "-")) {
            for (arg[1..]) |char| {
                try flags.append(char);
            }
        } else {
            try arguments.append(arg);
        }
    }

    for (options.items) |option| {
        if (std.mem.eql(u8, option, "help")) {
            return ParsingResult.help;
        } else if (std.mem.eql(u8, option, "version")) {
            return ParsingResult.version;
        }
    }

    return ParsingResult.default;
}
