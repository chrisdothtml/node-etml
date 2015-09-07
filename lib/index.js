/*
 * File: index
 * Description: Handles source and destination and sends files to compiler.
 */
'use strict';
var bfe, compile, defaults, fs, path;

bfe = require('better-fs-errors');

defaults = require('defaults');

fs = require('fs');

path = require('path');

compile = require('./compile');

module.exports = function (src, dest, options) {
	var canCompile, handleErr;
	src = path.normalize(src);
	dest = path.normalize(dest);
	({
		options: defaults(options.etml, {
			useBfe: false
		})
	});
	handleErr = function (err) {
		if (options.useBfe) {
			throw bfe(err);
		}
		throw err;
	};
	canCompile = function (filename) {
		return path.extname(filename) === '.etml' && filename.charAt(0) !== '_';
	};
	if (path.extname(dest)) {
		handleErr('Provided destination is not a directory');
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