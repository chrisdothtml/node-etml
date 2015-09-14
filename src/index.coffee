###
 * File: index
 * Description: Handles user input.
###

'use strict'

# external modules
bfe = require 'better-fs-errors'

# etml modules
etmlapi = require 'etml-api'
io = require './io'

module.exports =

	###
	 * src()
	 * Used for sending a block of etml through the compiler
	###
	src: (src, options) ->
		file = {contents: src}
		return etmlapi.compile file, options

	###
	 * file()
	 * Used for sending a file or directory of files through
	 * the compiler
	###
	file: (src, dest, options) ->

		handleErr = (err) ->
			if options.bfe?
				if options.bfe is false
					throw err
			throw bfe err

		io src, dest, options, handleErr