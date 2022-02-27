const fs = require('fs')
const mysql = require('mysql')
const input = JSON.parse(fs.readFileSync(0, 'utf-8'))
const PREFIX = process.env.PREFIX ?? 'oc_'

const con = mysql.createConnection({
    host: process.env.MYSQL_HOST ?? 'mysql',
    user: process.env.MYSQL_USER ?? 'nextcloud',
    password: process.env.MYSQL_PASSWORD ?? '',
    database: process.env.MYSQL_DATABASE ?? 'nextcloud'
})

const data = input.data.map(item => ({
    id: item.title.replace(/.*<a href=".*\/(.*)".*/, '$1'),
    title: item.title.replace(/<a.*>(.*)<\/a>/, '$1'),
    ggrnr: item._nummer,
    type: item._kategorieId,
    //status:
    date: item._geschaeftsdatum
}))

const query = `insert into ${PREFIX}ggrwinti_geschaefte ('${Object.keys(data[0]).join("','")}') values ('${data.map(item => Object.values(item).join("','")).join("','")}') on duplicate key update`

con.connect(err => {
    if (err) throw err
    console.log('connected')
    con.query(query, (err, res) => {
        if (err) throw err
        console.log(result)
    })
})

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