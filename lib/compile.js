/*
 * File: compile
 * Description: Handles file i/o and facilitates process methods.
 */
'use strict';
var beautify, fs, path, tokenize;

beautify = require('js-beautify').html;

fs = require('fs');

path = require('path');

tokenize = require('./tokenize');

module.exports = function (srcFilePath, destPath, options, handleErr) {
	var start;
	start = new Date();
	return fs.readFile(srcFilePath, 'utf8', function (err, contents) {
		var destFile, globals, srcFile, srcPath, tokens;
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
		tokens = tokenize(contents, '', globals.options);
		return console.log(tokens);

		/*handle tokens (err, contents) ->
					if err then return handleErr err
						
					 * beautify contents before writing to file
					output = beautify contents,
						globals.options.indent_level
						globals.options.indent_with_tabs
						globals.options.unescape_strings
    
					fs.writeFile destPath + destFile, contents, (err) ->
						if err then return handleErr err
    
						end = new Date()
    
						return console.log 'Compiled ' + destFile + ' in ' + (end.getTime() - start.getTime()) + 'ms'
		 */
	});
};