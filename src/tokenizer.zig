const std = @import("std");
const Token = @import("Token.zig");
const expect = std.testing.expect;

const logger = std.log.scoped(.tokenizer);

pub const Tokenizer = struct {
    buf: []const u8,
    index: u32,

    const State = enum {
        start,

        int,
        octal,

        identifier,

        equals,
        equals_equals,

        bang,
        bang_equals,

        dot,
        dot_dot,

        double_quote_string,
        single_quote_string,
        template_literal,

        ampersand,
        @"and",
        pipe,
        @"or",

        plus,
        minus,
        asterisk,
        exponentiation,
        slash,
        percent,
        question,
        question_question,
        gt,
        lt,

        inline_comment,
        block_comment,
        block_comment_asterisk, // /* block comment need to be in this state to find slash to end ->*
    };

    pub fn init(buf: []const u8) Tokenizer {
        return .{
            .buf = buf,
            .index = 0,
        };
    }

    pub fn next(self: *Tokenizer) Token {
        var token = Token{
            .tag = .eof,
            .loc = .{
                .start = self.index,
                .end = self.index,
            },
        };

        var state: State = State.start;

        while (self.index < self.buf.len) : (self.index += 1) {
            const char = self.buf[self.index];

            switch (state) {
                // single character tokens need to increment index to its loc.end is the next index
                // for the purposes of end being exclusive
                .start => switch (char) {
                    0 => break,
                    'a'...'z',
                    'A'...'Z',
                    '_',
                    '$',
                    '#', // # can only prefix an identifier in a class but its still a valid identifier token
                    => {
                        state = .identifier;
                        token.tag = .identifier;
                    },

                    // TODO: Support other number types
                    '0'...'9' => {
                        state = .int;
                        token.tag = .int;
                    },

                    '\n',
                    ' ',
                    '\t',
                    => {
                        token.loc.start += 1;
                    },

                    ';' => {
                        token.tag = .semicolon;
                        self.index += 1;
                        break;
                    },
                    ':' => {
                        token.tag = .colon;
                        self.index += 1;
                        break;
                    },

                    // parens
                    '(' => {
                        token.tag = .left_paren;
                        self.index += 1;
                        break;
                    },
                    ')' => {
                        token.tag = .right_paren;
                        self.index += 1;
                        break;
                    },

                    // curlys
                    '{' => {
                        token.tag = .left_curly;
                        self.index += 1;
                        break;
                    },
                    '}' => {
                        token.tag = .right_curly;
                        self.index += 1;
                        break;
                    },

                    // brackets
                    '[' => {
                        token.tag = .left_bracket;
                        self.index += 1;
                        break;
                    },
                    ']' => {
                        token.tag = .right_bracket;
                        self.index += 1;
                        break;
                    },

                    '=' => {
                        token.tag = .assign;
                        state = .equals;
                    },

                    '+' => {
                        token.tag = .plus;
                        state = .plus;
                    },

                    '-' => {
                        token.tag = .minus;
                        state = .minus;
                    },

                    '*' => {
                        token.tag = .asterisk;
                        state = .asterisk;
                    },

                    '%' => {
                        token.tag = .mod;
                        state = .percent;
                    },

                    '/' => {
                        token.tag = .slash;
                        state = .slash;
                    },

                    '>' => {
                        token.tag = .gt;
                        state = .gt;
                    },

                    '<' => {
                        token.tag = .lt;
                        state = .lt;
                    },

                    '!' => {
                        token.tag = .bang;
                        state = .bang;
                    },

                    ',' => {
                        token.tag = .comma;
                        self.index += 1;
                        break;
                    },

                    '.' => {
                        token.tag = .dot;
                        state = .dot;
                    },

                    '"' => {
                        state = .double_quote_string;
                        token.tag = .double_quote_string;
                    },

                    '\'' => {
                        state = .single_quote_string;
                        token.tag = .single_quote_string;
                    },

                    '&' => {
                        token.tag = .ampersand;
                        state = .ampersand;
                    },

                    '|' => {
                        token.tag = .pipe;
                        state = .pipe;
                    },

                    '?' => {
                        token.tag = .question;
                        state = .question;
                    },

                    else => break,
                },

                // equals
                .equals => switch (char) {
                    '=' => {
                        token.tag = .equals_equals;
                        state = .equals_equals;
                    },
                    '>' => {
                        token.tag = .arrow;
                        self.index += 1;
                        break;
                    },
                    else => {
                        token.tag = .assign;
                        break;
                    },
                },
                .equals_equals => switch (char) {
                    '=' => {
                        token.tag = .equals_equals_equals;
                        self.index += 1;
                        break;
                    },
                    else => {
                        token.tag = .equals_equals;
                        break;
                    },
                },

                // bang
                .bang => switch (char) {
                    '=' => {
                        token.tag = .not_equals;
                        state = .bang_equals;
                    },
                    else => {
                        token.tag = .bang;
                        break;
                    },
                },
                .bang_equals => switch (char) {
                    '=' => {
                        token.tag = .not_equals_equals;
                        self.index += 1;
                        break;
                    },
                    else => {
                        token.tag = .not_equals;
                        break;
                    },
                },

                // dot
                .dot => switch (char) {
                    '.' => {
                        token.tag = .illegal;
                        state = .dot_dot;
                    },
                    else => {
                        token.tag = .dot;
                        break;
                    },
                },
                .dot_dot => switch (char) {
                    '.' => {
                        token.tag = .ellipsis;
                        self.index += 1;
                        break;
                    },
                    else => {
                        token.tag = .illegal;
                        break;
                    },
                },

                .ampersand => switch (char) {
                    '&' => {
                        token.tag = .@"and";
                        state = .@"and";
                    },
                    else => {
                        token.tag = .ampersand;
                        break;
                    },
                },
                .@"and" => switch (char) {
                    '=' => {
                        token.tag = .and_equals;
                        self.index += 1;
                        break;
                    },
                    else => {
                        token.tag = .@"and";
                        break;
                    },
                },

                .pipe => switch (char) {
                    '|' => {
                        token.tag = .@"or";
                        state = .@"or";
                    },
                    else => {
                        token.tag = .pipe;
                        break;
                    },
                },

                .@"or" => switch (char) {
                    '=' => {
                        token.tag = .or_equals;
                        self.index += 1;
                        break;
                    },
                    else => {
                        token.tag = .@"or";
                        break;
                    },
                },

                .plus => switch (char) {
                    '+' => {
                        token.tag = .increment;
                        self.index += 1;
                        break;
                    },
                    '=' => {
                        token.tag = .plus_equals;
                        self.index += 1;
                        break;
                    },
                    else => {
                        token.tag = .plus;
                        break;
                    },
                },

                .minus => switch (char) {
                    '-' => {
                        token.tag = .decrement;
                        self.index += 1;
                        break;
                    },
                    '=' => {
                        token.tag = .minus_equals;
                        self.index += 1;
                        break;
                    },
                    else => {
                        token.tag = .minus;
                        break;
                    },
                },

                .asterisk => switch (char) {
                    '*' => {
                        token.tag = .exponentiation;
                        state = .exponentiation;
                    },
                    '=' => {
                        token.tag = .asterisk_equals;
                        self.index += 1;
                        break;
                    },
                    else => {
                        token.tag = .asterisk;
                        break;
                    },
                },

                .exponentiation => switch (char) {
                    '=' => {
                        token.tag = .exponentiation_equals;
                        self.index += 1;
                        break;
                    },
                    else => {
                        token.tag = .exponentiation;
                        break;
                    },
                },

                .slash => switch (char) {
                    '=' => {
                        token.tag = .slash_equals;
                        self.index += 1;
                        break;
                    },
                    '/' => {
                        token.tag = .inline_comment;
                        state = .inline_comment;
                    },
                    '*' => {
                        token.tag = .block_comment;
                        state = .block_comment;
                    },
                    else => {
                        token.tag = .slash;
                        break;
                    },
                },

                .percent => switch (char) {
                    '=' => {
                        token.tag = .mod_equals;
                        self.index += 1;
                        break;
                    },
                    else => {
                        token.tag = .mod;
                        break;
                    },
                },

                .gt => switch (char) {
                    '=' => {
                        token.tag = .gt_equals;
                        self.index += 1;
                        break;
                    },
                    else => {
                        token.tag = .gt;
                        break;
                    },
                },

                .lt => switch (char) {
                    '=' => {
                        token.tag = .lt_equals;
                        self.index += 1;
                        break;
                    },
                    else => {
                        token.tag = .lt;
                        break;
                    },
                },

                .question => switch (char) {
                    '?' => {
                        token.tag = .question_question;
                        state = .question_question;
                    },
                    '.' => {
                        token.tag = .question_dot;
                        self.index += 1;
                        break;
                    },
                    else => {
                        token.tag = .question;
                        break;
                    },
                },

                .question_question => switch (char) {
                    '=' => {
                        token.tag = .question_question_equals;
                        self.index += 1;
                        break;
                    },
                    else => {
                        token.tag = .question_question;
                        break;
                    },
                },

                .identifier => switch (char) {
                    'a'...'z',
                    'A'...'Z',
                    '0'...'9',
                    '_',
                    '$',
                    => {},
                    else => {
                        if (Token.keywords.get(self.buf[token.loc.start..self.index])) |keyword| {
                            token.tag = keyword;
                        }

                        break;
                    },
                },

                // numbers
                .int => switch (char) {
                    // TODO: underscore cannot be at the end of a number
                    // TODO: only one underscore is allowed as numberic seperator
                    // TODO: Underscores cannot be used after a leading 0
                    '0'...'9', '_' => {},
                    else => {
                        break;
                    },
                },

                // strings
                .double_quote_string => switch (char) {
                    '"' => {
                        self.index += 1;
                        break;
                    },
                    else => {},
                },

                .single_quote_string => switch (char) {
                    '\'' => {
                        self.index += 1;
                        break;
                    },
                    else => {},
                },

                // comments
                .inline_comment => switch (char) {
                    '\n' => {
                        token.tag = .inline_comment;
                        // we do not take the next index so we don't include new line in comment
                        break;
                    },
                    else => {},
                },

                .block_comment => switch (char) {
                    '*' => {
                        state = .block_comment_asterisk;
                    },
                    else => {},
                },

                .block_comment_asterisk => switch (char) {
                    '/' => {
                        token.tag = .block_comment;
                        self.index += 1;
                        break;
                    },
                    '*' => {},
                    else => {
                        state = .block_comment;
                    },
                },
                else => {},
            }
        }

        token.loc.end = self.index;

        return token;
    }
};

