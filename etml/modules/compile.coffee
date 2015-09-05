# File: compile.coffee
# Description: Handles the file contents before and after being processed.

'use strict'

fs = require 'fs'
process = require './process'

module.exports = (file, src, dest, callback) ->

	fs.readFile src + file, 'utf8', (err, data) ->
		if err then return callback err, null

		# break file lines into array
		lines = data.split '\n'
		newFilename = file.replace('.etml', '') + '.html'

		fileObj =
			lines: lines
			file: file

		# send to process module
		process fileObj, src, (err, fileObj) ->
			if err then return callback err, null

			# lines are reunited, and it feels so good
			output = fileObj.lines.join('\n')

			fs.writeFile dest + newFilename, output, (err) ->
				if err then return callback err, null

				# send word back to the main file to output results
				return callback null, {srcFile: src + file, destFile: dest + newFilename}

		return null