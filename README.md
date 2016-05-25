# Playcloud

## Requirements

* docker [https://docs.docker.com/engine/quickstart/]
* docker-compose [https://docs.docker.com/compose/install/]
* docker-machine [https://docs.docker.com/machine/]

## TL;DR

```bash
$docker-machine create -d virtualbox playcloud
$docker-machine env playcloud
$eval $(docker-machine env playcloud)
$git clone https://github.com/safecloud-project/playcloud.git 
$cd playcloud
$docker-compose build
$docker-compose up -d
$touch my-file.txt
$curl -v -X PUT `docker-machine ip playcloud`:3000/my-file.txt -T my-file.txt
$curl -v -X GET `docker-machine ip playcloud`:3000/my-file.txt -o my-file.txt
```

## Architecture

Playcloud is split in 3 components:

* proxy - A web server taking requests on port 3000
* encoder-decoder - A enconding/decoding component
* storage - A database to saved the encoded data


## Run the server

In order to start the server, run the following command in your terminal:

```bash
docker-compose build
docker-compose up (or -d to run in detach)

```

This command will launch three containers. One named *proxy*, containing the web application accepting HTTP requests on port 3000, a second one named *coder* in charge of encoding/decoding and a last one name *redis* for storage.

## API

The server currently accepts 2 types of requests.

### GET /file

Retrieves a file from the storage component.
```bash
curl -X GET my-server:3000/my-file.txt -o my-file.txt
```

### PUT /file

Sends a file to the storage component.
```bash
curl -X PUT my-server:3000/my-file.txt -T my-file.txt
```


## Configuration

### Encoder/Decoder

The encoder/decoder's configuration can be overloaded by environment variables. These values can be added/modified in the erasure.env file which is loaded when starting the server up.

## Misc
An export of the main branch (git rev: 49f27af64c1bd69be06b96d4e9d3ba0bec516e12 ).
