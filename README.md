node-etml
===

> A preprocessor that enhances HTML

This is a module that allows for etml usage within Node. For etml docs, visit [etml-api](https://github.com/chrisdothtml/etml-api). To report an issue/suggestion, please do it [here](https://github.com/chrisdothtml/etml-api/issues).

For etml usage with Grunt, visit [grunt-etml](https://github.com/chrisdothtml/grunt-etml).

## Installation

```
npm install node-etml
```

## Usage

Including the module

```js
var etml = require('node-etml');
```

Running etml

```js
// to compile etml on the fly (returns with HTML string)
etml.src(src, options);

// to compile one file
etml.file('path/to/src/file.etml', 'path/to/dest/', options);

// to compile all .etml files in a directory
etml.file('path/to/src/', 'path/to/dest/', options);
```

## Options

#### bfe
Type: `Boolean`
Default value: `true`

When this is set to `true`, it will use [better-fs-errors](https://github.com/chrisdothtml/better-fs-errors) for its filesystem error reporting.