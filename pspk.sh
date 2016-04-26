#!/bin/sh

TASKPATH="/var/ftp/tasks/" # путь к файлам заданий
MAXVOLUME=151

#sayit () { festival --tts --language russian; }
sayit () { /usr/local/bin/RHVoice -p 1.9 -r 1.3 -d /usr/local/share/rhvoice/Elena | aplay -D plughw:3,0;}
#sayit () { RHVoice -d /usr/local/share/rhvoice/Aleksandr | aplay;}
#sayit () { RHVoice | aplay;}

settings_toy () {
  VOLUME=$(echo "scale=2; `cat /root/settings.toy | grep volume | awk ' {print $3} '` * $MAXVOLUME" | bc)
  MUTE=`cat /root/settings.toy | grep mute | awk ' {print $3} '`

  echo volume=$VOLUME, mute=$MUTE
  if [ "$MUTE" = "1" ]; then
    amixer -c 3 cset numid=2,iface=MIXER,name='PCM Playback Volume' mute 
  else
    amixer -c 3 cset numid=2,iface=MIXER,name='PCM Playback Volume' $VOLUME
  fi
}

while [ 1 ]; do
  TASK=`ls -l $TASKPATH | grep -v ^d | sed -n 2p | awk ' {print $9} '`

  if [ -n "$TASK" ]; then
    TASKTYPE=${TASK#*.}
    echo name=$TASK, type=$TASKTYPE

    if [ "$TASKTYPE" = "zip" ]; then
      unzip $TASKPATH$TASK *.rus *.mp3 -d$TASKPATH
    fi

    if [ "$TASKTYPE" = "rus" ]; then
      settings_toy
      cat $TASKPATH$TASK | sayit # для espeak и festival
    fi

    if [ "$TASKTYPE" = "mp3" ]; then
      settings_toy
      mplayer -ao alsa:device=hw=3.0 $TASKPATH$TASK # ubuntu
    fi

    if [ "$TASKTYPE" = "toy" ]; then
      cp $TASKPATH$TASK /root
#      rm -f $TASKPATH$TASK
    fi

    cp $TASKPATH$TASK /var/ftp/tasks/processed
    rm -f $TASKPATH$TASK
    if [ $? -ne 0 ]; then
      echo "Что то пошло не так" || exit 1 # не удалился файл выполненного задания
    fi
  fi

  sleep 5
done

exit 0
