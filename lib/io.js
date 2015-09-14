/*
 * File: io
 * Description: Handles file input/output.
 */
'use strict';
var async, etmlapi, fs, path;

fs = require('fs');

path = require('path');

async = require('async');

etmlapi = require('etml-api');

module.exports = function (src, dest, options, handleErr) {

	/*
	 * canCompile()
	 * Checks if a filename is able to be compiled
	 */
	var canCompile, compileFiles, filename, files, makeFileObj;
	canCompile = function (file) {
		return path.extname(file) === '.etml' && file.charAt(0) !== '_';
	};

	/*
	 * makeFileObj()
	 * Returns an object with various file properties
	 */
	makeFileObj = function (file, src, dest) {
		var fileObj, newFile;
		newFile = file.replace('.etml', '.html');
		fileObj = {
			src: path.join(src, file),
			dest: path.join(dest, newFile),
			contents: ''
		};
		return fileObj;
	};

	/*
	 * compileFiles()
	 * Loops through an array of file objects and sends
	 * them through the compiler. If the file is successfully
	 * compiled, it is written to the destination file
	 */
	compileFiles = function (files, options) {
		return async.each(files, function (file, callback) {
			return fs.readFile(file.src, 'utf8', function (err, contents) {
				if (err) {
					return handleErr(err);
				}
				file.contents = contents;
				return etmlapi.compile(file, options, function (err, output) {
					if (err) {
						handleErr(err);
					}
					return fs.writeFile(file.dest, output, function (err) {
						if (err) {
							return handleErr(err);
						}
						return console.log('Compiled ' + file.src + ' successfully.');
						return callback(null);
					});
				});
			});
		});
	};
	src = path.normalize(src);
	dest = path.normalize(dest);
	if (path.extname(src)) {
		files = [];
		filename = path.basename(src);
		if (!canCompile(filename)) {
			handleErr('ERROR: Provided source file is not a compilable .etml file');
		}
		files.push(makeFileObj(filename, path.dirname(src), dest));
		return compileFiles(files, options);
	} else {
		return fs.readdir(src, function (err, files) {
			if (err) {
				handleErr(err);
			}
			files = files.filter(function (file) {
				return canCompile(file);
			});
			if (!files.length) {
				handleErr('ERROR: There are no compilable .etml files in provided destination');
			}
			files = files.map(function (file) {
				return makeFileObj(file, src, dest);
			});
			return compileFiles(files, options);
		});
	}
};