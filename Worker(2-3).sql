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

ИСПРАВЛЕНО: 
-- Тест решения: https://app.codingrooms.com/w/CV9Xbvi4h9X5 (созданиеЮ добавление, выборка по схеме: mysql.Vacation - БД.Таблица)

WITH my_subquery_new_dates AS 
	( SELECT new_date, SUM(Inc) AS Count
        FROM (SELECT DateBegin AS new_date, 0 AS Inc FROM mysql.Vacation
            UNION ALL
            SELECT DateEnd AS new_date, 1 AS Inc FROM mysql.Vacation 
     ) AS new_tab
        GROUP BY new_date ) 

SELECT LAG(new_date, 1) OVER (ORDER BY new_date) AS DateBegin, new_date AS DateEnd, Count
FROM my_subquery_new_dates
ORDER BY new_date

-- /*В первом подзапросе составила даты всех возможных интервалов, потому что дата окончания отпуска какого-то сотрудника будет датой начала нового интервала. 
То есть, нужно чтобы даты начала интервала и даты окончания интервала находились в одной колонке. Без оператора UNION этого не сделать не получилось. 
Немного помогло: https://www.sqlshack.com/sql-lag-function-overview-and-examples.
-- Намучилась с подсчетом кол-ва.. с всем известным оператором COUNT не работает..*/

