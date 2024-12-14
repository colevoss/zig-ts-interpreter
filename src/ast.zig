const std = @import("std");
const Token = @import("token.zig").Token;
const Tokenizer = @import("tokenizer.zig").Tokenizer;
const Parser = @import("parser.zig").Parser;

pub const Ast = struct {
    tokens: TokenList.Slice,
    nodes: NodeList.Slice,
    source: []const u8,
    errors: std.ArrayListUnmanaged(Error).Slice,

    pub const Tag = enum {
        null,
        number_literal,
        annon_function_decl, // function() {}
        function_decl, // function name() {}
        var_decl, // const, let, var
    };

    pub const TokenIndex = u32;
    pub const TokenList = std.MultiArrayList(struct {
        tag: Token.Tag,
        start: u32,
    });
    pub const NodeList = std.MultiArrayList(Node);

    pub const Node = struct {
        tag: Tag,
        token: TokenIndex, // TokenIndex??
        data: Data,

        pub const Data = struct {
            lhs: Index,
            rhs: Index,
        };

        pub const Index = u32;
    };

    pub fn deinit(self: *Ast, allocator: std.mem.Allocator) void {
        self.tokens.deinit(allocator);
        self.nodes.deinit(allocator);
    }

    pub fn tokenEnd(self: *Ast, index: TokenIndex) TokenIndex {
        if (index > self.tokens.len - 1) {
            return index;
        }

        return self.tokens[index + 1].start;
    }

    pub fn tokenStr(self: *Ast, index: TokenIndex) []const u8 {
        return self.source[index..self.tokenEnd(index)];
    }

    pub fn parse(allocator: std.mem.Allocator, source: []const u8) !Ast {
        var tokenizer = Tokenizer.init(source);

        var tokens = TokenList{};

        defer tokens.deinit(allocator);

        while (true) {
            const token = tokenizer.next();

            try tokens.append(allocator, .{
                .tag = token.tag,
                .start = token.loc.start,
            });

            if (token.tag == .eof) {
                break;
            }
        }

        var parser: Parser = .{
            .allocator = allocator,
            .source = source,
            .token_tags = tokens.items(.tag),
            .token_starts = tokens.items(.start),
            .token_index = 0,
            .nodes = .{},
            .errors = std.ArrayListUnmanaged(Error){},
        };

        defer parser.nodes.deinit(allocator);
        defer parser.errors.deinit(allocator);

        try parser.parse();

        return .{
            .source = source,
            .tokens = tokens.toOwnedSlice(),
            .nodes = parser.nodes.toOwnedSlice(),
            .errors = try parser.errors.toOwnedSlice(allocator),
        };
    }

    pub const Error = struct {
        message: []const u8,
        token: TokenIndex,
    };
};

test "parse setup" {
    var ast = try Ast.parse(std.testing.allocator, "");
    defer ast.deinit(std.testing.allocator);

    try std.testing.expect(true);
}
