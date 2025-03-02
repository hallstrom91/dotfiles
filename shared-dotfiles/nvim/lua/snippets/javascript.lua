local ls = require('luasnip')
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

return {

  s('mongoschema', {
    t('const '),
    i(1, 'schemaName'),
    t('Schema = new mongoose.Schema({'),
    t({ '', '  ' }),
    i(2, 'fieldName'),
    t(' : { type: '),
    i(3, 'Type'),
    t(', required: '),
    i(4, 'true/false'),
    t(','),
    t({ '', '  ' }),
    i(5, 'fieldName2'),
    t(' : { type: '),
    i(6, 'Type'),
    t(', required: '),
    i(7, 'true/false'),
    t(','),
    t({ '', '}, { timestamps: true });' }),
    t({ '', '' }),
    t('module.exports = '),
    i(8, 'schemaName'),
    t(';'),
  }),
}
