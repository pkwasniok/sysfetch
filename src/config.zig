const std = @import("std");

pub const ImageConfig = struct {
    path: ?std.ArrayList(u8),
};

pub const Config = struct {
    const Self = @This();

    allocator: std.mem.Allocator,
    image: ImageConfig,

    pub fn init(allocator: std.mem.Allocator) Self {
        return Self{
            .allocator = allocator,
            .image = .{ .path = null },
        };
    }

    pub fn deinit(self: *Self) void {
        if (self.image.path) |path| {
            path.deinit();
        }
    }

    pub fn loadFromFile(self: *Self, file: std.fs.File) !void {
        const ParserState = enum { Key, Value };

        const reader = file.reader();

        while (try reader.readUntilDelimiterOrEofAlloc(self.allocator, '\n', 512 * 1024)) |line| {
            var parser_state = ParserState.Key;
            var buffer_key = std.ArrayList(u8).init(self.allocator);
            defer buffer_key.deinit();
            var buffer_value = std.ArrayList(u8).init(self.allocator);
            defer buffer_value.deinit();

            for (line) |character| {
                switch (parser_state) {
                    .Key => {
                        if (character == '=') {
                            parser_state = .Value;
                        } else if (std.ascii.isWhitespace(character)) {
                            continue;
                        } else {
                            try buffer_key.append(character);
                        }
                    },
                    .Value => {
                        if (std.ascii.isWhitespace(character)) {
                            continue;
                        } else {
                            try buffer_value.append(character);
                        }
                    },
                }
            }

            if (std.mem.eql(u8, buffer_key.items, "image.path")) {
                var image_path = std.ArrayList(u8).init(self.allocator);
                try image_path.appendSlice(buffer_value.items);

                self.image.path = image_path;
            }
        }
    }
};
