#!/bin/bash

#!/bin/bash

COUNT=${1-1}

docker build -t jmeter-base jmeter-base
docker-compose build
docker-compose up -d
docker-compose scale master=1 slave=$COUNT

SLAVE_IP=$(docker inspect -f '{{.Name}} {{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $(docker ps -aq) | grep slave | awk -F' ' '{print $2}' | tr '\n' ',' | sed 's/.$//')
WDIR=`docker exec -it master /bin/pwd | tr -d '\r'`
mkdir -p results

echo $WDIR


for filename in scripts/*.jmx; do
    NAME=$(basename $filename)
    NAME="${NAME%.*}"
    eval "docker cp $filename master:$WDIR/scripts/"
     eval "docker exec -i master /bin/bash -c 'cat > /jmeter/apache-jmeter-3.3/users.csv' < users.csv"
     eval "docker exec -i jmeter-docker-master_slave_1 /bin/bash -c 'cat > /jmeter/apache-jmeter-3.3/users.csv' < users.csv"
     eval "docker exec -i jmeter-docker-master_slave_2 /bin/bash -c 'cat > /jmeter/apache-jmeter-3.3/users.csv' < users.csv"
     eval "docker exec -i jmeter-docker-master_slave_3 /bin/bash -c 'cat > /jmeter/apache-jmeter-3.3/users.csv' < users.csv"
     eval "docker exec -i jmeter-docker-master_slave_4 /bin/bash -c 'cat > /jmeter/apache-jmeter-3.3/users.csv' < users.csv"
     eval "docker exec -i jmeter-docker-master_slave_5 /bin/bash -c 'cat > /jmeter/apache-jmeter-3.3/users.csv' < users.csv"
     eval "docker exec -it master /bin/bash -c 'mkdir $NAME && cd $NAME && ../bin/jmeter -n -t  ../$filename -R$SLAVE_IP -l output.csv  -e -o web'"
    eval "docker cp master:$WDIR/$NAME results/"
done


#To stop docker and docker compose and remove all
# docker-compose stop && docker-compose rm -f
#To stop all containers are running
 # docker stop $(docker ps -a -q)
#TO remove all containers
   # docker rm $(docker ps -a -q)
 #To remove all images from docker
 #
 # docker rmi $(docker images -a -q)
 #Inspect the slaves IPD IPAddress
 #docker inspect --format '{{ .Name }} => {{ .NetworkSettings.IPAddress }}' $(sudo docker ps -a -q)
