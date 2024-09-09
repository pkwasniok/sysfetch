const std = @import("std");

pub const Config = struct {};

pub fn parse(reader: std.io.Reader(u8)) !Config {
    _ = reader;
    return .{};
}
