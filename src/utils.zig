pub fn stripFront(text: []u8) []u8 {
    for (text, 0..) |character, index| {
        if (character != ' ') {
            return text[index..];
        }
    }

    return text;
}

pub fn deleteEnd(text: []u8, count: usize) []u8 {
    return text[0 .. text.len - count - 1];
}
