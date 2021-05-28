#транзакции построчно в файле, найти количество транзакций/сумму доходов и во сколько раз отличаются доходы у опр user'a за первое полугодие и второе 

import ast
 
from datetime import datetime
 
d = {}
user = "6893471494264041902476759713387637260397696323592049455435171115739407560315033370567624081459643613290304703351527410005665278225022404900561112668260023"
# 1-input, 2 -send, 3-receive, 4-cash ; 11-функция input 1полугодие и тд
s11 = 0  # сумма для всех по номерам функций
s12 = 0
s22 = 0
s21 = 0
s31 = 0
s32 = 0
s41 = 0
s42 = 0
 
us11 = 0  # сумма доходов по пользователю
us12 = 0
us22 = 0
us21 = 0
us31 = 0
us32 = 0
us41 = 0
us42 = 0
 
# количество транзакций
count11 = 0  # inp
count12 = 0
count21 = 0  # send
count22 = 0
count31 = 0  # receive
count32 = 0
count41 = 0
count42 = 0
 
def month():
    t = int(d["time"])
    date = str(datetime.fromtimestamp(t).isoformat())
    dt = date[5:7]
    if dt[0] == "0":
        dt = dt[1:2]
    if int(dt) <= 6:
        return 1
    else:
        return 2
 
 
with open('t2.txt') as f:
    for line in f:
        text = f.readline()
        d = ast.literal_eval(text)
 
        if d["type"] == 'receive' and month() == 1:
            if str(d["to"]) == user:
                us31 += int(d["value"])
            count31 += 1
            s31 += int(d["value"])
        elif d["type"] == 'receive' and month() == 2:
            if str(d["to"]) == user:
                us32 += int(d["value"])
            count32 += 1
            s32 += int(d["value"])
        elif d["type"] == 'input' and month() == 1:
            if str(d["from"]) == user:
                us11 += int(d["value"])  # input 1 полугодие -доходы
            count11 += 1
            s11 += int(d["value"])
        elif d["type"] == 'input' and month() == 2:
            if str(d["from"]) == user:
                us12 += int(d["value"])
            count12 += 1
            s12 += int(d["value"])
 
 
        elif d["type"] == 'send' and month() == 1:  # send -расходы
            if str(d["from"]) == user:
                us21 += int(d["value"])
            count21 += 1
            s21 += int(d["value"])
        elif d["type"] == 'send' and month() == 2:
            if str(d["from"]) == user:
                us22 += int(d["value"])
            count22 += 1
            s22 += int(d["value"])
        elif d["type"] == 'cash' and month() == 1:
            if str(d["from"]) == user:
                us41 += int(d["value"])
            count41 += 1
            s41 += int(d["value"])
        elif d["type"] == 'cash' and month() == 2:
            if str(d["from"]) == user:
                us42 += int(d["value"])
            count42 += 1
            s42 += int(d["value"])
 
str1 = "Количество транзакций с доходами за каждое полугодие: "
str2 = "Cумма доходов за каждое полугодие: "
str3 = "Во сколько раз отличаются доходы заданного пользователя: "
 
print("Мы решили задачу 4 вариантами:\n")
print("1 - считаем за сумму доходов(влияют на 2 и 3 пункт тз) только функцию receive, 2 - receive+input, 3 - receive+input-send-cash, 4 - receive-send\n")
 
print("1.")
print(str1, count31, " и ", count32)
print(str2, s31, " и ", s32)
print(str3,round((us31 / us32), 2))
 
print("\n2.")
print(str1, count31 + count11, " и ", count32 + count12)
print(str2, s11 + s31, " и ", s12 + s32)
print(str3,round(((us31 + us11) / (us32 + us12)),2))
 
print("\n3.")
print(str1, count31 + count11, " и ", count32 + count12)
print(str2, s11 + s31 - s21 - s41, " и ", s12 + s32 - s22 - s42)
print(str3,round(abs((us11 + us31 - us21 - us41) / (us12 + us32 - us22 - us42)),2))
 
print("\n4.")
print(str1, count31, " и ", count32)
print(str2, s31 - s21, " и ", s32 - s22)
print(str3,round(abs((us31 - us21) / (us32 - us22)),2))
