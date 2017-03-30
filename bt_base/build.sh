NAME="bt_base"

if [ -z "$SOURCE_ROOT" ]
then
    SOURCE_ROOT=$HOME/src
fi

echo "SOURCE_ROOT: $SOURCE_ROOT"


docker rm $NAME
docker build -t "$NAME" .

docker run -i --name "$NAME" \
  -v "$SOURCE_ROOT:/brightlink_dev" -u docker "$NAME" /bin/bash <<'EOF'

PIP="/home/docker/docker_env/bin/pip install --extra-index https://devpi.thebrightlink.com/ops/brightlink/+simple/ "
PYTHON="/home/docker/docker_env/bin/python"


# Install the base Python packages
$PIP --allow-all-external --allow-unverified PEAK-Rules --allow-unverified CherryPy --allow-unverified cElementTree --allow-unverified elementtree --allow-unverified pyDes -r /brightlink_dev/ndeb/requirements.txt
$PIP -r /brightlink_dev/infrastructure/blcore/requirements.txt
$PIP -r /brightlink_dev/infrastructure/bltemplates/requirements.txt
$PIP pytest pytest-xdist pdbpp


# Install our packages
for package in blcore blauthentication blconfig blerrorhandling bllang blnotification blexcel blrules blfilter bllocking blscripts blcrypto blintegration blmonitor bltemplates blwebtop bllegacy template_resolver blpayments switchboard turborest blmobilelink; do
    cd /brightlink_dev/infrastructure/$package
    $PYTHON setup.py develop
    cd -
done

EOF

if [[ $? -eq 0 ]]
then
  docker commit "$NAME" "$NAME"
  docker rm "$NAME"
fi
