const std = @import("std");
const utils = @import("utils.zig");
const Allocator = std.mem.Allocator;

pub const OSInfo = struct {
    hostname: []u8,
    uptime: u32,
    kernel: []u8,
};

pub const CPUInfo = struct {
    model: []u8,
    frequency: u32,
};

pub const MemoryInfo = struct {
    total: u32,
    available: u32,
};

pub fn getOSInfo(allocator: Allocator) !OSInfo {
    const hostname = blk: {
        // Open hostname file
        const hostname_file = try std.fs.openFileAbsolute("/etc/hostname", .{ .mode = .read_only });
        defer hostname_file.close();

        // Read hostname from file
        const hostname_reader = hostname_file.reader();
        const hostname = (try hostname_reader.readUntilDelimiterOrEofAlloc(allocator, '\n', 1024)).?;

        break :blk hostname;
    };

    const uptime = blk: {
        // Open uptime file
        const uptime_file = try std.fs.openFileAbsolute("/proc/uptime", .{ .mode = .read_only });
        defer uptime_file.close();

        // Read uptime from file
        const uptime_reader = uptime_file.reader();
        const uptime_text = (try uptime_reader.readUntilDelimiterOrEofAlloc(allocator, '\n', 1024)).?;

        // Parse uptime
        const separator_index = std.mem.indexOf(u8, uptime_text, " ").?;
        break :blk try std.fmt.parseInt(u32, uptime_text[0 .. separator_index - 3], 10);
    };

    const kernel: []u8 = blk: {
        const version_file = try std.fs.openFileAbsolute("/proc/version", .{ .mode = .read_only });
        defer version_file.close();

        const version_reader = version_file.reader();
        var segments = std.ArrayList([]u8).init(allocator);
        while (try version_reader.readUntilDelimiterOrEofAlloc(allocator, ' ', 1024)) |segment| {
            try segments.append(segment);
        }

        break :blk segments.items[2];
    };

    return OSInfo{
        .hostname = hostname,
        .uptime = uptime,
        .kernel = kernel,
    };
}

pub fn getCPUInfo(allocator: Allocator) !CPUInfo {
    // Open cpuinfo file
    const cpuinfo_file = try std.fs.openFileAbsolute("/proc/cpuinfo", .{ .mode = .read_only });
    defer cpuinfo_file.close();

    // Parse cpuinfo file
    var cpuinfo_keys = std.ArrayList([]u8).init(allocator);
    var cpuinfo_values = std.ArrayList(?[]u8).init(allocator);
    const cpuinfo_reader = cpuinfo_file.reader();
    while (try cpuinfo_reader.readUntilDelimiterOrEofAlloc(allocator, '\n', 1024)) |line| {
        const separator_index = std.mem.indexOf(u8, line, ":");

        if (separator_index == null) {
            continue;
        }

        const key = utils.stripBack(line[0..separator_index.?]);
        const value: ?[]u8 = if (separator_index.? + 1 == line.len) null else line[separator_index.? + 2 ..];

        try cpuinfo_keys.append(key);
        try cpuinfo_values.append(value);
    }

    const model = cpuinfo_values.items[4].?;

    const frequency_dot = std.mem.indexOf(u8, cpuinfo_values.items[7].?, ".").?;
    const frequency = try std.fmt.parseInt(u32, cpuinfo_values.items[7].?[0..frequency_dot], 10);

    return CPUInfo{
        .model = model,
        .frequency = frequency,
    };
}

pub fn getMemoryInfo(allocator: Allocator) !MemoryInfo {
    // Open memory info file
    const meminfo_file = try std.fs.openFileAbsolute("/proc/meminfo", .{ .mode = .read_only });
    defer meminfo_file.close();

    // Parse memory info file
    var meminfo_keys = std.ArrayList([]u8).init(allocator);
    var meminfo_values = std.ArrayList([]u8).init(allocator);
    const meminfo_reader = meminfo_file.reader();
    while (try meminfo_reader.readUntilDelimiterOrEofAlloc(allocator, '\n', 1024)) |line| {
        const separator_index = std.mem.indexOf(u8, line, ":").?;

        const key = line[0..separator_index];
        const value = utils.stripFront(line[separator_index + 1 ..]);

        try meminfo_keys.append(key);
        try meminfo_values.append(value);
    }

    // Parse meminfo file properties
    const total = try std.fmt.parseInt(u32, utils.deleteEnd(meminfo_values.items[0], 2), 10);
    const available = try std.fmt.parseInt(u32, utils.deleteEnd(meminfo_values.items[2], 2), 10);

    return MemoryInfo{
        .total = total,
        .available = available,
    };
}
