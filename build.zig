const std = @import("std");

pub fn build(b: *std.Build) void {
    // Standard build target options
    const target = b.standardTargetOptions(.{});

    // Standard build optimization options
    const optimize = b.standardOptimizeOption(.{});

    const package = b.dependency("zig-containers", .{
        .target = target,
        .optimize = optimize,
    });

    const module = package.module("containers");

    // Define executable
    const exe = b.addExecutable(.{
        .name = "sysfetch",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    exe.root_module.addImport("containers", module);

    // Add executable to build
    b.installArtifact(exe);

    // Add executable to run
    const run_exe = b.addRunArtifact(exe);

    // Define run step
    const run_step = b.step("run", "Run the application");
    run_step.dependOn(&run_exe.step);
}
