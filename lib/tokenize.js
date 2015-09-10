/*
 * File: tokenize
 * Description: Takes a string of etml, crawls the source and
 * creates an array of tokens for it. Based off the Jade Lexer.
 * Jade Lexer: https://github.com/jadejs/jade-lexer
 */
'use strict';
var Tokenizer;

module.exports = function (str, filename, options) {
	var tokenizer;
	tokenizer = new Tokenizer(str, filename, options);
	return tokenizer.getTokens();
};

module.exports.Tokenizer = Tokenizer;

Tokenizer = function (str, filename, options) {
	str = str.replace(/^\uFEFF/, '');
	this.options = options;
	this.input = str.replace(/\r\n|\r/g, '\n');
	this.origInput = this.input;
	this.filename = filename;
	this.tokens = [];
	return this.done = false;
};

Tokenizer.prototype = {
	constructor: Tokenizer,
	warn: function (message) {
		if (this.options.warnings) {
			return console.log('WARNING: ' + message);
		}
	},
	error: function (message) {
		var err;
		err = 'ERROR: ' + message;
		throw err;
	},
	token: function (type, attrs) {
		if (attrs != null) {
			return {
				type: type,
				attrs: attrs
			};
		} else {
			return {
				type: type
			};
		}
	},
	consume: function (length) {
		return this.input = this.input.substr(length);
	},
	matches: function (expr) {
		var capture, captures;
		if (captures = /"[^\n]*/.exec(expr)) {
			if (!(capture = /"[^\n]*"/.exec(captures[0]))) {
				this.error('Unmatched double quote "');
			}
		}
		if (captures = /'[^\n]*/.exec(expr)) {
			if (!(capture = /'[^\n]*'/.exec(captures[0]))) {
				this.error('Unmatched single quote \'');
			}
		}
		if (captures = /\{[^\n]*/.exec(expr)) {
			if (!(capture = /\{[^\n]*\}/.exec(captures[0]))) {
				this.error('Unmatched curly bracket {');
			}
		}
		return true;
	},
	eos: function () {
		if (this.input.length) {
			return;
		}
		this.tokens.push(this.token('eos'));
		this.done = true;
		return true;
	},
	blank: function () {
		var captures;
		if (captures = /^\n[ \t]*\n/.exec(this.input)) {
			this.consume(captures[0].length - 1);
			this.tokens.push(this.token('text', {
				value: '\n'
			}));
			return true;
		}
	},
	scripts: function () {
		var captures;
		if (captures = /^<script[\s\S]*\/script>/.exec(this.input)) {
			this.consume(captures[0].length);
			this.tokens.push(this.token('text', {
				value: captures[0]
			}));
			return true;
		}
	},
	comment: function () {
		var captures;
		if (captures = /^\\\/\//.exec(this.input)) {
			this.consume(captures[0].length);
			this.tokens.push(this.token('comment', {
				escaped: true,
				type: 'line'
			}));
			return true;
		}
		if (captures = /^\/\/.*/.exec(this.input)) {
			this.consume(captures[0].length);
			this.tokens.push(this.token('comment', {
				escaped: false,
				type: 'line'
			}));
			return true;
		}
		if (captures = /^\\\/\*/.exec(this.input)) {
			this.consume(captures[0].length);
			this.tokens.push(this.token('comment', {
				escaped: true,
				type: 'blockStart'
			}));
			return true;
		}
		if (captures = /^\/\*/.exec(this.input)) {
			this.consume(captures[0].length);
			this.tokens.push(this.token('comment', {
				escaped: false,
				type: 'blockStart'
			}));
			return true;
		}
		if (captures = /^\\\*\//.exec(this.input)) {
			this.consume(captures[0].length);
			this.tokens.push(this.token('comment', {
				escaped: true,
				type: 'blockEnd'
			}));
			return true;
		}
		if (captures = /^\*\//.exec(this.input)) {
			this.consume(captures[0].length);
			this.tokens.push(this.token('comment', {
				escaped: false,
				type: 'blockEnd'
			}));
			return true;
		}
	},
	include: function () {
		var captures;
		if (captures = /^\\@include ?['"]([\w\.\/-]*)['"];/.exec(this.input)) {
			this.consume(captures[0].length);
			this.tokens.push(this.token('include', {
				escaped: true,
				url: captures[1]
			}));
			return true;
		}
		if (captures = /^@include ?['"]([\w\.\/-]*)['"];?/.exec(this.input)) {
			this.matches(captures[0]);
			if (captures[0].substr(-1) === ';') {
				this.tokens.push(this.token('include', {
					escaped: false,
					url: captures[1]
				}));
			} else {
				this.warn('Missing semicolon ; for @include');
				this.tokens.push(this.token('text', {
					value: captures[0]
				}));
			}
			this.consume(captures[0].length);
			return true;
		}
	},
	variableDefine: function () {
		var captures;
		if (captures = /^\\\$([\w-]+): ?['"]([^'"]*)['"];/.exec(this.input)) {
			this.consume(captures[0].length);
			this.tokens.push(this.token('variable', {
				escaped: true,
				action: 'define',
				name: captures[1],
				value: captures[2]
			}));
			return true;
		}
		if (captures = /^\$([\w-]+): ?['"]([^'"]*)['"];?/.exec(this.input)) {
			this.matches(captures[0]);
			if (captures[0].substr(-1) === ';') {
				this.tokens.push(this.token('variable', {
					escaped: false,
					action: 'define',
					name: captures[1],
					value: captures[2]
				}));
			} else {
				this.warn('Missing semicolon ; for variable definition');
				this.tokens.push(this.token('text', {
					value: captures[0]
				}));
			}
			this.consume(captures[0].length);
			return true;
		}
	},
	variableCall: function () {
		var captures;
		if (captures = /^\\\{ ?\$([\w-]+) ?\}/.exec(this.input)) {
			this.consume(captures[0].length);
			this.tokens.push(this.token('variable', {
				escaped: true,
				action: 'call',
				name: captures[1]
			}));
			return true;
		}
		if (captures = /^\{ ?\$([\w-]+) ?\}?/.exec(this.input)) {
			this.matches(captures[0]);
			this.consume(captures[0].length);
			this.tokens.push(this.token('variable', {
				escaped: false,
				action: 'call',
				name: captures[1]
			}));
			return true;
		}
	},
	text: function () {
		var captures;
		if (captures = /((?!\\?\/\/|\\?\/\*|\\?\*\/|\\?@include\s?['"][\w\.\/-]*['"];?|\\?\$[\w-]+:\s?['"][^'"]*['"];?|\\?\{\$[\w-]+\}?|<script).)*\n*/.exec(this.input)) {
			if (captures[0].length) {
				this.consume(captures[0].length);
				this.tokens.push(this.token('text', {
					value: captures[0]
				}));
				return true;
			}
		}
	},
	fail: function () {
		console.log(this.tokens);
		return this.error('Unexpected text found');
	},
	advance: function () {
		return this.eos() || this.blank() || this.scripts() || this.comment() || this.include() || this.variableDefine() || this.variableCall() || this.text() || this.fail();
	},
	getTokens: function () {
		while (!this.done) {
			this.advance();
		}
		return this.tokens;
	}
};