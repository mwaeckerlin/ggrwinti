#! /bin/bash -e
## @id $Id$

##       1         2         3         4         5         6         7         8
## 45678901234567890123456789012345678901234567890123456789012345678901234567890

docker run -d -p ${PORT:-9000}:80 --name ggrwinti mwaeckerlin/owncloud

echo "Go to http://localhost:${PORT:-9000} and login with:"
docker logs ggrwinti | egrep '^admin-(user|password):'
