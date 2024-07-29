const std = @import("std");
const Allocator = std.mem.Allocator;

pub const ArgumentsParser = struct {
    const Self = @This();

    allocator: Allocator,
    arguments: std.ArrayList([]const u8),

    pub fn init(allocator: Allocator) !Self {
        return Self{
            .allocator = allocator,
            .arguments = std.ArrayList([]const u8).init(allocator),
        };
    }

    pub fn deinit(self: *Self) void {
        self.arguments.deinit();
    }

    pub fn parse(self: *Self, args: std.process.ArgIterator) !void {
        var iter = args;

        while (iter.next()) |argument| {
            try self.arguments.append(argument);
        }
    }

    pub fn is_existent(self: *const Self, argument: []const u8) bool {
        for (self.arguments.items) |item| {
            if (std.mem.eql(u8, item, argument)) {
                return true;
            }
        }

        return false;
    }

    pub fn len(self: *const Self) usize {
        return self.arguments.items.len;
    }
};
