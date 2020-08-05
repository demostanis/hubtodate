# This file is to run HubToDate inside of Docker
# A normal user should take a look at ./install.sh
# and `hubtodate` command to run

COMMAND=$(test $1 && echo $1 || echo run)
case $COMMAND in
  run)
    docker run -v "$(pwd):/app" -it hubtodate
  ;;

  build)
    docker build . -t hubtodate
  ;;

  *)
    echo "Invalid command"
    exit 1
  ;;
esac
