location /static/ {
    alias /clarus/brighttrac2/store/static/;
}

location /media/ {
    alias /clarus/brighttrac2/store/static/admin/;
}

location /admin_media/ {
    alias /clarus/brighttrac2/store/static/admin/;
}
