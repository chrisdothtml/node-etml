###
 * File: compile.coffee
 * Description: Handles file io and facilitates process methods.
###

'use strict'

# external modules
fs = require 'fs'
path = require 'path'
beautify = require('js-beautify').html

# etml modules
process = require('./process')

module.exports = (srcFilePath, destPath, options, handleErr) ->

	options = options || {}

	fs.readFile srcFilePath, 'utf8', (err, contents) ->
		if err then return handleErr err

		# file properties
		srcPath = path.dirname(srcFilePath) + '\\'
		srcFile = srcFilePath.replace(srcPath, '')
		destFile = srcFile.replace('.etml', '.html')

		process.globals = globals =
			options:
				jsBeautify:
					indent_level: options.indent_level || 1
					indent_with_tabs: options.indent_with_tabs || true
					#unescape_strings: options.unescape_strings || true
			file:
				srcPath: srcPath
				srcFile: srcFile
				destPath: destPath
				destFile: destFile

		# escapes
		contents = process.escapes contents

		# comments
		contents = process.comments contents

		# imports
		process.imports contents, (err, contents) ->
			if err then return handleErr err

			# escapes (second time in case imported files have escapes)
			contents = process.escapes contents

			# comments (second time in case imported files have comments)
			contents = process.comments contents

			# tags
			process.tags contents, (err, contents) ->
				if err then return handleErr err
					
				# beautify output before sending back
				contents = beautify contents, globals.options.jsBeautify

				fs.writeFile destPath + destFile, contents, (err) ->
					if err then return handleErr err

					return console.log 'Compiled "'+destFile+'" successfully'