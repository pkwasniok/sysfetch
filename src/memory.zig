const std = @import("std");

pub const MemoryInfo = struct {
    const Self = @This();

    allocator: std.mem.Allocator,
    total: ?u32,

    pub fn init(allocator: std.mem.Allocator) Self {
        return Self{
            .allocator = allocator,
            .total = null,
        };
    }

    pub fn deinit(self: *Self) void {
        _ = self;
    }

    pub fn fetch(self: *Self) !void {
        const meminfo_file = try std.fs.openFileAbsolute("/proc/meminfo", .{ .mode = .read_only });
        defer meminfo_file.close();

        const meminfo_reader = meminfo_file.reader();
        while (try meminfo_reader.readUntilDelimiterOrEofAlloc(self.allocator, '\n', 4096)) |line| {
            defer self.allocator.free(line);

            const ParserState = enum { key, value };
            var parser_state = ParserState.key;

            var buffer_key = std.ArrayList(u8).init(self.allocator);
            defer buffer_key.deinit();

            var buffer_value = std.ArrayList(u8).init(self.allocator);
            defer buffer_value.deinit();

            for (line) |char| {
                switch (parser_state) {
                    .key => {
                        if (char == ':') {
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

            // std.debug.print("\"{s}\": \"{s}\"\n", .{ buffer_key.items, buffer_value.items });
        }
    }
};
