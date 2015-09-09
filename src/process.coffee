###
 * File: process
 * Description: Various processing methods
###

'use strict'

async = require 'async'
cheerio = require 'cheerio'
fs = require 'fs'
path = require 'path'

# Array.removeDuplicates()
# Returns new array without duplicates from original
Array.prototype.removeDuplicates = ->
	uniques = []

	for item in this
		if uniques.indexOf(item) is -1
			uniques.push item

	return uniques

# String.isEscaped()
# Checks a string to see if it has a '\' at the beginning
String.prototype.isEscaped = ->
	return this.substring(0,1) is '\\'

module.exports =
	globals: {}

	# comments()
	# Processes //line and /*block comments*/
	comments: (contents) ->
		self = this

		lineRe = /[^:"'](\/\/[^\n]*)/g

		handleLineComment = (str) ->

			return str.replace lineRe, (orig, match) ->

				if orig.isEscaped()
					orig = orig.replace '\\', ''
					return handleLineComment orig

				else
					return orig.replace match, ''


		# if the first line is a comment, this
		# allows the comment regex to pick it up
		if contents.substring(0,2) is '//'
			contents = contents.replace '//', '\n//'

		contents = handleLineComment contents

		return contents

	# variables()
	# Processes $variables and replaces ${variable} calls
	variables: (contents) ->
		self = this

		# find variables
		vars = {}
		varRe = /\\?\$([\w-]+):\s?['"]([^'"]+)['"];/ig

		while match = varRe.exec(contents)
			if not match[0].isEscaped()
				vars[match[1]] = match[2]

		###if Object.keys(vars).length
			# no need for duplicates
			#vars = vars.removeDuplicates()

			console.log vars###

		return contents

	# imports()
	# Processes @import calls
	imports: (contents, callback) ->
		self = this

		# findImports()
		# Searches a provided string for iimport calls and
		# recursively retrives file contents
		findImports = (str, srcPath, _callback) ->

			# prepareUrl()
			# Returns object for use with fs reading
			prepareUrl = (file) ->
				file = path.normalize file

				# isolate url parts
				filePath = path.dirname file
				file = path.basename file

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

				res =
					filePath: srcPath + filePath + file
					# context for any additional imports
					context: srcPath + filePath

				return res

			# handleImport()
			# Made to be called from async.map() to asynchronously
			# handle each import. Also checks imported file for
			# further imports, and handles those as well
			handleImport = (file, __callback) ->
				url = prepareUrl file
				importObj = {}

				fs.readFile url.filePath, 'utf8', (err, contents) ->
					if err then return __callback err, null

					# escapes
					#contents = self.escapes contents

					# comments
					#contents = self.comments contents

					# search retreived file for further imports
					findImports contents, url.context, (err, contents) ->
						if err then return __callback err, null

						importObj[file] = contents
						return __callback null, importObj

			# find imports
			imports = []
			urlRe = /@import\s?['"]([\w\.\/-]+)['"];/ig

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
							importRe = new RegExp '@import\\s?[\'"]' + importKey + '[\'"];', 'ig'

							# replace any matching import in
							# the original file with the file contents
							str = str.replace importRe, importObj[importKey]

					return _callback null, str

			else return _callback null, str

		# start finding imports
		findImports contents, self.globals.file.srcPath, (err, contents) ->
			if err then return callback err, null

			return callback null, contents

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