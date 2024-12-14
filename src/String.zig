const std = @import("std");
const ast = @import("ast.zig");

const PrintError = error{PrintErrorIGuess};

pub fn renderAst(buffer: *std.ArrayList(u8), tree: ast.Ast) !void {
    var node_index: u32 = 0;

    const writer = buffer.writer();

    while (true) : (node_index += 1) {
        const node = tree.nodes.get(node_index);

        switch (node.tag) {
            .var_decl => try printVarDecl(writer, tree, node),
            else => break,
        }
    }
}

pub fn tokenEnd(tree: ast.Ast, index: ast.Ast.TokenIndex) ast.Ast.TokenIndex {
    const i = if (index >= tree.tokens.len - 1) index else index + 1;

    return tree.tokens.get(i).start;
}

pub fn tokenStr(tree: ast.Ast, index: ast.Ast.TokenIndex) []const u8 {
    const token = tree.tokens.get(index);
    return tree.source[token.start..tokenEnd(tree, index)];
}

// TODO: Handle type declarations
fn printVarDecl(writer: anytype, tree: ast.Ast, node: ast.Ast.Node) !void {
    const tok_i = node.token;
    const token = tree.tokens.get(tok_i);

    const expr_node_i = node.data.rhs;
    const expr_node = tree.nodes.get(expr_node_i);

    const declType = token.tag.str() orelse return PrintError.PrintErrorIGuess;
    const declName = tokenStr(tree, tok_i + 1);
    const declExpression = tokenStr(tree, expr_node.token);

    // TODO: Fix the way we get identifier names so it doesn't include the trailing space
    return writer.print("{s} {s}= {s};", .{ declType, declName, declExpression });
}

test "printVarDecl" {
    var tree = try ast.Ast.parse(std.testing.allocator, "const foo = 1;");
    defer tree.deinit(std.testing.allocator);

    var buffer = std.ArrayList(u8).init(std.testing.allocator);
    defer buffer.deinit();
    try renderAst(&buffer, tree);

    try std.testing.expect(std.mem.eql(u8, "const foo = 1;", buffer.items));
}
