const std = @import("std");
const cpu = @import("./cpu.zig");
const memory = @import("./memory.zig");

pub const CPUInfo = cpu.CPUInfo;
pub const MemoryInfo = memory.MemoryInfo;

test {
    std.testing.refAllDecls(cpu);
    std.testing.refAllDecls(memory);
}
