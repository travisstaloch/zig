const std = @import("std");
const builtin = @import("builtin");

pub fn build(b: *std.Build) void {
    const test_step = b.step("test", "Test it");
    b.default_step = test_step;

    const optimize: std.builtin.OptimizeMode = .Debug;
    const target = b.graph.host;

    if (builtin.os.tag != .windows) return;

    const hello = b.addExecutable(.{
        .name = "hello",
        .root_module = b.createModule(.{
            .root_source_file = b.path("hello.zig"),
            .optimize = optimize,
            .target = target,
        }),
    });

    const main = b.addExecutable(.{
        .name = "main",
        .root_module = b.createModule(.{
            .root_source_file = b.path("main.zig"),
            .optimize = optimize,
            .target = target,
        }),
    });

    main.root_module.linkSystemLibrary("advapi32", .{});

    const run = b.addRunArtifact(main);
    run.addArtifactArg(hello);
    run.expectExitCode(0);
    run.skip_foreign_checks = true;

    test_step.dependOn(&run.step);
}
