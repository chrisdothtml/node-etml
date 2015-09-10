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

module.exports = {
	globals: {},
	tokenTypes: {
		lineComment: {
			type: 'lineComment'
		}
	},
	tokenize: function (contents, callback) {
		var lines, self;
		self = this;
		lines = self.globals.file.contents.split('\n');
		lines.map(function (line) {
			var lineArr;
			lineArr = [];
			console.log(line.trimLeft().substring(2));
			if (line.trimLeft().substring(2) === '//') {
				lineArr.push(self.tokens.lineComment);
				self.globals.file.lines.push(lineArr);
				return line;
			}
			self.globals.file.lines.push(lineArr);
			return line;
		});
		return console.log(self.globals.file.lines);
	},
	handle: function (tokens, callback) {
		var self;
		return self = this;
	}
};