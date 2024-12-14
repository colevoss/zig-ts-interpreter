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

        single_quote_string_literal, // "like this"
        double_quote_string_literal, // 'like this'
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

        pub fn str(self: Tag) ?[]const u8 {
            return switch (self) {
                .illegal,
                .eof,
                .identifier,
                .int,
                .float,
                .binary,
                .hex,
                .octal,
                .bigint,
                .exponential,
                .single_quote_string_literal, // "like this"
                .double_quote_string_literal, // 'like this'
                .template_literal, // `like this`
                .inline_comment,
                .block_comment,
                => null,

                .comma => ",",
                .dot => ".",
                .ellipsis => "...",
                .colon => ":",
                .semicolon => ";",
                .question => "?",
                .question_question => "??",
                .question_dot => "?.",
                .plus => "+",
                .increment => "++",
                .minus => "-",
                .decrement => "--",
                .asterisk => "*",
                .exponentiation => "**",
                .slash => "/",
                .backslash => "\\",
                .mod => "%",
                .caret => "^",
                .ampersand => "&",
                .@"and" => "&&",
                .pipe => "|",
                .@"or" => "||",
                .bang => "!",
                .assign => "=",
                .equals => "==",
                .equals_equals => "==",
                .equals_equals_equals => "===",
                .not_equals => "!=",
                .not_equals_equals => "!==",
                .arrow => "=>",
                .plus_equals => "+=",
                .minus_equals => "-=",
                .asterisk_equals => "*=",
                .exponentiation_equals => "**=",
                .slash_equals => "/=",
                .mod_equals => "%=",
                .question_question_equals => "??=",
                .and_equals => "&&=",
                .or_equals => "||=",
                .gt => ">",
                .lt => "<",
                .gt_equals => ">=",
                .lt_equals => "<=",
                .left_paren => "(",
                .right_paren => ")",
                .left_curly => "{",
                .right_curly => "}",
                .left_bracket => "[",
                .right_bracket => "]",
                .double_quote => "\"",
                .single_quote => "'",
                .backtick => "`",

                .keyword_abstract => "abstract",
                .keyword_any => "any",
                .keyword_as => "as",
                .keyword_async => "async",
                .keyword_await => "await",
                .keyword_boolean => "boolean",
                .keyword_break => "break",
                .keyword_continue => "continue",
                .keyword_class => "class",
                .keyword_const => "const",
                .keyword_configurable => "configurable",
                .keyword_constructor => "constructor",
                .keyword_debugger => "debugger",
                .keyword_declare => "declare",
                .keyword_default => "default",
                .keyword_delete => "delete",
                .keyword_do => "do",
                .keyword_enum => "enum",
                .keyword_enumerable => "enumerable",
                .keyword_export => "export",
                .keyword_extends => "extends",
                .keyword_false => "false",
                .keyword_for => "for",
                .keyword_in => "in",
                .keyword_of => "of",
                .keyword_from => "from",
                .keyword_function => "function",
                .keyword_get => "get",
                .keyword_if => "if",
                .keyword_else => "else",
                .keyword_implements => "implements",
                .keyword_import => "import",
                .keyword_instanceof => "instanceof",
                .keyword_interface => "interface",
                .keyword_is => "is",
                .keyword_let => "let",
                .keyword_module => "module",
                .keyword_namespace => "namespace",
                .keyword_never => "never",
                .keyword_new => "new",
                .keyword_null => "null",
                .keyword_number => "number",
                .keyword_private => "private",
                .keyword_protected => "protected",
                .keyword_public => "public",
                .keyword_readonly => "readonly",
                .keyword_require => "require",
                .keyword_return => "return",
                .keyword_set => "set",
                .keyword_static => "static",
                .keyword_string => "string",
                .keyword_super => "super",
                .keyword_switch => "switch",
                .keyword_case => "case",
                .keyword_symbol => "symbol",
                .keyword_this => "this",
                .keyword_true => "true",
                .keyword_try => "try",
                .keyword_catch => "catch",
                .keyword_finally => "finally",
                .keyword_type => "type",
                .keyword_typeof => "typeof",
                .keyword_undefined => "undefined",
                .keyword_value => "value",
                .keyword_var => "var",
                .keyword_void => "void",
                .keyword_while => "while",
                .keyword_writable => "writable",
                .keyword_yield => "yield",
            };
        }
    };
};
