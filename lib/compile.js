/*
 * File: compile
 * Description: Handles file io and facilitates process methods.
 */
'use strict';
var beautify, fs, path, process;

fs = require('fs');

path = require('path');

beautify = require('js-beautify').html;

process = require('./process');

module.exports = function (srcFilePath, destPath, options, handleErr) {
	var start;
	start = new Date();
	return fs.readFile(srcFilePath, 'utf8', function (err, contents) {
		var destFile, globals, srcFile, srcPath;
		if (err) {
			return handleErr(err);
		}
		srcPath = path.dirname(srcFilePath) + '\\';
		srcFile = srcFilePath.replace(srcPath, '');
		destFile = srcFile.replace('.etml', '.html');
		process.globals = globals = {
			options: options,
			file: {
				srcPath: srcPath,
				srcFile: srcFile,
				destPath: destPath,
				destFile: destFile
			}
		};
		contents = process.escapes(contents);
		contents = process.comments(contents);
		return process.imports(contents, function (err, contents) {
			if (err) {
				return handleErr(err);
			}
			return process.tags(contents, function (err, contents) {
				if (err) {
					return handleErr(err);
				}
				contents = beautify(contents, {
					indent_level: 1,
					indent_with_tabs: true,
					unescape_strings: true
				});
				return fs.writeFile(destPath + destFile, contents, function (err) {
					var end;
					if (err) {
						return handleErr(err);
					}
					end = new Date();
					return console.log('Compiled ' + destFile + ' in ' + (end.getTime() - start.getTime()) + 'ms');
				});
			});
		});
	});
};