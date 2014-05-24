# React Marked

Render markdown with React using marked's lexer and parser

```
var React = require('react');
var Marked = require('react-marked');

var content = "# heading \
  * bullet 1\
  * bullte 2";

console.log(React.renderComponentToString(<Marked markdown={content}>));
```

# TODO
* Port tests from [marked](https://github.com/chjj/marked)
