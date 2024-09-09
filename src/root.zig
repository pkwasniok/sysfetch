const std = @import("std");
const cpu = @import("./cpu.zig");
const memory = @import("./memory.zig");
<<<<<<< HEAD
const os = @import("./os.zig");

pub const CPUInfo = cpu.CPUInfo;
pub const MemoryInfo = memory.MemoryInfo;
pub const OSInfo = os.OSInfo;
=======

pub const CPUInfo = cpu.CPUInfo;
pub const MemoryInfo = memory.MemoryInfo;
>>>>>>> main

test {
    std.testing.refAllDecls(cpu);
    std.testing.refAllDecls(memory);
<<<<<<< HEAD
    std.testing.refAllDecls(os);
=======
>>>>>>> main
}
