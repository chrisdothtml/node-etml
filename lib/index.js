/*
 * File: index.coffee
 * Description: Handles source and destination and sends files to compiler.
 */
'use strict';
var compile, errno, fs, path;

fs = require('fs');

path = require('path');

errno = require('errno');

compile = require('./compile');

module.exports = function (src, dest, options) {
	var canCompile, handleErr, useErrno;
	src = path.normalize(src);
	dest = path.normalize(dest);
	options = options || {};
	useErrno = options.useErrno || true;
	handleErr = function (err) {
		var error;
		if (useErrno && errno.code[err.code]) {
			error = '------------------------------------------------\nRAW ERROR:\n' + err + '\n\nERROR DESCRIPTION:\n' + errno.code[err.code].description + '\n------------------------------------------------';
			throw error;
		} else {
			throw err;
		}
	};
	canCompile = function (filename) {
		return path.extname(filename) === '.etml' && filename.charAt(0) !== '_';
	};
	if (path.extname(dest)) {
		dest = path.dirname(dest);
	}
	if (dest.slice(-1) !== '\\') {
		dest += '\\';
	}
	if (path.extname(src)) {
		if (!canCompile(src)) {
			handleErr('Provided source file is not a compilable .etml file');
		}
		return compile(src, dest, options, handleErr);
	} else {
		return fs.readdir(src, function (err, files) {
			var file, i, len, results;
			if (err) {
				handleErr(err);
			}
			files = files.filter(function (file) {
				return canCompile(file);
			});
			if (!files.length) {
				handleErr('There are no compilable .etml files in provided destination');
			}
			results = [];
			for (i = 0, len = files.length; i < len; i++) {
				file = files[i];
				results.push(compile(src + file, dest, options, handleErr));
			}
			return results;
		});
	}
};