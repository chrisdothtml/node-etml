###
 * File: process.coffee
 * Description: Various processing methods
###

'use strict'

# external modules
async = require 'async'
cheerio = require 'cheerio'
fs = require 'fs'
he = require 'he'
path = require 'path'

module.exports =
	globals: {}

	# escapes()
	# Processes character escapes #{}
	escapes: (contents) ->
		self = this

		re = /#{([^#{}]*)}/g
		return contents.replace re, he.encode('$1', {'encodeEverything': true})

	# imports()
	# Processes @import calls
	imports: (contents, callback) ->
		self = this

		# Array.removeDuplicates()
		# Returns new array without duplicates from original
		Array.prototype.removeDuplicates = ->
			uniques = []

			for item in this
				if uniques.indexOf(item) is -1
					uniques.push item

			return uniques

		# String.prepareUrl()
		# Returns prepared URL for fs reading
		String.prototype.prepareUrl = ->
			url = path.normalize this

			# isolate url parts
			file = path.basename url
			filePath = path.dirname url

			# remove leading slash
			if filePath.charAt(0) is '\\'
				filePath = filePath.replace '\\', ''

			# add trailing slash
			if filePath.slice(-1) isnt '\\'
				filePath += '\\'

			# optional extention (file > file.etml)
			if file.indexOf('.etml') is -1
				file += '.etml'

			# optional leading underscore (file.etml > _file.etml)
			if file.charAt(0) isnt '_'
				file = '_'+file

			return self.globals.file.srcPath + filePath + file

		# findImports()
		# Searches a provided string for iimport calls and
		# recursively retrives file contents
		findImports = (str, _callback) ->

			# handleImport()
			# Made to be called from async.map() to asynchronously
			# handle each import. Also checks imported file for
			# further imports, and handles those as well
			handleImport = (file, __callback) ->
				url = file.prepareUrl()
				importObj = {}

				fs.readFile url, 'utf8', (err, contents) ->
					if err then return __callback err, null

					# search retreived file for further imports
					findImports contents, (err, contents) ->
						if err then return __callback err, null

						importObj[file] = contents
						return __callback null, importObj

			# find imports
			imports = []
			urlRe = /@import\s?['"]([\w\.\/-]*)['"]/ig

			while match = urlRe.exec(str)
				imports.push match[1]

			if imports.length

				# no need for duplicates
				imports = imports.removeDuplicates()

				# asynchronously loop through imports
				async.map imports, handleImport, (err, imports) ->
					if err then return _callback err, null

					for importObj in imports

						for importKey of importObj

							# make regex based on the import url
							importRe = new RegExp '@import\\s?[\'"]' + importKey + '[\'"]', 'ig'

							# replace any matching import in
							# the original file with the file contents
							str = str.replace importRe, importObj[importKey]

					return _callback null, str

			else return _callback null, str

		# start finding imports
		findImports contents, (err, contents) ->
			if err then return callback err, null

			return callback null, contents

	# comments()
	# Processes //line and /*block comments*/
	comments: (contents) ->
		self = this

		# inline comments
		lines = contents.split '\n'

		contents = lines.map (line) ->

			if line.indexOf('//') > -1
				parts = line.split '//'

				# remove if nothing before comment
				if not parts[0].trim() then return false

				# leave only what's before the comment
				return parts[0]

			return line

		# remove commented or empty lines
		.filter (line) ->
			return line

		# rejoin lines
		.join '\n'

		# block comments
		if contents.indexOf('/*') > -1
			contents = contents.replace '/*', '<!--'

		if contents.indexOf('*/') > -1
			contents = contents.replace '*/', '-->'

		return contents

	# tags()
	# Processes etml's built-in custom html tags
	tags: (contents, callback) ->
		self = this

		$ = cheerio.load contents,
			decodeEntities: false
			xmlMode: true
	
		# find etml tags
		$('css, js').each ->

			type = $(@)[0].name
			url = $(@).attr('url')
			attrs = $(@)[0].attribs
			
			if type is 'css'
				$newTag = $('<link rel="stylesheet" href="' + url + '">')
			else if type is 'js'
				$newTag = $('<script src="' + url + '"></script>')

			for attrKey of attrs
				if ['url','src','href'].indexOf(attrKey) is -1
					$newTag.attr attrKey, attrs[attrKey]
			
			$(@).after($newTag).remove()

		return callback null, $.html()