# File: process.coffee
# Description: The processor. Tells all other modules when to fire.

'use strict'

# process object for readability
process =
	imports: require './imports'
	comments: require './comments'
	tags: require './tags'

module.exports = (lines, src, callback) ->
	
	# send to imports module
	process.imports lines, src, (err, data) ->
		if err then return callback err, null

		# send to comments module
		process.comments data, (err, data) ->
			if err then return callback err, null

			# send to tags module
			process.tags data, (err, data) ->
				if err then return callback err, null

				# remove empty lines
				data = data.filter (line) ->
					return line.trim()
				
				return callback null, data