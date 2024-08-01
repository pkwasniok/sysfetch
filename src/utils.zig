const std = @import("std");

pub fn stripFront(text: []u8) []u8 {
    for (text, 0..) |character, index| {
        if (!std.ascii.isWhitespace(character)) {
            return text[index..];
        }
    }

    return text;
}

pub fn stripBack(text: []u8) []u8 {
    var i = text.len - 1;

    while (i >= 0) {
        if (!std.ascii.isWhitespace(text[i])) {
            return text[0 .. i + 1];
        }

        i -= 1;
    }

    return text;
}

pub fn deleteEnd(text: []u8, count: usize) []u8 {
    return text[0 .. text.len - count - 1];
}
