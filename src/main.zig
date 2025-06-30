const std = @import("std");
const config = @import("config/config.zig");

pub fn main() !void {
    const env = try config.load_env();
    std.debug.print("DB URL: {s}\n", .{env.db_url});
}
