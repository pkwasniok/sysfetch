const std = @import("std");
const Allocator = std.mem.Allocator;
const utils = @import("utils.zig");

pub const os = struct {
    pub const OSInfo = struct {
        const Self = @This();

        allocator: Allocator,
        hostname: []u8,
        uptime: u32,

        pub fn fetch(allocator: Allocator) !Self {
            const file_hostname = try std.fs.openFileAbsolute("/etc/hostname", .{ .mode = .read_only });
            defer file_hostname.close();

            const file_uptime = try std.fs.openFileAbsolute("/proc/uptime", .{ .mode = .read_only });
            defer file_uptime.close();

            // Parse hostname
            const hostname = (try file_hostname.reader().readUntilDelimiterOrEofAlloc(allocator, '\n', 1024)).?;

            // Parse uptime
            const uptime_text = try file_uptime.reader().readAllAlloc(allocator, 1024);
            defer allocator.free(uptime_text);
            const uptime_active_text = uptime_text[0..std.mem.indexOf(u8, uptime_text, " ").?];
            const uptime = try std.fmt.parseInt(u32, uptime_active_text[0 .. uptime_active_text.len - 3], 10);

            return Self{
                .allocator = allocator,
                .hostname = hostname,
                .uptime = uptime,
            };
        }

        pub fn deinit(self: *Self) void {
            self.allocator.free(self.hostname);
        }
    };
};

pub const cpu = struct {
    pub const CPUInfo = struct {};

    pub fn fetch() CPUInfo {
        return CPUInfo{};
    }
};

pub const gpu = struct {
    pub const GPUInfo = struct {};

    pub fn fetch() GPUInfo {
        return GPUInfo{};
    }
};

pub const memory = struct {
    pub const MemoryInfo = struct {
        const Self = @This();

        allocator: Allocator,
        total: u32,
        available: u32,

        pub fn fetch(allocator: Allocator) !Self {
            const meminfo_file = try std.fs.openFileAbsolute("/proc/meminfo", .{ .mode = .read_only });
            defer meminfo_file.close();

            var total: u32 = 0;
            var available: u32 = 0;

            var meminfo_reader = meminfo_file.reader();
            while (try meminfo_reader.readUntilDelimiterOrEofAlloc(allocator, '\n', 1024)) |line| {
                if (std.mem.startsWith(u8, line, "MemTotal")) {
                    total = try std.fmt.parseInt(u32, utils.deleteEnd(utils.stripFront(line[9..]), 2), 10);
                } else if (std.mem.startsWith(u8, line, "MemAvailable")) {
                    available = try std.fmt.parseInt(u32, utils.deleteEnd(utils.stripFront(line[13..]), 2), 10);
                }
            }

            return Self{
                .allocator = allocator,
                .total = total,
                .available = available,
            };
        }
    };
};

pub const network = struct {
    pub const NetworkInfo = struct {};

    pub fn fetch() void {
        return NetworkInfo{};
    }
};
