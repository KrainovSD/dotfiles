local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local fmt = require("luasnip.extras.fmt").fmt

return {
  s(
    "vue",
    fmt(
      [[
<script setup lang="ts">
{}
</script>

<template>
</template>

<style lang="scss" module>
</style>
]],
      {
        i(1, ""),
      }
    )
  ),
}
