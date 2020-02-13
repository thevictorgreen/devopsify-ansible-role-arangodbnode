#!/usr/bin/arangosh --javascript.execute
db._useDatabase("_system");
require("@arangodb/replication").setupReplication({ endpoint: "tcp://YYYYY:8529", username: "root", password: "g0th@m", verbose: false, includeSystem: false, incremental: true, autoResync: true});
