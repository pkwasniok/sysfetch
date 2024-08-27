const std = @import("std");

pub const CPUInfo = struct {
    const Self = @This();

    allocator: std.mem.Allocator,
    manufacturer_name: ?[]u8,
    model_name: ?[]u8,
    cores: ?u32,
    threads: ?u32,

    pub fn init(allocator: std.mem.Allocator) Self {
        return Self{
            .allocator = allocator,
            .manufacturer_name = null,
            .model_name = null,
            .cores = null,
            .threads = null,
        };
    }

    pub fn deinit(self: *Self) void {
        if (self.model_name) |model_name| {
            self.allocator.free(model_name);
        }

        if (self.manufacturer_name) |manufacturer_name| {
            self.allocator.free(manufacturer_name);
        }
    }

    pub fn fetch(self: *Self) !void {
        const cpuinfo_file = try std.fs.openFileAbsolute("/proc/cpuinfo", .{ .mode = .read_only });
        defer cpuinfo_file.close();

        const cpuinfo_reader = cpuinfo_file.reader();
        while (try cpuinfo_reader.readUntilDelimiterOrEofAlloc(self.allocator, '\n', 4096)) |line| {
            defer self.allocator.free(line);

            if (std.mem.eql(u8, line, "")) {
                break;
            }

            const ParserState = enum { key, value };
            var parser_state = ParserState.key;

            var buffer_key = std.ArrayList(u8).init(self.allocator);
            defer buffer_key.deinit();

            var buffer_value = std.ArrayList(u8).init(self.allocator);
            defer buffer_value.deinit();

            for (line) |char| {
                switch (parser_state) {
                    .key => {
                        if (std.ascii.isWhitespace(char)) {
                            continue;
                        } else if (char == ':') {
                            parser_state = .value;
                        } else {
                            try buffer_key.append(char);
                        }
                    },
                    .value => {
                        if (buffer_value.items.len == 0 and std.ascii.isWhitespace(char)) {
                            continue;
                        } else {
                            try buffer_value.append(char);
                        }
                    },
                }
            }

            if (std.mem.eql(u8, buffer_key.items, "modelname")) {
                self.model_name = try self.allocator.alloc(u8, buffer_value.items.len);
                std.mem.copyForwards(u8, self.model_name.?, buffer_value.items);
            } else if (std.mem.eql(u8, buffer_key.items, "vendor_id")) {
                if (std.mem.eql(u8, buffer_value.items, "AuthenticAMD")) {
                    const model_name = "AMD";
                    self.manufacturer_name = try self.allocator.alloc(u8, model_name.len);
                    std.mem.copyForwards(u8, self.manufacturer_name.?, model_name);
                } else if (std.mem.eql(u8, buffer_value.items, "GenuineIntel")) {
                    const model_name = "Intel";
                    self.manufacturer_name = try self.allocator.alloc(u8, model_name.len);
                    std.mem.copyForwards(u8, self.manufacturer_name.?, model_name);
                } else {
                    self.manufacturer_name = try self.allocator.alloc(u8, buffer_value.items.len);
                    std.mem.copyForwards(u8, self.manufacturer_name.?, buffer_value.items);
                }
            } else if (std.mem.eql(u8, buffer_key.items, "cpucores")) {
                self.cores = std.fmt.parseInt(u32, buffer_value.items, 10) catch null;
            } else if (std.mem.eql(u8, buffer_key.items, "siblings")) {
                self.threads = std.fmt.parseInt(u32, buffer_value.items, 10) catch null;
            }
        }
    }
};
