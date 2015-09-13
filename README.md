node-etml
===

> A preprocessor that enhances HTML

This is a module that allows for etml usage within node. For etml docs, please visit the [API repo](https://github.com/chrisdothtml/etml-api). To report an issue/suggestion, please do it [here](https://github.com/chrisdothtml/etml-api/issues).

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
etml.compile(src, options);

// to compile one file
etml.process('path/to/src/file.etml', 'path/to/dest/', options);

// to compile all .etml files in a directory
etml.process('path/to/src/', 'path/to/dest/', options);
```

## Options

