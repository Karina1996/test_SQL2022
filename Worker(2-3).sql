drop table if exists Employee 
drop table if exists Vacation

-- Справочник сотрудников
create table Employee (
    ID int not null primary key,
    Code varchar(10) not null unique,
    Name_ varchar(255) 
)

insert into Employee (ID, Code, Name_)
    values (1, 'E01', 'Ivanov Ivan Ivanovich'),
    (2, 'E02', 'Petrov Petr Petrovich'),
    (3, 'E03', 'Sidorov Sidr Sidorovich')
-- 3 записи

-- Отпуска сотрудников
create table Vacation (
    ID int not null identity(1, 1) primary key, -- автоинкремент начинается с 1, последующие значения +1
    ID_Employee int not null references Employee(ID), -- связь с родительской таблицей Employee
    DateBegin date not null,
    DateEnd date not null
    )

insert into Vacation (ID_Employee, DateBegin, DateEnd)
    values (1, '2019-08-10', '2019-09-01')
    ,(1, '2019-05-13', '2019-06-02')
    ,(1, '2019-12-29', '2020-01-14')
    ,(2, '2019-05-01', '2019-05-15')
-- 4 записи

-- Вывести имена сотрудников, которые не были в отпуске в 2020 году
-- Должно вернуться 2 строки: Petrov Petr Petrovich, Sidorov Sidr Sidorovich
-- * - задание желательно решить без использования DISTINCT

SELECT Name_
    FROM Employee E LEFT JOIN Vacation V ON E.ID = V.ID_Employee
    WHERE DateEnd IS NULL OR ID NOT IN( SELECT ID_Employee FROM Vacation
                              WHERE DateEnd BETWEEN '2020-01-01' AND '2020-12-31')


/*Из таблицы Vacation видно, что сотрудник с кодом = 2 не был в отпуске в 2020 году, также видно,
что сотрудник с кодом = 3 вообще не был в отпуске => действительно, запрос должен вернуть 2 записи

Условия в операторе WHERE:
    DateEnd IS NULL - вообще не был в отпуске (сотрудника нет в таблице Vacation)
    в подзапросе отбираю идентификаторы сотрудников, которые не были в отпуске в 2020 году
    ID IN( SELECT ID_Employee FROM Vacation WHERE DateEnd NOT BETWEEN '2020-01-01' AND '2020-12-31') - не был в отпуске в 2020
Оператор IN определяет, совпадает ли значение ID со значением в списке.
BETWEEN '2020-01-01' AND '2020-12-31' - отбирает записи для заданного диапозона значений.
*/

-- Написать запрос для данных из Worker.sql, который выводит список периодов и кол-во сотрудников находившихся в этот период в отпуске. 
-- Необходимо сделать тестовый пример, который воспроизводит разные ситуации пересечения отпусков. 
-- Результат должен быть со столбцами: DateBegin, DateEnd, Count. Периоды должны быть расположены последовательно. 
-- Вывести периоды, в которые не было ни одного человека в отпуске. Т.е. чтобы в Count для некоторых периодов была цифра 0.

-- Tестовый пример, который воспроизводит разные ситуации пересечения отпусков. ???
-- Пусть отпуск двухнедельный.. пересечения отпусков для ID = 1, ID = 2:
insert into Vacation (ID_Employee, DateBegin, DateEnd)
    values (1, '2022-01-11', '2022-01-25')
    ,(1, '2022-02-05', '2022-02-19')
    ,(1, '2022-03-14', '2022-03-28')
    ,(1, '2022-04-09', '2022-04-23')
    ,(1, '2022-05-29', '2022-06-12')
    ,(2, '2022-01-11', '2022-01-25') -- ситуация, когда несколько сотрудников отдыхают в один календарный период 
    ,(2, '2022-02-10', '2022-02-24') -- ситуация, когда один из сотрудников ещё в отпуске -> отправился другой
-- 7 записей

-- drop table mysql.Vacation;
-- delete from mysql.Vacation;

ИСПРАВЛЕНО: [тест](https://app.codingrooms.com/w/O40Tryq9N4IM)

-- SELECT * FROM mysql.Vacation;

WITH my_subquery_new_dates as
	( SELECT new_date, SUM(Inc) as sum_Inc
        FROM (SELECT DateBegin as new_date, 0 as Inc FROM mysql.Vacation 
              UNION 
              SELECT DateEnd as new_date, 1 as Inc FROM mysql.Vacation 
        ) as new_tab_1
        GROUP BY new_date
    ),
    new_tab_2 as
    ( SELECT V1.DateEnd as DE, V2.DateBegin as DB FROM mysql.Vacation V1 JOIN mysql.Vacation V2 ON V1.ID_Employee != V2.ID_Employee
        WHERE V1.DateEnd BETWEEN V2.DateBegin AND V2.DateEnd
    )

SELECT LAG(new_date, 1) OVER (ORDER BY new_date) as DateBegin, 
            new_date as DateEnd, 
            (CASE 
                WHEN new_date IN(SELECT DE FROM new_tab_2) THEN sum_Inc+1
                WHEN new_date IN(SELECT DB FROM new_tab_2 ) THEN sum_Inc+1
                ELSE sum_Inc
            END) as Count
FROM my_subquery_new_dates;

/*На первом шаге (в первом подзапросе) составила даты всех возможных интервалов, потому что дата окончания отпуска какого-то сотруднгика будет датой начала нового интервала. То есть, нужно чтобы даты начала интервала и даты окончания интервала находились в одной колонке. Без оператора UNION этого не сделать не получилось. Немного помогло: https://www.sqlshack.com/sql-lag-function-overview-and-examples.
Намучилась с подсчетом кол-ва..

С помощью оконной функции вывела предыдущее значение столбца по порядку сортировки new_date - LAG(new_date, 1) OVER (ORDER BY new_date)

Оконная функция - функция, которая работает с выделенным набором строк (окном, партицией) и выполняет вычисление для этого набора строк в отдельном столбце. 

Главное отличие оконных функций от функций агрегации с группировкой? 
При использовании агрегирующих функций предложение GROUP BY сокращает количество строк в запросе с помощью их группировки.
При использовании оконных функций количество строк в запросе не уменьшается по сравнении с исходной таблицей.*/
