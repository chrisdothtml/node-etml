###
 * File: index.coffee
 * Description: Handles source and destination and sends files to compiler.
###

'use strict'

# external modules
fs = require 'fs'
path = require 'path'
errno = require 'errno'

# etml modules
compile = require './compile'

module.exports = (src, dest, options) ->
	src = path.normalize src
	dest = path.normalize dest

	options = options || {}
	useErrno = options.useErrno || true

	handleErr = (err) ->

		if useErrno and errno.code[err.code]
			error = '------------------------------------------------\nRAW ERROR:\n' + err + '\n\nERROR DESCRIPTION:\n' + errno.code[err.code].description + '\n------------------------------------------------'
			throw error

		else throw err

	canCompile = (filename) ->
		return path.extname(filename) is '.etml' and filename.charAt(0) isnt '_'

	# extract path
	if path.extname(dest)
		dest = path.dirname(dest)

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