const std = @import("std");
const Token = @import("token.zig").Token;

pub const Ast = struct {
    pub const Tag = enum {
        null,
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
};
