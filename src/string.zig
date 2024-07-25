const std = @import("std");
const Allocator = std.mem.Allocator;

pub fn stripFront(source: []const u8) []const u8 {
    for (source, 0..) |character, index| {
        if (character != ' ' and character != '\n') {
            return source[index..];
        }
    }

    return source;
}

pub fn stripBack(source: []const u8) []const u8 {
    var i = source.len - 1;
    while (i >= 0) : (i -= 1) {
        if (source[i] != ' ' and source[i] != '\n') {
            return source[0 .. i + 1];
        }
    }

    return source;
}
