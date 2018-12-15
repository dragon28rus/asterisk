#!/bin/sh

#rm -f /tmp/*.wav

echo "Начинаем"

while read number numdog summ tariff; do

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

sleep 5

#Округляем баланс до целого числа
summ=$(echo "$summ/1.0" | bc)

#Скланяем рубль
n=$(($summ % 100))
n1=$(($n % 10))
if [ $n -gt 10 -a $n -lt 20 ]; 
then
    balansrub="рублей";
elif [ $n -gt -20 -a $n -lt -10 ]; 
then
    balansrub="рублей";
elif [ $n1 -gt 1 -a $n1 -lt 5 ]; 
then 
    balansrub="рубля";
elif [ $n1 -gt -5 -a $n1 -lt -1 ]; 
then 
    balansrub="рубля";
elif [ $n1 -eq 1 ]; 
then 
    balansrub="рубль";
elif [ $n1 -eq -1 ]; 
then 
    balansrub="рубль";
else
    balansrub="рублей"
fi

# Делим номер договора для лучшего восприятия
if (( "${#numdog}" > 4 ))
then
    numberstart=${numdog:0:3}
    numberend=${numdog:3}
elif (( "${#numdog}" == 4 ))
then
    numberstart=${numdog:0:2}
    numberend=${numdog:2}
else
    numberstart=${numdog:0}
    numberend=" "
fi

# Формируем текст для яндекса учитывая тип услуги 0-Интернет; 1-КТВ; 2-ЦКТВ
if [ $tariff -eq 1 ];
then
    text="Кабельные системы сообщают, что услуги кабельного телевидения по договору, $numberstart  $numberend ,  необходимо оплатить до 8го числа текущего месяца! Так же сообщаем что 3 ноября абонентский отдел работает до 18 часов, четвертого ноября абонентский отдел не работает. в остальные дни с 8 до 19 часов без перерыва! Спасибо что пользуетесь нашими услугами."
elif [ $tariff -eq 2 ];
then
    text="Кабельные системы сообщают, что услуга цифровое телевидение по договору, $numberstart  $numberend , приостановленна. Для активации  услуг пополните баланс. Так же сообщаем что 3 ноября абонентский отдел работае�� до 18 часов, четвертого ноября абонентский отдел не работает. в остальные дни с 8 до 19 часов без перерыва! Спасибо что пользуетесь нашими услугами."
else
    text="Кабельные системы сообщают, что баланс по договору, $numberstart  $numberend , составляет $summ, $balansrub ! Не забудьте пополнить Ваш баланс!"
fi

# Отправляемся в яндекс за голосовым файликом и сохраняем его в /temp с номером телефона
#curl "https://tts.voicetech.yandex.net/generate?format=wav&quality=lo&lang=ru-RU&speaker=oksana&emotion=good&key=cbea8524-b886-45c5-bd7e-5540998c89ee" -G --data-urlencode "text=$text" > /tmp/$number.wav #ключ it@dvsat.ru
curl "https://tts.voicetech.yandex.net/generate?format=wav&quality=lo&lang=ru-RU&speaker=oksana&emotion=good&key=74f4650a-cef9-4066-94e1-a77d54fb4553" -G --data-urlencode "text=$text" > /tmp/$number.wav  #ключ info@dvsat.ru

#Даем соответствующие права файлу
chown asterisk:asterisk /tmp/$number.wav
chmod 775 /tmp/$number.wav

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
Set: arg1=$number

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

        if [ "$count_f" -eq "170" ]; then
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