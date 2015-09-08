###
 * File: compile
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

		# escapes
		contents = process.escapes contents

		# comments
		contents = process.comments contents

		# imports
		process.imports contents, (err, contents) ->
			if err then return handleErr err

			# tags
			process.tags contents, (err, contents) ->
				if err then return handleErr err
					
				# beautify output before sending back
				contents = beautify contents,
					indent_level: 1,
					indent_with_tabs: true,
					unescape_strings: true

				fs.writeFile destPath + destFile, contents, (err) ->
					if err then return handleErr err

					end = new Date()

					return console.log 'Compiled '+destFile+' in ' + (end.getTime() - start.getTime()) + 'ms'