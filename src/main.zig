const std = @import("std");
const Tokenizer = @import("tokenizer.zig").Tokenizer;
const Token = @import("token.zig").Token;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    defer _ = gpa.deinit();

    const file = try std.fs.cwd().openFile("myFile", .{});

    defer file.close();

    // const buf = try file.readToEndAlloc(allocator, std.math.maxInt(u32));
    const buf = try file.readToEndAllocOptions(allocator, std.math.maxInt(u32), null, @alignOf(u8), 0);
    defer allocator.free(buf);

    var tokenizer = Tokenizer.init(buf);

    var token: Token = tokenizer.next();

    while (token.tag != .eof) : (token = tokenizer.next()) {
        std.debug.print("{s} - {}\n", .{ buf[token.loc.start..token.loc.end], token });
    }
}

test {
    _ = @import("tokenizer.zig");
    _ = @import("parser.zig");
}
