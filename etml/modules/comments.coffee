# File: comments.coffee
# Description: Removes inline comments, parses block comments

'use strict'

module.exports = (lines, callback) ->

	newLines = lines.map (line) ->

		# inline comments
		if line.indexOf('//') > -1
			parts = line.split '//'

			# remove if nothing before comment
			if !parts[0].trim() then return false

			# leave only what's before the comment
			return parts[0]

		# block comments
		if line.indexOf('/*') > -1
			line = line.replace '/*', '<!--'

		if line.indexOf('*/') > -1
			line = line.replace '*/', '-->'

		return line

	# remove any lines marked false
	.filter (line) ->
		return line

	callback null, newLines