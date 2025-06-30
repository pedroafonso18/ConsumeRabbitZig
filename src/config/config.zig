const std = @import("std");

const Env = struct {
    rabbit_url: []const u8,
    db_url: []const u8,
    db_url_logs: []const u8,
};

pub fn load_env() !Env {
    const allocator = std.heap.page_allocator;

    var env: Env = .{
        .rabbit_url = "",
        .db_url = "",
        .db_url_logs = "",
    };

    const file = std.fs.cwd().openFile(".env", .{}) catch |err| {
        if (err == error.FileNotFound) {
            std.debug.print("Warning: .env file not found\n", .{});
            return env;
        }
        return err;
    };
    defer file.close();

    const content = file.readToEndAlloc(allocator, 1024 * 1024) catch return error.OutOfMemory;
    defer allocator.free(content);

    var lines = std.mem.splitAny(u8, content, "\n");
    while (lines.next()) |line| {
        const trimmed = std.mem.trim(u8, line, " \r\t");
        if (trimmed.len == 0 or trimmed[0] == '#') continue;

        if (std.mem.indexOf(u8, trimmed, "=")) |eq_pos| {
            const key = std.mem.trim(u8, trimmed[0..eq_pos], " ");
            const value = std.mem.trim(u8, trimmed[eq_pos + 1 ..], " \"");

            if (std.mem.eql(u8, key, "RABBIT_URL")) {
                env.rabbit_url = allocator.dupe(u8, value) catch continue;
            } else if (std.mem.eql(u8, key, "DB_URL")) {
                env.db_url = allocator.dupe(u8, value) catch continue;
            } else if (std.mem.eql(u8, key, "DB_URL_LOGS")) {
                env.db_url_logs = allocator.dupe(u8, value) catch continue;
            }
        }
    }

    return env;
}
