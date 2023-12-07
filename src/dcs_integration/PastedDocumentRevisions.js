const pastedDocumentNumbersAndRevisions =
`` // paste the list here

const sqlValuesString = pastedDocumentNumbersAndRevisions
    .split('\n')
    .map((line) => line.split('\t'))
    .map((values) => {
        if(values[2].length === 1) values[2] = '0' + values[2]
        return values
    })
    .map((values) => `('${values[1]}', '${values[2]}')`)
    .join(',\n')

console.log(sqlValuesString)
