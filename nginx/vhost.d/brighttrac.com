location /static/ {
    alias /brighttrac/static/;
}

#location /blcore/custom/static/ {
#    alias /custom/static/;
#}

location /blcore/static/ {
    alias /blcore/static/;
}

location /admin/webtop/static/ {
    alias /webtop/static/;
}
