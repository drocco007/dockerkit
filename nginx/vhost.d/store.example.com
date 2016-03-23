location /static/ {
    alias /clarus/brighttrac2/store/static/;
}
