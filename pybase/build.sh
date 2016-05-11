set -e

docker build --build-arg UID=$UID --build-arg GID=$(id -g) -t pybase .
