const std = @import("std");
const cpu = @import("./cpu.zig");
const memory = @import("./memory.zig");
const os = @import("./os.zig");

pub const CPUInfo = cpu.CPUInfo;
pub const MemoryInfo = memory.MemoryInfo;
pub const OSInfo = os.OSInfo;

test {
    std.testing.refAllDecls(cpu);
    std.testing.refAllDecls(memory);
    std.testing.refAllDecls(os);
}
