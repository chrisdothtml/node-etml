# File: tags.coffee
# Description: Processes non-standard HTML tags.

'use strict'

cheerio = require 'cheerio'

module.exports = (fileObj, callback) ->
	$ = cheerio.load fileObj.lines.join '\n'

	tags =
		type: ($tag) ->
			return $tag[0].name
		obj: ($tag) ->
			return $tag.get()[0]
	
	# built-in etml tags
	$('css, js').each ->
		type = tags.type $(@)
		url = $(@).attr('url')
		attrs = tags.obj($(@)).attribs

		if not $(@).attr 'url'
			return callback type+' tags require `url` attribute ('+fileObj.file+')', null

		if type is 'css' then $newTag = $('<link>', {rel: 'stylesheet', href: url})
		else if type is 'js' then $newTag = $('<script>', {src: url})

		for attrKey of attrs
			if ['url','src','href'].indexOf(attrKey) is -1
				$newTag.attr attrKey, attrs[attrKey]
		
		$(@).replaceWith $newTag

	fileObj.lines = $.html().split '\n'
	callback null, fileObj