const fs = require('fs')
const mysql = require('mysql2')

const PREFIX = process.env.PREFIX ?? 'oc_'

async function read(stream) {
    const chunks = [];
    for await (const chunk of stream) chunks.push(chunk);
    return Buffer.concat(chunks).toString('utf8');
}

read(process.stdin).then(input => {

    if (!input) throw new Error('empty input', input)

    const con = mysql.createConnection({
        host: process.env.MYSQL_HOST ?? 'mysql',
        user: process.env.MYSQL_USER ?? 'nextcloud',
        password: process.env.MYSQL_PASSWORD ?? '',
        database: process.env.MYSQL_DATABASE ?? 'nextcloud'
    })

    con.connect(err => {
        if (err) throw err

        const fullData = JSON.parse(input).data

        while (fullData.length) {

            const data = fullData.splice(0, 100).map(item => ({
                id: item.name.replace(/.*<a href="[^"]*\/(.*)".*/s, '$1'),
                date: item['_datum-sort'].replace(/ .*/s, '')
            }))

            const query = `insert into ${PREFIX}ggrwinti_ggrsitzungen
                (${Object.keys(data[0]).join()})
                values
                ('${data.map(item => Object.values(item).map(txt => txt.replace("'", "\'")).join("','")).join("'),\n                ('")}')
                on duplicate key update
                ${Object.keys(data[0]).map(key => key + '=values(' + key + ')').join()};`

            con.query(query, (err, res) => {
                if (err) throw err
                console.log(data.map(item => item.id).join('\n'))
            })

        }

        con.end()
    })

}).catch(console.error)
