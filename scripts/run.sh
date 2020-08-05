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
