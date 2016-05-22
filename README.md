### Learning Locker LRS Docker container

This is a docker container for [Learning Locker](http://learninglocker.net).
As such, link to a running mongoDB container is required.

This Learning Locker uses Mongo 3.2.

#### Available tags

- hongymagic/learninglocker:1.12.1-http
- hongymagic/learninglocker:1.12.1, latest

All Dockerfile are managed in [this GitHub repo](https://github.com/hongymagic/learninglocker).

#### Example usage

Best usage is via `docker-compose`. Please checkout `docker-compose.yml` for
more detailed information.

```
> git clone git@github.com:hongymagic/learninglocker.git
> cd learninglocker
> docker-compose build
> docker-compose up
```

Make sure to map `lrs.docker.dev` to your `docker-machine`. Then [visit the HTTPS-enabled website](https://lrs.docker.dev).

#### Environment variables

> Users of this container are **strongly encourage** to change **all non-optional** environment variables when running this container.

##### Required

- `APP_URL`: FQDN of the final URL, if missing defaults to `TUTUM_SERVICE_FQDN` then `$HOSTNAME`
- `APP_SECRET_KEY`: [Encryption key](http://docs.learninglocker.net/installation/#configuration) used by learning locker. Defaults to `CHANGEME12345678`
- `SMTP_SERVER`
- `SMTP_PORT`
- `SMTP_USER`
- `SMTP_PASSWORD`
- `EMAIL_FROM_NAME`
- `EMAIL_FROM_ADDRESS`

##### Optional

- `MONGO_WAIT_TIMEOUT`: (_optional_) Time to wait before mongo container becomes live. Defaults to 10 seconds
- `AWS_S3_BUCKET_PATH`: (_optional_) AWS S3 Bucket path to download certificates from. The path should be of the form `s3://my-bucket/www.example.com/certs/*`. And below two keys are also required. If missing, will generate a self-signed certificate
	- `AWS_S3_ACCESS_KEY_ID`
	- `AWS_S3_SECRET_ACCESS_KEY`
