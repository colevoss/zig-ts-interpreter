const std = @import("std");
const tok = @import("tokenizer.zig");
const Token = @import("Token.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    defer _ = gpa.deinit();

    const file = try std.fs.cwd().openFile("myFile", .{});

    defer file.close();

    const buf = try file.readToEndAlloc(allocator, std.math.maxInt(u32));
    defer allocator.free(buf);

    var tokenizer = tok.Tokenizer.init(buf);

    var token: Token = tokenizer.next();

    while (token.tag != .eof) : (token = tokenizer.next()) {
        std.debug.print("{s} - {}\n", .{ buf[token.loc.start..token.loc.end], token });
    }
}

test {
    _ = tok;
}
