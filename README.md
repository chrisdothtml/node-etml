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