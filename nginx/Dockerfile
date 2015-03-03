FROM nginx
MAINTAINER Daniel Rocco <drocco@gmail.com>

# Set the nginx user to have read permission for the mounted static
# files on the host.
RUN usermod -u 1000 nginx

# Run nginx in foreground mode
RUN ["/bin/bash", "-c", "echo -e '\ndaemon off;' >> /etc/nginx/nginx.conf"]

# Install our server configuration
COPY default /etc/nginx/conf.d/default.conf

# Run nginx when the container starts
CMD ["nginx"]
