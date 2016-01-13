### Learning Locker LRS Docker container

This is a HTTPS **application-only** container for [Learning Locker](http://learninglocker.net).
As such, link to a running mongoDB container is required.

#### Example usage

1. Create a mongoDB instance (example using docker container). [`tutum/mongodb`](https://hub.docker.com/r/tutum/mongodb/) has better custom `ENV` support so use it instead of official mongoDB container:

	```
	docker run -d --name db -p 27017:27017 -p 28017:28017 -e MONGODB_PASS="MONGODB_ADMIN_PASSWORD_HERE" tutum/mongodb:2.6
	```

	This will run a mongoDB 2.6 instance with `test` and `admin` database, with root user `admin@MONGODB_ADMIN_PASSWORD_HERE`.

2. Create learning locker instance:

	```
	docker run \
		-d \
		--name web \
		--link db:mongo \
		-p 433:433 \
		hongymagic/learninglocker:latest
	```

	This will run Learning Locker web application using the above mongoDB instance.

#### Environment variables

> Users of this container are **strongly encourage** to change **all non-optional** environment variables when running this container.

##### Required

- `MONGO_ADMIN_USER`: Root admin user of the mongoDB server (_not_ learning locker user). Defaults to `admin`
- `MONGO_ADMIN_PASSWORD`: Password of the root admin user. Defaults to `password`
- `LEARNINGLOCKER_DB_USER`: Assign a new user to the learning locker database to be created. Defaults to `learninglocker`
- `LEARNINGLOCKER_DB_PASSWORD`: Password of the new learning locker user. Defaults to `learninglocker`
- `LEARNINGLOCKER_DB_NAME`: Name of the database to create for learning locker. Defaults to `learninglocker`
- `APP_URL`: FQDN of the final URL, if missing defaults to `TUTUM_SERVICE_FQDN` then `$HOSTNAME`
- `APP_SECRET_KEY`: [Encryption key](http://docs.learninglocker.net/installation/#configuration) used by learning locker. Defaults to `CHANGEME12345678`
- `SMTP_SERVER`, `SMTP_PORT`, `SMTP_USER`, `SMTP_PASSWORD`, `EMAIL_FROM_NAME`, `EMAIL_FROM_ADDRESS`: Self explanatory, see [configuration page](http://docs.learninglocker.net/installation/#configuration) for more details

##### Optional

- `LEARNINGLOCKER_DB_HOST`: (_optional_) If not linking to another docker container, hostname of the mongoDB server
- `MONGO_WAIT_TIMEOUT`: (_optional_) Time to wait before mongo container becomes live. Defaults to 10 seconds
- `AWS_S3_BUCKET_PATH`: (_optional_) AWS S3 Bucket path to download certificates from. The path should be of the form `s3://my-bucket/www.example.com/certs/*`. And below two keys are also required. If missing, will generate a self-signed certificate
	- `AWS_S3_ACCESS_KEY_ID`
	- `AWS_S3_ACCESS_SECRET_KEY`

#### Example docker-compose.yml

```
web:
  container_name: ll-web
  build: learninglocker
  links:
    - db:mongo
  hostname: example.com
  environment:
    APP_URL: 'example.com'
    MONGO_ADMIN_USER: 'admin'
    MONGO_ADMIN_PASSWORD: 'password'
    LEARNINGLOCKER_DB_NAME: 'learninglocker'
    LEARNINGLOCKER_DB_USER: 'learninglocker'
    LEARNINGLOCKER_DB_PASSWORD: 'learninglocker'
    APP_SECRET_KEY: 'CHANGEME12345678'
    SMTP_SERVER: 'smtp.sendgrid.net'
    SMTP_PORT: 587
    SMTP_USER: 'smtp-username'
    SMTP_PASSWORD: 'smtp-password'
    EMAIL_FROM_NAME: 'Learning Locker LRS Docker Container'
    EMAIL_FROM_ADDRESS: 'lrs@example.com'
    AWS_S3_BUCKET_PATH: 's3://bucket/certs/'
    AWS_S3_ACCESS_KEY_ID: 'AWS access key id'
    AWS_S3_ACCESS_SECRET_KEY: 'AWS access secret key'
  ports:
    - "443:443"
db:
  container_name: ll-db
  build: mongodb/2.6
  hostname: docker.dev
  environment:
    MONGODB_PASS: 'password'
  ports:
    - "27017:27017"
    - "28017:28017"
```
