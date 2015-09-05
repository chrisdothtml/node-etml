# File: etml.coffee
# Description: Main file that initiates the file compiler.

'use strict'

fs = require 'fs'
path = require 'path'
compile = require './modules/compile'

src = 'test/src/'
dest = 'test/'

fs.readdir src, (err, files) ->
	if err then throw err

	for file in files

		if path.extname(file) is '.etml' and file.charAt(0) isnt '_'

			# send to compile module
			compile file, src, dest, (err, data) ->
				if err then throw err

				console.log data.srcFile + ' > ' + data.destFile + ' - success!'

	return null