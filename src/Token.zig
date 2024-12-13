const std = @import("std");

pub const Token = struct {
    tag: Tag,
    loc: Location,

    pub const Location = struct {
        start: u32,
        end: u32,
    };

    pub const keywords = std.StaticStringMap(Tag).initComptime(.{
        .{ "abstract", .keyword_abstract },
        .{ "any", .keyword_any },
        .{ "as", .keyword_as },
        .{ "async", .keyword_async },
        .{ "await", .keyword_await },
        .{ "boolean", .keyword_boolean },
        .{ "break", .keyword_break },
        .{ "continue", .keyword_continue },
        .{ "class", .keyword_class },
        .{ "const", .keyword_const },
        .{ "configurable", .keyword_configurable },
        .{ "constructor", .keyword_constructor },
        .{ "debugger", .keyword_debugger },
        .{ "declare", .keyword_declare },
        .{ "default", .keyword_default },
        .{ "delete", .keyword_delete },
        .{ "do", .keyword_do },
        .{ "enum", .keyword_enum },
        .{ "enumerable", .keyword_enumerable },
        .{ "export", .keyword_export },
        .{ "extends", .keyword_extends },
        .{ "false", .keyword_false },
        .{ "for", .keyword_for },
        .{ "in", .keyword_in },
        .{ "of", .keyword_of },
        .{ "from", .keyword_from },
        .{ "function", .keyword_function },
        .{ "get", .keyword_get },
        .{ "if", .keyword_if },
        .{ "else", .keyword_else },
        .{ "implements", .keyword_implements },
        .{ "import", .keyword_import },
        .{ "instanceof", .keyword_instanceof },
        .{ "interface", .keyword_interface },
        .{ "is", .keyword_is },
        .{ "let", .keyword_let },
        .{ "module", .keyword_module },
        .{ "namespace", .keyword_namespace },
        .{ "never", .keyword_never },
        .{ "new", .keyword_new },
        .{ "null", .keyword_null },
        .{ "number", .keyword_number },
        .{ "private", .keyword_private },
        .{ "protected", .keyword_protected },
        .{ "public", .keyword_public },
        .{ "readonly", .keyword_readonly },
        .{ "require", .keyword_require },
        .{ "return", .keyword_return },
        .{ "set", .keyword_set },
        .{ "static", .keyword_static },
        .{ "string", .keyword_string },
        .{ "super", .keyword_super },
        .{ "switch", .keyword_switch },
        .{ "case", .keyword_case },
        .{ "symbol", .keyword_symbol },
        .{ "this", .keyword_this },
        .{ "true", .keyword_true },
        .{ "try", .keyword_try },
        .{ "catch", .keyword_catch },
        .{ "finally", .keyword_finally },
        .{ "type", .keyword_type },
        .{ "typeof", .keyword_typeof },
        .{ "undefined", .keyword_undefined },
        .{ "value", .keyword_value },
        .{ "var", .keyword_var },
        .{ "void", .keyword_void },
        .{ "while", .keyword_while },
        .{ "writable", .keyword_writable },
        .{ "yield", .keyword_yield },
    });

    pub const Tag = enum {
        illegal,
        eof,

        identifier,

        // numbers
        int,
        float,
        binary,
        hex,
        octal,
        bigint,
        exponential,

        comma, // ,

        dot, // .
        ellipsis, // ...

        colon, // :
        semicolon, // ;

        single_quote_string, // "like this"
        double_quote_string, // 'like this'
        template_literal, // `like this`

        question, // ?
        question_question, // ??
        question_dot, // ?.

        plus, // +
        increment, // ++
        minus, // -
        decrement, // --
        asterisk, // *
        exponentiation, // **
        slash, // /
        backslash,
        mod, // %
        caret, // ^

        ampersand,
        @"and", // &&
        pipe, // |
        @"or", // ||

        inline_comment,
        block_comment,

        bang, // !
        assign, // =
        equals, // ==
        equals_equals, // ==
        equals_equals_equals, // ===
        not_equals, // !=
        not_equals_equals, // !==
        arrow, // =>

        plus_equals, // +=
        minus_equals, // -=
        asterisk_equals, // *=
        exponentiation_equals, // **=
        slash_equals, // /=
        mod_equals, // %=
        question_question_equals, // ??=
        and_equals, // &&=
        or_equals, // ||=

        gt, // >
        lt, // <
        gt_equals, // >=
        lt_equals, // <=

        // TODO: Binary operators

        // ()
        left_paren,
        right_paren,

        // {}
        left_curly,
        right_curly,

        // []
        left_bracket,
        right_bracket,

        double_quote, // "
        single_quote, // '
        backtick, // `

        keyword_abstract,
        keyword_any,
        keyword_as,
        keyword_async,
        keyword_await,
        keyword_boolean,
        keyword_break,
        keyword_continue,
        keyword_class,
        keyword_const,
        keyword_configurable,
        keyword_constructor,
        keyword_debugger,
        keyword_declare,
        keyword_default,
        keyword_delete,
        keyword_do,
        keyword_enum,
        keyword_enumerable,
        keyword_export,
        keyword_extends,
        keyword_false,
        keyword_for,
        keyword_in,
        keyword_of,
        keyword_from,
        keyword_function,
        keyword_get,
        keyword_if,
        keyword_else,
        keyword_implements,
        keyword_import,
        keyword_instanceof,
        keyword_interface,
        keyword_is,
        keyword_let,
        keyword_module,
        keyword_namespace,
        keyword_never,
        keyword_new,
        keyword_null,
        keyword_number,
        keyword_private,
        keyword_protected,
        keyword_public,
        keyword_readonly,
        keyword_require,
        keyword_return,
        keyword_set,
        keyword_static,
        keyword_string,
        keyword_super,
        keyword_switch,
        keyword_case,
        keyword_symbol,
        keyword_this,
        keyword_true,
        keyword_try,
        keyword_catch,
        keyword_finally,
        keyword_type,
        keyword_typeof,
        keyword_undefined,
        keyword_value,
        keyword_var,
        keyword_void,
        keyword_while,
        keyword_writable,
        keyword_yield,
    };
};
