const std = @import("std");
const fs = std.fs;
const Allocator = std.mem.Allocator;

pub const OSInfo = struct {
    host_name: []u8,
};

pub fn fetchOSInfo(allocator: Allocator) !OSInfo {
    var os_info = OSInfo{
        .host_name = "",
    };

    const hostname_file = try fs.openFileAbsolute("/etc/hostname", .{ .mode = .read_only });

    const host_name = (try hostname_file.reader().readUntilDelimiterOrEofAlloc(allocator, '\n', 1024)).?;

    os_info.host_name = host_name;

    return os_info;
}
