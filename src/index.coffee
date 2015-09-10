###
 * File: index
 * Description: Handles source and destination and sends files to compiler.
###

'use strict'

# external modules
bfe = require 'better-fs-errors'
defaults = require 'defaults'
fs = require 'fs'
path = require 'path'

# etml modules
compile = require './compile'

module.exports = (src, dest, options) ->
	src = path.normalize src
	dest = path.normalize dest

	# setup options
	options: defaults options,
		# etml defaults
		warnings: true
		useBfe: false
		# JS Beautify defaults
		indent_level: 1,
		indent_with_tabs: true,
		unescape_strings: true

	handleErr = (err) ->
		if options.useBfe
			throw bfe err
		throw err

	canCompile = (filename) ->
		return path.extname(filename) is '.etml' and filename.charAt(0) isnt '_'

	# check if dest is a file
	if path.extname(dest)
		handleErr 'Provided destination is not a directory'

	# add trailing slash
	if dest.slice(-1) isnt '\\'
		dest += '\\'

	# if single file
	if path.extname(src)

		if not canCompile src
			handleErr 'Provided source file is not a compilable .etml file'
		
		compile src, dest, options, handleErr

	else

		# compile all etml files in src dir
		fs.readdir src, (err, files) ->
			if err then handleErr err

			# remove non-compilables
			files = files.filter (file) ->
				return canCompile file

			if not files.length
				handleErr 'There are no compilable .etml files in provided destination'

			for file in files
				compile src + file, dest, options, handleErr