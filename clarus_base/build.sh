NAME="clarus_base"

if [ -z "$SOURCE_ROOT" ]
then
    SOURCE_ROOT=$HOME/src
fi

echo "SOURCE_ROOT: $SOURCE_ROOT"

GUEST_ROOT=/brightlink_dev


docker rm $NAME
docker build -t "$NAME" .


docker run -i --name "$NAME" \
  -e SOURCE_ROOT="$GUEST_ROOT" -v "$SOURCE_ROOT:$GUEST_ROOT" -u docker "$NAME" /bin/bash <<'EOF'

set -e


CLARUS_ROOT=$SOURCE_ROOT/clarus/clarus
MODULES_ROOT=$SOURCE_ROOT/infrastructure


# update virtualenv
/home/docker/docker_env/bin/pip install -U pip


PIP="/home/docker/docker_env/bin/pip install -i https://devpi.thebrightlink.com/ops/brightlink/+simple/ "
PYTHON="/home/docker/docker_env/bin/python"


# Install the base Python packages
$PIP --allow-all-external --allow-unverified PEAK-Rules --allow-unverified CherryPy --allow-unverified cElementTree --allow-unverified elementtree --allow-unverified pyDes -r $CLARUS_ROOT/requirements.txt
$PIP -r $MODULES_ROOT/blauthentication/requirements.txt
$PIP -r $MODULES_ROOT/blcore/requirements.txt
$PIP -r $MODULES_ROOT/bltemplates/requirements.txt
$PIP pytest pytest-xdist pdbpp django-debug-toolbar==0.9.1


$PIP -r $MODULES_ROOT/satchmo_braintree/requirements.txt
$PIP -e $MODULES_ROOT/satchmo_braintree


# Install our packages
for package in blcore blauthentication blconfig blerrorhandling bllang blnotification blexcel blrules blfilter bllocking blscripts blcrypto blintegration blmonitor bltemplates blwebtop utctime template_resolver blpayments switchboard turborest ; do
    cd $MODULES_ROOT/$package
    $PYTHON setup.py develop
    cd -
done

$PIP -e $SOURCE_ROOT/clarus/compass


# Fix Django translations, templates, and other data files
. /home/docker/docker_env/bin/activate
python /home/docker/fix_django_files.py
rm /home/docker/fix_django_files.py

EOF

if [[ $? -eq 0 ]]
then
  docker commit "$NAME" "$NAME"
  docker rm "$NAME"
fi
