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

# Installation

```
npm install node-etml
```

# Usage

Including the module

```js
var etml = require('node-etml');
```

Running etml

```js
etml('path/to/src/file.etml', 'path/to/dest/, options);

etml('path/to/src/', 'path/to/dest/, options);
```

## Options

# Installation

etml is built using CoffeeScript and is compiled using Grunt. Development is best suited in the /src/ directory. To work on etml, clone the repo and run:

```
npm install
```