#!/bin/sh

#sayit () { espeak -v ru -s100; }
sayit () { festival --tts --language russian; }
#sayit () { mplayer -ao alsa -really-quiet -noconsolecontrols "http://translate.google.com/translate_tts?tl=ru&q=$*"; }

TASKPATH="/home/kgbplus/pispeaker/tasks/"  # путь к файлам заданий

while [ 1 ]; do
  TASK=`ls -l $TASKPATH | grep -v ^d | sed -n 2p | awk ' {print $9} '`

  if [ -n "$TASK" ]; then
    TASKTYPE=${TASK#*.}
    echo name=$TASK, type=$TASKTYPE

    if [ "$TASKTYPE" = "txt" ]; then
      cat $TASKPATH$TASK | sayit   # для espeak и festival
#      sayit `cat $TASKPATH$TASK`   # для google
    fi

    if [ "$TASKTYPE" = "mp3" ]; then
      omxplayer $TASKPATH$TASK     # raspberry pi
#      mplayer $TASKPATH$TASK       # ubuntu
    fi

    rm -f $TASKPATH$TASK
    if [ $? -ne 0 ]; then
      echo "Что то пошло не так" || exit 1   # не удалился файл выполненного задания
    fi
  fi

  sleep 1
done

exit 0
