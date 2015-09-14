/*
 * File: index
 * Description: Handles user input.
 */
'use strict';
var bfe, etmlapi, io;

bfe = require('better-fs-errors');

etmlapi = require('etml-api');

io = require('./io');

module.exports = {

	/*
	 * src()
	 * Used for sending a block of etml through the compiler
	 */
	src: function (src, options) {
		var file;
		file = {
			contents: src
		};
		return etmlapi.compile(file, options);
	},

	/*
	 * file()
	 * Used for sending a file or directory of files through
	 * the compiler
	 */
	file: function (src, dest, options) {
		var handleErr;
		handleErr = function (err) {
			if (options.bfe != null) {
				if (options.bfe === false) {
					throw err;
				}
			}
			throw bfe(err);
		};
		return io(src, dest, options, handleErr);
	}
};