# File: tags.coffee
# Description: Processes non-standard HTML tags.

'use strict'



module.exports = (lines, callback) ->

	newLines = lines.map (line) ->

		#

		# built-in to etml
		#

		return line

	callback null, newLines