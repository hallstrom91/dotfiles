local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

return {
	s("jsconfig-node-commonjs", {
		t({
			"{",
			'  "compilerOptions": {',
			'    "module": "',
		}),
		i(1, "CommonJS"),
		t('",'),
		t({ "", '    "target": "' }),
		i(2, "ES2020"),
		t('",'),
		t({ "", '    "moduleResolution": "' }),
		i(3, "NodeNext"),
		t('",'),
		t({ "", '    "baseUrl": "' }),
		i(4, "."),
		t('",'),
		t({ "", '    "checkJs": false' }),
		t({ "", "  }," }),
		t({ "", '  "exclude": [', '    "' }),
		i(5, "node_modules"),
		t({ '"', "  ]", "}" }),
	}),

	s("jsconfig-node-module", {
		t({
			"{",
			'  "compilerOptions": {',
			'    "module": "',
		}),
		i(1, "ESNext"),
		t('",'),
		t({ "", '    "target": "' }),
		i(2, "ES2020"),
		t('",'),
		t({ "", '    "moduleResolution": "' }),
		i(3, "NodeNext"),
		t('",'),
		t({ "", '    "baseUrl": "' }),
		i(4, "."),
		t('",'),
		t({ "", '    "checkJs": false' }),
		t({ "", "  }," }),
		t({ "", '  "exclude": [', '    "' }),
		i(5, "node_modules"),
		t({ '"', "  ]", "}" }),
	}),

	s("jsconfig-react", {
		t({
			"{",
			'  "compilerOptions": {',
			'    "module": "',
		}),
		i(1, "ESNext"),
		t('",'),
		t({ "", '    "target": "' }),
		i(2, "ESNext"),
		t('",'),
		t({ "", '    "moduleResolution": "' }),
		i(3, "Bundler"),
		t('",'),
		t({ "", '    "baseUrl": "' }),
		i(4, "."),
		t('",'),
		t({ "", '    "checkJs": false' }),
		t({ "", "  }," }),
		t({ "", '  "exclude": [', '    "' }),
		i(5, "node_modules"),
		t({ '"', "  ]", "}" }),
	}),
}
