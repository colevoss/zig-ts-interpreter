const std = @import("std");
const Token = @import("token.zig").Token;
const ast = @import("ast.zig");

const expect = std.testing.expect;

const Ast = ast.Ast;
const Node = Ast.Node;

const null_node: Node.Index = 0;

pub const Parser = struct {
    allocator: std.mem.Allocator,
    source: []const u8,

    token_tags: []const Token.Tag,
    token_starts: []const Ast.TokenIndex, // ByteOffset??
    token_index: Ast.TokenIndex,
    nodes: Ast.NodeList,
    errors: std.ArrayListUnmanaged(Ast.Error),

    pub const Error = error{ ParseError, OutOfMemory };

    pub fn init(source: []const u8) Parser {
        return .{
            .source = source,
        };
    }

    pub fn parse(self: *Parser) !void {
        while (true) {
            const tag = self.currentTag();

            switch (tag) {
                .eof => break,
                .keyword_var,
                .keyword_let,
                .keyword_const,
                => _ = try self.parseVarDecl(),
                else => break,
            }
        }
    }

    pub fn parseVarDecl(self: *Parser) !Node.Index {
        const decl_type = self.eat(.keyword_const) orelse
            self.eat(.keyword_let) orelse
            self.eat(.keyword_var) orelse
            return null_node;

        _ = try self.expectToken(.identifier);

        const decl_i = try self.reserveNode(.var_decl);

        const type_node: Node.Index = if (self.eat(.colon) != null) try self.expectTypeExpression() else 0;
        const value_node: Node.Index = if (self.eat(.assign) != null) try self.expectExpression() else 0;

        // return self.addNode(.{
        return self.setNode(decl_i, .{
            .tag = .var_decl,
            .token = decl_type,
            .data = .{
                .lhs = type_node,
                .rhs = value_node,
            },
        });
    }

    /// Sets node at index
    fn setNode(self: *Parser, i: Node.Index, node: Node) Error!Node.Index {
        self.nodes.set(i, node);
        return i;
    }

    /// Adds a node at the end of the node list
    fn addNode(self: *Parser, node: Node) Error!Node.Index {
        const index = try self.nodes.addOne(self.allocator);
        return self.setNode(@as(Node.Index, @intCast(index)), node);
    }

    /// Creates a spot for a node of `tag` type and returns the index
    fn reserveNode(self: *Parser, tag: Ast.Tag) !Node.Index {
        const reservedIndex = try self.nodes.addOne(self.allocator);
        self.nodes.items(.tag)[reservedIndex] = tag;
        return @as(Node.Index, @intCast(reservedIndex));
    }

    /// If the current token is of `token` tag type, return its index after advancing
    /// the parser index by 1
    pub fn eat(self: *Parser, token: Token.Tag) ?Ast.TokenIndex {
        if (self.currentTag() != token) {
            return null;
        }

        return self.nextToken();
    }

    /// Get the tag of the current token
    inline fn currentTag(self: *Parser) Token.Tag {
        return self.token_tags[self.token_index];
    }

    inline fn nextTag(self: *Parser) Token.Tag {
        return self.token_tags[self.token_index + 1];
    }

    /// Advance the parser token index by one and return the current index
    fn nextToken(self: *Parser) Ast.TokenIndex {
        const result = self.token_index;
        self.token_index += 1;
        return result;
    }

    /// Eat the current token if it exists, otherwise return ParseError
    fn expectToken(self: *Parser, token: Token.Tag) Error!Node.Index {
        if (self.currentTag() == token) {
            return self.eat(token) orelse Error.ParseError;
        }

        return Error.ParseError;
    }

    fn expectExpression(self: *Parser) Error!Node.Index {
        switch (self.currentTag()) {
            .int => {
                return try self.addNode(.{
                    .tag = .number_literal,
                    .token = self.token_index,
                    .data = .{
                        .lhs = 0,
                        .rhs = 0,
                    },
                });
            },
            else => {
                return 0;
            },
        }
    }

    // Wants next token(s) to be a type
    // TODO: Complex type expressions like unions, intersections, assertions, `is`
    // TODO: Types with generics
    fn expectTypeExpression(_: *Parser) Error!Node.Index {
        return 0;
        // const i = self.token_index;
        // const nextTag = self.token_tags[i + 1];
        //
        // switch (nextTag) {
        //     .identifier, .keyword_string, .keyword_number, .keyword_boolean => {
        //         return self.nextToken();
        //     },
        //     else => {
        //         return Error.ParseError;
        //     },
        // }
    }
};

// test "eat" {
//     const tokens: []const Token.Tag = &.{ .keyword_var, .keyword_let, .keyword_const };
//
//     var parser = testParser(tokens);
//
//     try expect(parser.eat(.keyword_var) == 0);
//     try expect(parser.eat(.keyword_let) == 1);
//     try expect(parser.eat(.keyword_const) == 2);
// }
//
// test "currentTag" {
//     const tokens: []const Token.Tag = &.{ .keyword_var, .keyword_let, .keyword_const };
//
//     var parser = testParser(tokens);
//
//     try expect(parser.currentTag() == .keyword_var);
//     _ = parser.nextToken();
//     try expect(parser.currentTag() == .keyword_let);
//     _ = parser.nextToken();
//     try expect(parser.currentTag() == .keyword_const);
// }
//
// test "expectToken returns true when current token is provided and eats token" {
//     const tokens: []const Token.Tag = &.{ .keyword_var, .keyword_let, .keyword_const };
//
//     var parser = testParser(tokens);
//
//     try expect(try parser.expectToken(.keyword_var) == 0);
//     try expect(parser.currentTag() == .keyword_let);
// }
//
// test "expectToken returns error when provided incorrect token tag" {
//     const tokens: []const Token.Tag = &.{ .keyword_var, .keyword_let, .keyword_const };
//     var parser = testParser(tokens);
//
//     const expected = parser.expectToken(.keyword_let); // should be var
//     try std.testing.expectError(Parser.Error.ParseError, expected);
// }
//
// fn testParser(tokens: []const Token.Tag) Parser {
//     return .{
//         .allocator = std.testing.allocator,
//         .source = "",
//         .token_tags = tokens,
//         .token_starts = &.{},
//         .token_index = 0,
//         .nodes = .{},
//     };
// }

test "mal test" {
    const MyList = std.MultiArrayList(struct { a: u32 });
    var myList = MyList{};

    defer myList.deinit(std.testing.allocator);

    try myList.append(std.testing.allocator, .{ .a = 10 });
    try myList.append(std.testing.allocator, .{ .a = 20 });

    var slice = myList.toOwnedSlice();
    defer slice.deinit(std.testing.allocator);

    const t = slice.get(0);

    try expect(t.a == 10);
}
