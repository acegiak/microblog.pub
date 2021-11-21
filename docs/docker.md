### Docker Compose Deployment

To spawn the docker-compose project (running this command will also update _microblog.pub_ to latest and restart everything if it's already running):

```shell
$ make run
```

By default, the server will listen on `localhost:5005` (http://localhost:5005 should work if you're running locally).

For production, you need to setup a reverse proxy (nginx, caddy) to forward your domain to the local server 
(and check [certbot](https://certbot.eff.org/) for getting a free TLS certificate).