local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

return {

	s("mongoschema", {
		t("const "),
		i(1, "schemaName"),
		t("Schema = new mongoose.Schema({"),
		t({ "", "  " }),
		i(2, "fieldName"),
		t(" : { type: "),
		i(3, "Type"),
		t(", required: "),
		i(4, "true/false"),
		t(","),
		t({ "", "  " }),
		i(5, "fieldName2"),
		t(" : { type: "),
		i(6, "Type"),
		t(", required: "),
		i(7, "true/false"),
		t(","),
		t({ "", "}, { timestamps: true });" }),
		t({ "", "" }),
		t("module.exports = "),
		i(8, "schemaName"),
		t(";"),
	}),

	s("mysqlconnection", {
		t("const mysql = require('mysql2');"),
		t({ "", "" }),
		t("const pool = mysql.createPool({"),
		t({ "", "  host: process.env.DB_HOST," }),
		t({ "", "  user: process.env.DB_USER," }),
		t({ "", "  database: process.env.DB_DATABASE," }),
		t({ "", "  port: process.env.DB_PORT," }),
		t({ "", "  password: process.env.DB_PASSWORD," }),
		t({ "", "});" }),
		t({ "", "" }),
		t("module.exports = pool;"),
	}),

	s("nodemiddleware", {
		t("const "),
		i(1, "middlewareName"),
		t(" = (req, res, next) => {"),
		t({ "", "  " }),
		i(2, "// your code here"),
		t({ "", "  next();" }),
		t({ "", "};" }),
		t({ "", "" }),
		t("module.exports = "),
		i(3, "middlewareName"),
		t(";"),
	}),
}
