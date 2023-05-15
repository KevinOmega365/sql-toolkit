const fs = require('fs')
let outputSql = ''

configData = JSON.parse(fs.readFileSync('./input.json'))

console.log('¯\\_(ツ)_/¯')

fields = configData.fields.map(f => f.name)

// todo: expand this to support more than just null and string-y data
const formatValues = (row) =>
`(
    ${row
        .map(s => s === null && 'NULL' || `'${s}'`)
        .join(',\n\t')}
)`

outputSql +=
`insert into dbo.atbl_Integrations_Setup_Endpoints
(
    ${fields.join(',\n\t')}
)
values
${configData.data.map(formatValues)}
`

fs.writeFileSync('output.sql', outputSql, 'utf-8')