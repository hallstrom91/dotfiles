local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

return {
	s("readme", {
		t("# "),
		i(1, "Project Title"),
		t({ "", "", "## Description", "" }),
		i(2, "A brief description of your project."),
		t({ "", "", "## Table of Contents", "" }),
		t({
			"- [Description](#description)",
			"- [Installation](#installation)",
			"- [Usage](#usage)",
			"- [Contributing](#contributing)",
			"- [License](#license)",
			"",
			"## Installation",
			"",
		}),
		i(3, "Instructions on how to install the project."),
		t({ "", "", "## Usage", "" }),
		i(4, "Provide examples on how to use the project."),
		t({ "", "", "## Contributing", "" }),
		i(5, "Guidelines for contributing to the project."),
		t({ "", "", "## License", "" }),
		i(6, "Specify the license under which the project is distributed."),
	}),
}
