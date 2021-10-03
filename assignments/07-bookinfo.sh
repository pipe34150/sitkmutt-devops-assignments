# Clean All Containers and Images that exist in Server
docker system prune -af
docker rm -vf $(docker ps -a -q)
docker rmi -f $(docker images -a -q)

# Open Bookinfo-Assignment Directory 
cd ../../bookinfo-assignment

# Ratings
cd ratings

# Build and Run Docker Image and Container of MongoDB and Ratings
docker build -t mongodb .
docker build -t ratings .

docker run -d --name mongodb -p 27017:27017 -v $(pwd)/databases:/docker-entrypoint-initdb.d -e MONGODB_ROOT_PASSWORD=CHANGEME -e MONGODB_USERNAME=ratings -e MONGODB_PASSWORD=CHANGEME -e MONGODB_DATABASE=ratings bitnami/mongodb:5.0.2-debian-10-r2
docker run -d --name ratings -p 8080:8080 --link mongodb:mongodb -e SERVICE_VERSION=v2 -e 'MONGO_DB_URL=mongodb://mongodb:27017/ratings' -e SERVICE_VERSION=v2 -e MONGO_DB_USERNAME=ratings -e MONGO_DB_PASSWORD=CHANGEME ratings

# Details
cd ../details

# Build and Run Docker Image and Container of Details
docker build -t details .
docker run -d --name details -p 8081:8081 -e ENABLE_EXTERNAL_BOOK_SERVICE=true -e DO_NOT_ENCRYPT=false details

# Reviews
cd ../reviews

# Build and Run Docker Image and Container of Reviews
docker build -t reviews .
docker run -d --name reviews -p 8082:9080 --link ratings:ratings -e 'RATINGS_SERVICE=http://ratings:8080' -e ENABLE_RATINGS=true reviews

# Productpage
cd ../productpage

# Build and Run Docker Image and Container of Productpage
docker build -t productpage .
docker run -d --name productpage -p 8083:8083 --link details:details --link ratings:ratings --link reviews:reviews -e 'DETAILS_HOSTNAME=http://details:8081' -e 'RATINGS_HOSTNAME=http://ratings:8080' -e 'REVIEWS_HOSTNAME=http://reviews:9080' -e FLOOD_FACTOR=0 productpage