const fs = require('fs')
const mysql = require('mysql2')

const PREFIX = process.env.PREFIX ?? 'oc_'

async function read(stream) {
    const chunks = [];
    for await (const chunk of stream) chunks.push(chunk);
    return Buffer.concat(chunks).toString('utf8');
}

read(process.stdin).then(input => {

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
                id: item.title.replace(/.*<a href="[^"]*\/(.*)".*/s, '$1'),
                title: item.title.replace(/<a.*>(.*?)<\/a>/s, '$1'),
                ggrnr: item._nummer,
                type: item._kategorieId,
                status: 'unbekannt',
                date: item['_geschaeftsdatum-sort']
            }))

            const query = `insert into ${PREFIX}ggrwinti_geschaefte
                (${Object.keys(data[0]).join()})
                values
                ('${data.map(item => Object.values(item).map(txt => txt.replace("'", "\'")).join("','")).join("'),\n                ('")}')
                on duplicate key update
                ${Object.keys(data[0]).map(key => key + '=values(' + key + ')').join()};`

            con.query(query, (err, res) => {
                if (err) throw err
                console.log(res)
            })

        }

        con.end()
    })

}).catch(console.error)

/*
names=( 'id' 'title' 'ggrnr' 'type' 'status' 'date' )
sql geschaefte names[@]  vals[@]

names=('id' 'date')
values=("$id" "'$date'")
sql ggrsitzungen names[@] values[@]

echo -n "insert into ${PREFIX}ggrwinti_${1} ("
join ',' "${arg2[@]}"
echo -n ") values ("
join ',' "${arg3[@]}"
echo -n ") on duplicate key update "
join ',' "${nms[@]}"
*/

//console.log(data)
//console.log(query)