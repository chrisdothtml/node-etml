###
 * File: compile
 * Description: Handles file i/o and facilitates process methods.
###

'use strict'

# external modules
beautify = require('js-beautify').html
fs = require 'fs'
path = require 'path'

# etml modules
tokenize = require('./tokenize')

module.exports = (srcFilePath, destPath, options, handleErr) ->

	start = new Date()

	fs.readFile srcFilePath, 'utf8', (err, contents) ->
		if err then return handleErr err

		# file properties
		srcPath = path.dirname(srcFilePath) + '\\'
		srcFile = srcFilePath.replace(srcPath, '')
		destFile = srcFile.replace('.etml', '.html')

		# set global variables
		process.globals = globals =
			options: options
			file:
				srcPath: srcPath
				srcFile: srcFile
				destPath: destPath
				destFile: destFile

		# tokenize contents
		tokens = tokenize contents, '', globals.options

		console.log tokens

		# handle tokens
		###handle tokens (err, contents) ->
			if err then return handleErr err
				
			# beautify contents before writing to file
			output = beautify contents,
				globals.options.indent_level
				globals.options.indent_with_tabs
				globals.options.unescape_strings

			fs.writeFile destPath + destFile, contents, (err) ->
				if err then return handleErr err

				end = new Date()

				return console.log 'Compiled ' + destFile + ' in ' + (end.getTime() - start.getTime()) + 'ms'###