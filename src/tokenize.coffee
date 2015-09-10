###
 * File: tokenize
 * Description: Takes a string of etml, crawls the source and
 * creates an array of tokens for it. Based off the Jade Lexer.
 * Jade Lexer: https://github.com/jadejs/jade-lexer
###
###
TOKEN TYPES/STRUCTURE

text
	val: String
comment
	escaped: Boolean
	type: String (line, startBlock, endBlock)
include
	escaped: Boolean
	url: String
variable
	escaped: Boolean
	action: String (define, call)
	name: String
	value: String
	scope: String (global, filename)
eos
###

'use strict'

module.exports = (str, filename, options) ->
	tokenizer = new Tokenizer str, filename, options
	return tokenizer.getTokens()

module.exports.Tokenizer = Tokenizer

# Tokenizer()
# Initializes `Tokenizer` with the provided `str`
Tokenizer = (str, filename, options) ->
	str = str.replace /^\uFEFF/, ''

	@options = options
	@input = str.replace /\r\n|\r/g, '\n'
	@origInput = @input
	@filename = filename

	@tokens = []
	@done = false

# Tokenizer prototype
Tokenizer.prototype =
	constructor: Tokenizer

	# warn()
	# Logs a warning message if warning is enabled
	warn: (message) ->
		if @options.warnings
			console.log 'WARNING: ' + message

	# error()
	# Throws an error message
	error: (message) ->
		err = 'ERROR: ' + message
		throw err

	# token()
	# Creates a token with provided type and attributes
	token: (type, attrs) ->
		if attrs?
			return {type: type, attrs: attrs}
		else return {type: type}

	# consume()
	# Removes the matched token so the tokenizer
	# can continue with the rest of the string
	consume: (length) ->

		@input = @input.substr length

	# matches()
	# Checks for matching single/double quotes or
	# curly brackets in expressions
	matches: (expr) ->

		# ""
		if captures = /"[^\n]*/.exec expr
			if not capture = /"[^\n]*"/.exec captures[0]
				@error 'Unmatched double quote "'

		# ''
		if captures = /'[^\n]*/.exec expr
			if not capture = /'[^\n]*'/.exec captures[0]
				@error 'Unmatched single quote \''

		# {}
		if captures = /\{[^\n]*/.exec expr
			if not capture = /\{[^\n]*\}/.exec captures[0]
				@error 'Unmatched curly bracket {'

		return true

	# eos()
	# Decides what happens when the end of the src
	# has been reached
	eos: ->
		if @input.length then return
		@tokens.push @token 'eos'
		@done = true
		return true

	# blank()
	# Blank line
	blank: ->
		if captures = /^\n[ \t]*\n/.exec @input
			@consume captures[0].length - 1
			@tokens.push @token 'text',
				value: '\n'
			return true

	# scripts()
	# Check for script tags since etml syntax is
	# similar to Javascript
	scripts: ->
		if captures = /^<script[\s\S]*\/script>/.exec @input
			@consume captures[0].length
			@tokens.push @token 'text',
				value: captures[0]
			return true

	# comment()
	# Inline and block comments
	comment: ->

		# inline
		# ===

		# \//
		# escaped
		if captures = /^\\\/\//.exec @input
			@consume captures[0].length
			@tokens.push @token 'comment',
				escaped: true
				type: 'line'
			return true

		# //
		# not escaped
		if captures = /^\/\/.*/.exec @input
			@consume captures[0].length
			@tokens.push @token 'comment',
				escaped: false
				type: 'line'
			return true

		# block start
		# ===

		# \/*
		# escaped
		if captures = /^\\\/\*/.exec @input
			@consume captures[0].length
			@tokens.push @token 'comment',
				escaped: true
				type: 'blockStart'
			return true

		# /*
		# not escaped
		if captures = /^\/\*/.exec @input
			@consume captures[0].length
			@tokens.push @token 'comment',
				escaped: false
				type: 'blockStart'
			return true

		# block end
		# ===

		# \*/
		# escaped
		if captures = /^\\\*\//.exec @input
			@consume captures[0].length
			@tokens.push @token 'comment',
				escaped: true
				type: 'blockEnd'
			return true

		# */
		# not escaped
		if captures = /^\*\//.exec @input
			@consume captures[0].length
			@tokens.push @token 'comment',
				escaped: false
				type: 'blockEnd'
			return true

	# include()
	# File includes
	include: ->

		# \@include '';
		# escaped
		if captures = /^\\@include ?['"]([\w\.\/-]*)['"];/.exec @input
			@consume captures[0].length
			@tokens.push @token 'include',
				escaped: true
				url: captures[1]
			return true

		# @include '';
		# not escaped
		if captures = /^@include ?['"]([\w\.\/-]*)['"];?/.exec @input
			@matches captures[0]

			if captures[0].substr(-1) is ';'
				@tokens.push @token 'include',
					escaped: false
					url: captures[1]

			else
				@warn 'Missing semicolon ; for @include'
				@tokens.push @token 'text',
					value: captures[0]
			
			@consume captures[0].length
			return true

	# variableDefine()
	# Variable definitions
	variableDefine: ->

		# \$variable: '';
		# escaped
		if captures = /^\\\$([\w-]+): ?['"]([^'"]*)['"];/.exec @input
			@consume captures[0].length
			@tokens.push @token 'variable',
				escaped: true
				action: 'define'
				name: captures[1]
				value: captures[2]
			return true

		# $variable: '';
		# not escaped
		if captures = /^\$([\w-]+): ?['"]([^'"]*)['"];?/.exec @input
			@matches captures[0]

			if captures[0].substr(-1) is ';'
				@tokens.push @token 'variable',
					escaped: false
					action: 'define'
					name: captures[1]
					value: captures[2]

			else
				@warn 'Missing semicolon ; for variable definition'
				@tokens.push @token 'text',
					value: captures[0]
			
			@consume captures[0].length
			return true

	# variableCall()
	# Variable calls
	variableCall: ->

		# \{$variable}
		# escaped
		if captures = /^\\\{ ?\$([\w-]+) ?\}/.exec @input
			@consume captures[0].length
			@tokens.push @token 'variable',
				escaped: true
				action: 'call'
				name: captures[1]
			return true

		# {$variable}
		# not escaped
		if captures = /^\{ ?\$([\w-]+) ?\}?/.exec @input
			@matches captures[0]

			@consume captures[0].length
			@tokens.push @token 'variable',
				escaped: false
				action: 'call'
				name: captures[1]
			return true

	# text()
	# Regular text (or HTML) that isn't a part
	# of any etml-related expression
	text: ->
		if captures = ///((
			?!\\?\/\/
			|\\?\/\*
			|\\?\*\/
			|\\?@include\s?['"][\w\.\/-]*['"];?
			|\\?\$[\w-]+:\s?['"][^'"]*['"];?
			|\\?\{\$[\w-]+\}?
			|<script
		).)*\n*///.exec @input
			if captures[0].length
				@consume captures[0].length
				@tokens.push @token 'text',
					value: captures[0]
				return true

	# fail()
	# Fails to match any other type
	fail: ->
		console.log @tokens
		@error 'Unexpected text found'

	# advance()
	# Moves to the next token
	advance: ->

		return @eos() or @blank() or @scripts() or @comment() or @include() or @variableDefine() or @variableCall() or @text() or @fail()

	# getTokens()
	# Returns array of tokens for the source
	getTokens: ->
		while not @done then @advance()
		return @tokens