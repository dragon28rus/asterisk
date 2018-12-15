#!/bin/sh

rm -f /tmp/*.wav

echo "Начинаем"

# Формируем текст для яндекса
    text="Уважаемые абонент! 17 декабря, в период с 9 до 12 часов, возможно отключение кабельного ТВ, по причине проведения профилактических работ на линии связи. Прин+осим свои извенения за доставленные неудобства.."

# Отправляемся в яндекс за голосовым файликом и сохраняем его в /temp
curl "https://tts.voicetech.yandex.net/generate?format=wav&quality=lo&lang=ru-RU&speaker=oksana&emotion=good&key=cbea8524-b886-45c5-bd7e-5540998c89ee" -G --data-urlencode "text=$text" > /tmp/message.wav #ключ it@dvsat.ru
#curl "https://tts.voicetech.yandex.net/generate?format=wav&quality=lo&lang=ru-RU&speaker=oksana&emotion=good&key=74f4650a-cef9-4066-94e1-a77d54fb4553" -G --data-urlencode "text=$text" > /tmp/message.wav  #ключ info@dvsat.ru

#Даем соответствующие права файлу
chown asterisk:asterisk /tmp/message.wav
chmod 775 /tmp/message.wav


while read number; do

sleep 5

#В период с 18 до 09 часов не звоним
echo "Проверяем текущий час - `date +%H`"
while ((`date +%H` > 17 || `date +%H` < 9))
do
    echo "Время позднее, спать пора"
    sleep 3600
done

#Приводим федеральный номер в нужный формат
if [[ $number =~ ^[+][7]+[0-9]{10}$ ]];
then
    number=8${number:2}
elif [[ $number =~ ^[7]+[0-9]{10}$ ]];
then
    number=8${number:1}
fi

#Проверяем на валидность номера телефона, пропускаем сотовые номера с 8 и городские 6ти значные
if [[ $number =~ ^[8]+[0-9]{10}$ ]] ||  [[ $number =~ ^[0-9]{6}$ ]];
then

#Channel: Local/s@outboundmsg
#Формируем файл для астериска для автоматического прозвона
cat <<EOF  >  /var/spool/asterisk/$number

Channel: Local/$number@from-dialer
MaxRetries: 0
Account: autodialer
Context: dialer-message
Extension: $number
RetryTime: 3600
WaitTime: 50
Priority: 1
Callerid: $number
Set: __ARG1=message

EOF

# Назначаем права файлу и ложим в нужное место
    chown asterisk:asterisk /var/spool/asterisk/$number
    mv /var/spool/asterisk/$number  /var/spool/asterisk/outgoing

    echo "$number"

    number=`expr $number + 1`

    while [ "$?" -eq "0" ]
    do
count_files ()

{
    count_f=`ls /var/spool/asterisk/outgoing | wc -l`

        if [ "$count_f" -eq "30" ]; then
            sleep 10
            return 0
        else
            return 1
        fi
}
    count_files
    done
else
    echo $number
fi

done < /home/dragon28rus/list.txt

exit 0