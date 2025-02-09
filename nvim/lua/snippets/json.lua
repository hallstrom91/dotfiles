local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node

return {
	s("pkgscripts", {
		t({
			'"scripts": {',
			'  "test": "echo \\"Error: no test specified\\" && exit 1",',
			'  "dev": "nodemon ./src/index.js",',
			'  "start": "node ./src/index.js"',
			"}",
		}),
	}),
}