fn testCode(code: []const u8, tags: []const Token.Tag, debug: bool) !void {
    var tokenizer = Tokenizer.init(code);

    for (tags) |tag| {
        const token = tokenizer.next();

        if (debug) {
            std.debug.print("expected {s}, got {s} `{s}` at {d}-{d}\n", .{
                @tagName(tag),
                @tagName(token.tag),
                code[token.loc.start..token.loc.end],
                token.loc.start,
                token.loc.end,
            });
        }

        try expect(token.tag == tag);
    }
}

test "ampersands" {
    const code = "& && &&=";

    try testCode(code, &.{ .ampersand, .@"and", .and_equals }, false);
}

test "pipes" {
    const code = "| || ||=";

    try testCode(code, &.{ .pipe, .@"or", .or_equals }, false);
}

test "equals" {
    const code = "= == ===";

    try testCode(code, &.{ .assign, .equals_equals, .equals_equals_equals }, false);
}

test "bang" {
    const code = "! != !==";

    try testCode(code, &.{ .bang, .not_equals, .not_equals_equals }, false);
}

test "dots" {
    const code = ". .. ...";

    try testCode(code, &.{ .dot, .illegal, .ellipsis }, false);
}

test "symbols" {
    const code = ";:(){}[],";
    try testCode(code, &.{
        .semicolon,
        .colon,
        .left_paren,
        .right_paren,
        .left_curly,
        .right_curly,
        .left_bracket,
        .right_bracket,
        .comma,
    }, false);
}

