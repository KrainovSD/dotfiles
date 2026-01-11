local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local fmt = require("luasnip.extras.fmt").fmt

return {
  s(
    "wrap",
    fmt('fmt.Errorf("{} %w", err)', {
      i(1, ""),
    })
  ),
  s("err", fmt("if err != nil {{\n\treturn nil, err\n}}", {})),
  s(
    "main",
    fmt("func main() {{\n\t{}\n}}", {
      i(1, ""),
    })
  ),
}
