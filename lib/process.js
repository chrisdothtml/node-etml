/*
 * File: process.coffee
 * Description: Various processing methods
 */
'use strict';
var async, cheerio, fs, he, path;

async = require('async');

cheerio = require('cheerio');

fs = require('fs');

he = require('he');

path = require('path');

module.exports = {
	globals: {},
	escapes: function (contents) {
		var re, self;
		self = this;
		re = /#{([^#{}]*)}/g;
		return contents.replace(re, he.encode('$1', {
			'encodeEverything': true
		}));
	},
	imports: function (contents, callback) {
		var findImports, self;
		self = this;
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
		String.prototype.prepareUrl = function () {
			var file, filePath, url;
			url = path.normalize(this);
			file = path.basename(url);
			filePath = path.dirname(url);
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
			return self.globals.file.srcPath + filePath + file;
		};
		findImports = function (str, _callback) {
			var handleImport, imports, match, urlRe;
			handleImport = function (file, __callback) {
				var importObj, url;
				url = file.prepareUrl();
				importObj = {};
				return fs.readFile(url, 'utf8', function (err, contents) {
					if (err) {
						return __callback(err, null);
					}
					return findImports(contents, function (err, contents) {
						if (err) {
							return __callback(err, null);
						}
						importObj[file] = contents;
						return __callback(null, importObj);
					});
				});
			};
			imports = [];
			urlRe = /@import\s?['"]([\w\.\/-]*)['"]/ig;
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
							importRe = new RegExp('@import\\s?[\'"]' + importKey + '[\'"]', 'ig');
							str = str.replace(importRe, importObj[importKey]);
						}
					}
					return _callback(null, str);
				});
			} else {
				return _callback(null, str);
			}
		};
		return findImports(contents, function (err, contents) {
			if (err) {
				return callback(err, null);
			}
			return callback(null, contents);
		});
	},
	comments: function (contents) {
		var lines, self;
		self = this;
		lines = contents.split('\n');
		contents = lines.map(function (line) {
			var parts;
			if (line.indexOf('//') > -1) {
				parts = line.split('//');
				if (!parts[0].trim()) {
					return false;
				}
				return parts[0];
			}
			return line;
		}).filter(function (line) {
			return line;
		}).join('\n');
		if (contents.indexOf('/*') > -1) {
			contents = contents.replace('/*', '<!--');
		}
		if (contents.indexOf('*/') > -1) {
			contents = contents.replace('*/', '-->');
		}
		return contents;
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