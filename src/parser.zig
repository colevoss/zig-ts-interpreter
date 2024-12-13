const std = @import("std");
const Token = @import("token.zig").Token;
const ast = @import("ast.zig");

const expect = std.testing.expect;

const Ast = ast.Ast;
const Node = Ast.Node;

const null_node: Node.Index = 0;

pub const Parser = struct {
    source: []const u8,

    token_tags: []const Token.Tag,
    token_starts: []const Ast.TokenIndex, // ByteOffset??
    token_index: Ast.TokenIndex,
    nodes: Ast.NodeList,

    pub const Error = error{ParseError};

    pub fn init(source: []const u8) Parser {
        return .{
            .source = source,
        };
    }

    pub fn parse(self: *Parser) !void {
        while (true) {
            switch (self.currentTag()) {
                .keyword_const, .keyword_var, .keyword_let => {},
                else => {},
            }
        }
    }

    pub fn parseVarDecl(self: *Parser) !Node.Index {
        const declType = self.eat(.keyword_const) orelse
            self.eat(.keyword_let) orelse
            self.eat(.keyword_var) orelse
            return null_node;

        _ = try self.expectToken(.identifier);

        const type_node: Node.Index = if (self.eat(.colon) != null) try self.expectTypeExpression() else 0;

        return .{
            .tag = .var_decl,
            .token = declType,
            .data = .{
                .lhs = type_node,
                .rhs = 0,
            },
        };
    }

    fn eat(self: *Parser, token: Token.Tag) ?Node.Index {
        if (self.currentTag() != token) {
            return null;
        }

        return self.nextToken();
    }

    inline fn currentTag(self: *Parser) Token.Tag {
        return self.token_tags[self.token_index];
    }

    fn expectToken(self: *Parser, token: Token.Tag) Error!Node.Index {
        if (self.currentTag() == token) {
            return self.eat(token) orelse Error.ParseError;
        }

        return Error.ParseError;
    }

    // Wants next token(s) to be a type
    // TODO: Complex type expressions like unions, intersections, assertions, `is`
    fn expectTypeExpression(self: *Parser) Error!Node.Index {
        const i = self.token_index;
        const nextTag = self.token_tags[i + 1];

        switch (nextTag) {
            .identifier, .keyword_string, .keyword_number, .keyword_boolean => {
                return self.nextToken();
            },
            else => {
                return Error.ParseError;
            },
        }
    }

    fn nextToken(self: *Parser) Node.Index {
        const result = self.token_index;
        self.token_index += 1;
        return result;
    }
};

fn testParser(tokens: []const Token.Tag) Parser {
    return .{
        .source = "",
        .token_tags = tokens,
        .token_starts = &.{},
        .token_index = 0,
        .nodes = .{},
    };
}

test "eat" {
    const tokens: []const Token.Tag = &.{ .keyword_var, .keyword_let, .keyword_const };

    var parser = testParser(tokens);

    try expect(parser.eat(.keyword_var) == 0);
    try expect(parser.eat(.keyword_let) == 1);
    try expect(parser.eat(.keyword_const) == 2);
}

test "currentTag" {
    const tokens: []const Token.Tag = &.{ .keyword_var, .keyword_let, .keyword_const };

    var parser = testParser(tokens);

    try expect(parser.currentTag() == .keyword_var);
    _ = parser.nextToken();
    try expect(parser.currentTag() == .keyword_let);
    _ = parser.nextToken();
    try expect(parser.currentTag() == .keyword_const);
}

test "expectToken returns true when current token is provided and eats token" {
    const tokens: []const Token.Tag = &.{ .keyword_var, .keyword_let, .keyword_const };

    var parser = testParser(tokens);

    try expect(try parser.expectToken(.keyword_var) == 0);
    try expect(parser.currentTag() == .keyword_let);
}

test "expectToken returns error when provided incorrect token tag" {
    const tokens: []const Token.Tag = &.{ .keyword_var, .keyword_let, .keyword_const };
    var parser = testParser(tokens);

    const expected = parser.expectToken(.keyword_let); // should be var
    try std.testing.expectError(Parser.Error.ParseError, expected);
}
