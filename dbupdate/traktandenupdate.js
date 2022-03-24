const fs = require('fs')
const mysql = require('mysql2')

const PREFIX = process.env.PREFIX ?? 'oc_'

async function read(stream) {
    const chunks = [];
    for await (const chunk of stream) chunks.push(chunk);
    return Buffer.concat(chunks).toString('utf8');
}

read(process.stdin).then(input => {

    if (input) {

        const con = mysql.createConnection({
            host: process.env.MYSQL_HOST ?? 'mysql',
            user: process.env.MYSQL_USER ?? 'nextcloud',
            password: process.env.MYSQL_PASSWORD ?? '',
            database: process.env.MYSQL_DATABASE ?? 'nextcloud'
        })

        con.connect(err => {
            if (err) throw err

            const keys = ['id', 'nr', 'ggrsitzung', 'geschaeft']
            const query = `insert into ${PREFIX}ggrwinti_ggrsitzung_traktanden
                (${keys.join()})
                values
                (${input.replace(/\n$/, '').replace(/\n/g, '),\n                (')})
                on duplicate key update
                ${keys.map(key => key + '=values(' + key + ')').join()};`

            con.query(query, (err, res) => {
                if (err) throw err
            })

            con.end()
        })

    }

}).catch(console.error)
