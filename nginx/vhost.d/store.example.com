location /static/ {
    alias /clarus/brighttrac2/store/static/;
}

# FIXME!
location /custom/static/ {
    alias /brightlink_dev/clarus/nha/static/;
}
