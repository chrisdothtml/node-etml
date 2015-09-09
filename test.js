var etml = require('./');
var src = 'test/src/comments.etml';
var dest = 'test/';

etml(src, dest, {
	useBfe: true
});