// CONEXION CON CASSANDRA
const cassandra = require('cassandra-driver');

const auth = new cassandra.auth.PlainTextAuthProvider('cassandra', 'cassandra');
const client = new cassandra.Client({
    contactPoints: ['34.125.17.84'],
    localDataCenter: 'datacenter1',
    authProvider: auth,
    protocolOptions: { port: 9042 },
    keyspace: 'techframer',
    socketOptions: { readTimeout: 0 }
});

async function executeC(query) {
    const options = { prepare: true , fetchSize: 1000000 };
    return await (await client.execute(query,"",options))
}

executeC(`select count(*) from student`);

const cassandra = async () => {
    await (await executeC(cassandraQuerys.consulta1_1)).rows[0]['count'];
}