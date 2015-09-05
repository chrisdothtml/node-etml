# File: imports.coffee
# Description: Processes all the @import calls.

'use strict'

fs = require 'fs'
async = require 'async'

module.exports = (fileObj, src, callback) ->

	filterUrl = (url) ->

		# isolate the url parts
		parts = url.split('/')
		newUrl = parts[parts.length - 1]
		filePath = url.replace newUrl, ''

		# optional extention (file > file.etml)
		if newUrl.indexOf('.etml') is -1
			newUrl += '.etml'

		# optional leading underscore (file.etml > _file.etml)
		if newUrl.charAt(0) isnt '_'
			newUrl = '_'+newUrl

		return filePath + newUrl

	asyncRead = (line, _callback) ->
		
		if line.indexOf('@import') > -1

			# find anything surrounding the import
			importRe = /@import\s?['"].*['"]/i;
			wrappers = line.split(importRe).filter (wrapper) ->
				return wrapper.trim()

			# matches file path from import statement
			urlRe = /@import\s?['"](.*)['"]/i;
			url = filterUrl urlRe.exec(line)[1]

			fs.readFile src + url, 'utf8', (err, data) ->
				if err then return _callback err, null

				# re-add any surrounding content
				if wrappers.length is 1
					data = wrappers[0] + data
				else if wrappers.length is 2
					data = wrappers[0] + data + wrappers[1]

				return _callback null, data

			return null

		# if no @import, keep original line content
		return _callback null, line

	# async map so the loop doesn't get
	# ahead of the file reading
	async.map fileObj.lines, asyncRead, (err, data) ->
		if err then return callback err, null

		# join and re-slice for updated lines
		fileObj.lines = data.join('\n').split('\n')

		return callback null, fileObj