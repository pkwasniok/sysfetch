const std = @import("std");
const String = @import("containers").ASCIIString;

pub fn parse(allocator: std.mem.Allocator, template: []const u8, map: std.StringHashMap([]const u8)) !String {
    var result = String.init(allocator);

    const ParserState = enum { Text, Symbol };

    var parser_state = ParserState.Text;

    var symbol_buffer = String.init(allocator);
    defer symbol_buffer.deinit();

    for (template) |char| {
        switch (parser_state) {
            .Text => {
                switch (char) {
                    '{' => {
                        symbol_buffer.clear();
                        parser_state = .Symbol;
                    },
                    else => try result.push(char),
                }
            },
            .Symbol => {
                switch (char) {
                    '}' => {
                        if (map.get(symbol_buffer.string)) |symbol| {
                            try result.pushString(symbol);
                        }

                        parser_state = .Text;
                    },
                    else => try symbol_buffer.push(char),
                }
            },
        }
    }

    return result;
}
