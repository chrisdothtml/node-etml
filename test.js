var etml = require('./');
var src = 'test/src/contact.etml';
var dest = 'test/';

etml(src, dest, {
	useBfe: true
});