NAME="bt_base"
SOURCE_ROOT=$HOME/source/brightlink
PIP_DOWNLOAD_CACHE=$HOME/.cache/pip


docker rm $NAME
docker build -t "$NAME" .

docker run -i --name "$NAME" \
  -v "$SOURCE_ROOT:/brightlink_dev" -v "$PIP_DOWNLOAD_CACHE:/home/docker/.cache/pip" -u docker "$NAME" /bin/bash <<'EOF'

export PIP_DOWNLOAD_CACHE=$HOME/.cache/pip
PIP="/home/docker/docker_env/bin/pip install "
PYTHON="/home/docker/docker_env/bin/python"

$PIP /brightlink_dev/packages/trml2pdf/trml2pdf-1.0.tar.gz

for package in /brightlink_dev/packages/forks/elixir/trunk ; do
    cd $package

    # not develop because it breaks django
    $PYTHON setup.py install
    cd -
done


# Install the base Python packages
$PIP --allow-all-external --allow-unverified PEAK-Rules --allow-unverified CherryPy --allow-unverified cElementTree --allow-unverified elementtree --allow-unverified pyDes -r /brightlink_dev/ndeb/requirements.txt
$PIP -r /brightlink_dev/modules-git/blcore/requirements.txt
$PIP -r /brightlink_dev/modules-git/bltemplates/requirements.txt
$PIP pytest pytest-xdist pdbpp


# Install our packages
for package in blcore blauthentication blconfig blerrorhandling bllang blnotification blexcel blrules blfilter bllocking blscripts blcrypto blintegration blmonitor bltemplates blwebtop bllegacy template_resolver blpayments switchboard turborest ; do
    cd /brightlink_dev/modules-git/$package
    $PYTHON setup.py develop
    cd -
done

EOF

if [[ $? -eq 0 ]]
then
  docker commit "$NAME" "$NAME"
  docker rm "$NAME"
fi
