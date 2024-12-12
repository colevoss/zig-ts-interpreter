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
        pipe,

        plus,
        minus,
        asterisk,
        slash,
        gt,
        lt,
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
                        state = .equals;
                    },

                    '+' => {
                        state = .plus;
                    },

                    '+' => {
                        state = .minus;
                    },

                    '*' => {
                        state = .asterisk;
                    },

                    '/' => {
                        state = .slash;
                    },

                    '>' => {
                        state = .gt;
                    },

                    '<' => {
                        state = .lt;
                    },

                    '!' => {
                        state = .bang;
                    },

                    ',' => {
                        token.tag = .comma;
                        self.index += 1;
                        break;
                    },

                    '.' => {
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
                        state = .ampersand;
                    },

                    '|' => {
                        state = .pipe;
                    },

                    else => break,
                },

                // equals
                .equals => switch (char) {
                    '=' => {
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
                        self.index += 1;
                        break;
                    },
                    else => {
                        token.tag = .ampersand;
                        break;
                    },
                },

                .pipe => switch (char) {
                    '|' => {
                        token.tag = .@"or";
                        self.index += 1;
                        break;
                    },
                    else => {
                        token.tag = .pipe;
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
                .int => switch (char) {
                    // TODO: underscore cannot be at the end of a number
                    // TODO: only one underscore is allowed as numberic seperator
                    // TODO: Underscores cannot be used after a leading 0
                    '0'...'9', '_' => {},
                    else => {
                        break;
                    },
                },

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

                else => {},
            }
        }

        token.loc.end = self.index;

        return token;
    }
};
