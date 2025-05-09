const pastedDocumentNumbersAndRevisions =
`` // paste the list here

const sqlValuesString = pastedDocumentNumbersAndRevisions
    .split('\n')
    .filter((x) => x) // remove empty lines -- false-y values (e.g., '')
    .map((line) => line.split('\t'))
    .filter((line) => {
        // remove whitespace lines -- arrays of false-y values (e.g., ['',''])
        return ! line.every((value) => ! value)
    })
    .map((values) => {
        if(values[2].length === 1) values[2] = '0' + values[2]
        return values
    })
    .map((values) => `('${values[1]}', '${values[2]}')`)
    .join(',\n')

console.log(sqlValuesString)
