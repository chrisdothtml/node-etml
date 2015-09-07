node-etml
===
**E**nhanced **T**ext **M**arkup **L**anguage

etml is a NodeJS-built HTML enhancer. It was inspired by the way that [SCSS](http://sass-lang.com/documentation/file.SCSS_FOR_SASS_USERS.html) maintains all the syntax from vanilla CSS, yet enhances the way you are able to work with it. etml allows you to work with the HTML syntax you know and love, but provides some enhanced functionality to make development quicker and more efficient.

I built this processor out of my own necessity, and I personally use it on most of my projects. It's the perfect tool for me, but if it's not for you, feel free to [create an issue](https://github.com/chrisdothtml/node-etml/issues) and I'll be happy to consider any changes or additions.

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
// to compile one file
etml('path/to/src/file.etml', 'path/to/dest/', options);

// to compile all .etml files in a directory
etml('path/to/src/', 'path/to/dest/', options);
```

### Options

Syntax
===

Much like the idea behind etml, the syntax was also inspired by [SCSS](http://sass-lang.com/documentation/file.SCSS_FOR_SASS_USERS.html).

### Built-in Tags

etml comes with some custom tags that are shortcuts for other tags. These are optional, and are only there to either shorten the code, or make it more readable.

`<js>` and `<css>`

````
<css url="core.css">
<js url="core.js">
````

compiles to

````
<link rel="stylesheet" type="text/css" href="core.css" />
<script type="text/javascript" src="core.js"></script>
````

All custom tags will honor any additional attributes you have on them. For example:

````
<css id="ie-css" url="core.css">
````

compiles to

````
<link id="ie-css" rel="stylesheet" type="text/css" href="core.css" />
````

### Custom Tags

In addition to the built-in tags, you are able to make your own custom tags with etml.

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

Files that are imported to etml must use the `_file.etml` format. Files in this format can only be used in imports and will not be picked up by the compiler.

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

Providing the leading underscore and file extension are optional in file imports, but the actual file still needs them.

````
@import 'inc/_file.etml'
@import 'inc/file.etml'
@import 'inc/file'
````

File imports are recursive, so you are able to import files within other imported files.

### Escaping

In some instances, you may need to escape things so they don't get picked up by the compiler. For instance:

````
<span><strong>FREE SHIPPING //</strong> on orders over $200</span>
````

The right portion of that line would be commented out because of etml line comments. If you ever need to escape anything from the compiler, just wrap it like this:

````
<span><strong>FREE SHIPPING #{//}</strong> on orders over $200</span>
````

NOTE: it's best to escape only when necessary as the compiler decodes every character inside to html entities. Another example:

````
// escaping the `@` is enough to stop it from being picked up from the compiler
<span>Import files by using #{@}import 'file.etml'</span>
````

node-etml Development
===

etml is built with CoffeeScript and is compiled using Grunt. Development is best suited in the /src/ directory. To work on etml, clone the repo and run:

```
npm install
```

### Debugging

etml comes with an option to use [better-fs-errors](https://github.com/chrisdothtml/better-fs-errors) for its fs error reporting. This can be enabled by passing the option `useBfe: true`. The option is set to `false` by default.

### Awesome modules used

- [async](https://github.com/caolan/async)
- [cheerio](https://github.com/cheeriojs/cheerio)
- [errno](https://github.com/rvagg/node-errno)
- [JS Beautifier](https://github.com/beautify-web/js-beautify)
- [he](https://github.com/mathiasbynens/he)

### Special Thanks

- [bebraw](https://github.com/bebraw) for [mocss](https://github.com/bebraw/mocss) and his [blog post](http://www.nixtu.info/2011/12/how-to-write-css-preprocessor-using.html).
- [ionutvmi](https://github.com/ionutvmi) for [sublime-html](https://github.com/ionutvmi/sublime-html)
- [workshopper](https://github.com/workshopper) for [learnyounode](https://github.com/workshopper/learnyounode)