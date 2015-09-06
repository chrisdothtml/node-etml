node-etml
===
**E**nhanced **T**ext **M**arkup **L**anguage

etml is a NodeJS-built HTML enhancer. It was inspired by the way that [SCSS](http://sass-lang.com/documentation/file.SCSS_FOR_SASS_USERS.html) maintains all the syntax from vanilla CSS, yet enhances the way you are able to work with it. etml allows you to work with the HTML syntax you know and love, but provides some enhanced functionality to make development quicker and more efficient.

I built this processor out of my own necessity, and I personally use it on most of my projects. It's the perfect tool for me, but if it's not for you, feel free to [create an issue](https://github.com/chrisdothtml/node-etml/issues) and I'll be happy to consider any changes or additions.

### Awesome modules used

- [async](https://github.com/caolan/async)
- [cheerio](https://github.com/cheeriojs/cheerio)
- [JS Beautifier](https://github.com/beautify-web/js-beautify)

### Special Thanks

- [bebraw](https://github.com/bebraw) for [mocss](https://github.com/bebraw/mocss)
- [ionutvmi](https://github.com/ionutvmi) for [sublime-html](https://github.com/ionutvmi/sublime-html)
- [workshopper](https://github.com/workshopper) for [learnyounode](https://github.com/workshopper/learnyounode)

Installation
===

```
npm install node-etml
```

Usage
===

Including the module

```js
var etml = require('node-etml');
```

Running etml

```js
etml('path/to/src/file.etml', 'path/to/dest/', options);

etml('path/to/src/', 'path/to/dest/', options);
```

### Options

Syntax
===

Much like the idea behind etml, the syntax was also inspired by [SCSS](http://sass-lang.com/documentation/file.SCSS_FOR_SASS_USERS.html).

### Comments

One of my biggest gripes with HTML is the comments. They don't look very good, and you can't just quickly add them in. In etml, inline and block comments can be used.

````
<button>Submit</button>//Submit btn

//<b>Bold Text</b>
<strong>Bold Text</strong>

/* Removing nonsense
<marquee>Welcome to my site</marquee>
<blink>I hope you like it</blink>
*/
````

### Variables

````
$contain = ''
````

### File Imports

Files that are imported to etml should use the `_file.etml` format (but it is not required). Files in this format can only be used in imports and will not be picked up by the compiler.

````
<!DOCTYPE html>
<html>
<head>
	@import 'inc/_global-head.etml'
</head>
<body>

</body>
</html>
````

Providing the leading underscore and file extension are optional in file imports.

````
@import 'inc/_file.etml'
@import 'inc/file.etml'
@import 'inc/file'
````

File imports are recursive, so you are able to import files within other imported files.

node-etml Development
===

etml is built with CoffeeScript and is compiled using Grunt. Development is best suited in the /src/ directory. To work on etml, clone the repo and run:

```
npm install
```