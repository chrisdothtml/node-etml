# File: process.coffee
# Description: The processor. Tells all other modules when to fire.

'use strict'

# process object for readability
process =
	imports: require './imports'
	comments: require './comments'
	tags: require './tags'

module.exports = (fileObj, src, callback) ->
	
	# send to imports module
	process.imports fileObj, src, (err, fileObj) ->
		if err then return callback err, null

		# send to comments module
		process.comments fileObj, (err, fileObj) ->
			if err then return callback err, null

			# send to tags module
			process.tags fileObj, (err, fileObj) ->
				if err then return callback err, null

				# remove empty lines
				fileObj.lines = fileObj.lines.filter (line) ->
					return line.trim()
				
				return callback null, fileObj