###
 * File: io
 * Description: Handles file input/output.
###

'use strict'

# external modules
fs = require 'fs'
path = require 'path'
async = require 'async'

# etml modules
etmlapi = require 'etml-api'

module.exports = (src, dest, options, handleErr) ->

	###
	 * canCompile()
	 * Checks if a filename is able to be compiled
	###
	canCompile = (file) ->
		return path.extname(file) is '.etml' and file.charAt(0) isnt '_'

	###
	 * makeFileObj()
	 * Returns an object with various file properties
	###
	makeFileObj = (file, src, dest) ->

		newFile = file.replace '.etml', '.html'

		fileObj =
			src: path.join src, file
			dest: path.join dest, newFile
			contents: ''
		
		return fileObj

	###
	 * compileFiles()
	 * Loops through an array of file objects and sends
	 * them through the compiler. If the file is successfully
	 * compiled, it is written to the destination file
	###
	compileFiles = (files, options) ->

		async.each files, (file, callback) ->

			fs.readFile file.src, 'utf8', (err, contents) ->
				if err then return handleErr err

				file.contents = contents
				etmlapi.compile file, options, (err, output) ->
					if err then handleErr err

					fs.writeFile file.dest, output, (err) ->
						if err then return handleErr err

						return console.log 'Compiled ' + file.src + ' successfully.'
						callback null

	src = path.normalize src
	dest = path.normalize dest

	# single file
	if path.extname(src)

		files = []
		filename = path.basename src

		if not canCompile filename
			handleErr 'ERROR: Provided source file is not a compilable .etml file'

		# convert file to object and send off to be compiled
		files.push(makeFileObj(filename, path.dirname(src), dest))
		compileFiles files, options

	# directory
	else

		fs.readdir src, (err, files) ->
			if err then handleErr err

			# remove non-compilables
			files = files.filter (file) ->
				return canCompile file

			if not files.length
				handleErr 'ERROR: There are no compilable .etml files in provided destination'

			# convert remaining files to objects
			files = files.map (file) ->
				return makeFileObj(file, src, dest)

			compileFiles files, options