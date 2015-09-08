/*
 * File: process
 * Description: Various processing methods
 */
'use strict';
var async, cheerio, fs, path;

async = require('async');

cheerio = require('cheerio');

fs = require('fs');

path = require('path');

Array.prototype.removeDuplicates = function () {
	var i, item, len, uniques;
	uniques = [];
	for (i = 0, len = this.length; i < len; i++) {
		item = this[i];
		if (uniques.indexOf(item) === -1) {
			uniques.push(item);
		}
	}
	return uniques;
};

String.prototype.isEscaped = function () {
	return this.charAt(0) !== '\\';
};

module.exports = {
	globals: {},
	comments: function (contents) {
		var lines, self;
		self = this;
		lines = contents.split('\n');
		contents = lines.map(function (line) {
			var inlineRe, match, parts;
			inlineRe = /\\?\/\//g;
			while (match = inlineRe.exec(line)) {
				if (!match[0].isEscaped()) {
					console.log(match);
					line = line.replace('\\//', '\\/#/#');
					parts = line.split('//');
					if (!parts[0].trim()) {
						return false;
					}
					line = parts[0].replace('\\/#/#', '\\//');
				}
			}
			while (match = inlineRe.exec(line)) {
				console.log(match);
				if (match[0].isEscaped()) {
					line = line.replace('\\//', '//');
				}
			}
			return line;
		}).filter(function (line) {
			return line;
		}).map(function (line) {
			return line;
		}).join('\n');
		return contents;
	},
	variables: function (contents) {
		var match, self, varRe, vars;
		self = this;
		vars = {};
		varRe = /\\?\$([\w-]+):\s?['"]([^'"]+)['"];/ig;
		while (match = varRe.exec(contents)) {
			if (!match[0].isEscaped()) {
				vars[match[1]] = match[2];
			}
		}

		/*if Object.keys(vars).length
					 * no need for duplicates
					#vars = vars.removeDuplicates()
    
					console.log vars
		 */
		return contents;
	},
	imports: function (contents, callback) {
		var findImports, self;
		self = this;
		findImports = function (str, srcPath, _callback) {
			var handleImport, imports, match, prepareUrl, urlRe;
			prepareUrl = function (file) {
				var filePath, res;
				file = path.normalize(file);
				filePath = path.dirname(file);
				file = path.basename(file);
				if (filePath.charAt(0) === '\\') {
					filePath = filePath.replace('\\', '');
				}
				if (filePath.slice(-1) !== '\\') {
					filePath += '\\';
				}
				if (file.indexOf('.etml') === -1) {
					file += '.etml';
				}
				if (file.charAt(0) !== '_') {
					file = '_' + file;
				}
				res = {
					filePath: srcPath + filePath + file,
					context: srcPath + filePath
				};
				return res;
			};
			handleImport = function (file, __callback) {
				var importObj, url;
				url = prepareUrl(file);
				importObj = {};
				return fs.readFile(url.filePath, 'utf8', function (err, contents) {
					if (err) {
						return __callback(err, null);
					}
					contents = self.escapes(contents);
					contents = self.comments(contents);
					return findImports(contents, url.context, function (err, contents) {
						if (err) {
							return __callback(err, null);
						}
						importObj[file] = contents;
						return __callback(null, importObj);
					});
				});
			};
			imports = [];
			urlRe = /@import\s?['"]([\w\.\/-]+)['"];/ig;
			while (match = urlRe.exec(str)) {
				imports.push(match[1]);
			}
			if (imports.length) {
				imports = imports.removeDuplicates();
				return async.map(imports, handleImport, function (err, imports) {
					var i, importKey, importObj, importRe, len;
					if (err) {
						return _callback(err, null);
					}
					for (i = 0, len = imports.length; i < len; i++) {
						importObj = imports[i];
						for (importKey in importObj) {
							importRe = new RegExp('@import\\s?[\'"]' + importKey + '[\'"];', 'ig');
							str = str.replace(importRe, importObj[importKey]);
						}
					}
					return _callback(null, str);
				});
			} else {
				return _callback(null, str);
			}
		};
		return findImports(contents, self.globals.file.srcPath, function (err, contents) {
			if (err) {
				return callback(err, null);
			}
			return callback(null, contents);
		});
	},
	tags: function (contents, callback) {
		var $, self;
		self = this;
		$ = cheerio.load(contents, {
			decodeEntities: false,
			xmlMode: true
		});
		$('css, js').each(function () {
			var $newTag, attrKey, attrs, type, url;
			type = $(this)[0].name;
			url = $(this).attr('url');
			attrs = $(this)[0].attribs;
			if (type === 'css') {
				$newTag = $('<link rel="stylesheet" href="' + url + '">');
			} else if (type === 'js') {
				$newTag = $('<script src="' + url + '"></script>');
			}
			for (attrKey in attrs) {
				if (['url', 'src', 'href'].indexOf(attrKey) === -1) {
					$newTag.attr(attrKey, attrs[attrKey]);
				}
			}
			return $(this).after($newTag).remove();
		});
		return callback(null, $.html());
	}
};