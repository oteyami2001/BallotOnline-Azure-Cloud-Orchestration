# Nginx Configuration

[`nginx.conf`](nginx.conf) is the Nginx configuration used for the
BallotOnline web server in the proof of concept.

The key part is the server block that serves the website from
`/data/www/BallotOnline` on port 80:

```nginx
index   index.html index.htm;

server {
    location / {
        root /data/www/BallotOnline;
    }
}
```

The rest of the file is the standard packaged Nginx configuration, with
the default server and the TLS example left commented out.

## Notes

- With no `listen` directive, the server block listens on port 80, which
  matches the Network Security Group rule and the load balancer health
  probe (HTTP :80 `/`).
- The file sets `user nginx;`, the default on RHEL-family systems.
  Ubuntu's Nginx package runs as `www-data`, so use `user www-data;` when
  copying this file to an Ubuntu VM.
- Always test before reloading: `sudo nginx -t && sudo systemctl reload nginx`.

The website files themselves are in [`website/`](../../website/).