test "plus" {
    const code = "+ ++ +=";

    try testCode(code, &.{ .plus, .increment, .plus_equals }, false);
}

test "minus" {
    const code = "- -- -=";

    try testCode(code, &.{ .minus, .decrement, .minus_equals }, false);
}

test "percent" {
    const code = "% %=";

    try testCode(code, &.{ .mod, .mod_equals }, false);
}

test "asterisk" {
    const code = "* *= ** **=";
    try testCode(code, &.{
        .asterisk,
        .asterisk_equals,
        .exponentiation,
        .exponentiation_equals,
    }, false);
}

test "slash" {
    const code = "/ /=";
    try testCode(code, &.{ .slash, .slash_equals }, false);
}

test "gt" {
    const code = "> >=";

    try testCode(code, &.{ .gt, .gt_equals }, false);
}

test "lt" {
    const code = "< <=";

    try testCode(code, &.{ .lt, .lt_equals }, false);
}

test "inline comments" {
    // has extra line to test that inline comment ends on newline
    const code =
        \\// hello
        \\/
    ;
    try testCode(code, &.{ .inline_comment, .slash }, false);
}

test "block comments" {
    const code =
        \\ /* this is a block comment */
        \\ /**
        \\   * this is also a block comment
        \\   */
    ;

    try testCode(code, &.{ .block_comment, .block_comment }, false);
}

test "questions" {
    const code = "? ?. ?? ??=";

    try testCode(code, &.{ .question, .question_dot, .question_question, .question_question_equals }, false);
}

test "strings" {
    const code =
        \\"foo"
        \\'bar'
    ;

    try testCode(code, &.{ .double_quote_string, .single_quote_string }, true);
}
