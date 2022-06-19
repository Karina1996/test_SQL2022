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

ИСПРАВЛЕНО: 


-- -- (создание, добавление, выборка, удаление по схеме: mysql.Vacation - БД.Таблица)
-- -- чтобы выполнить запросы, нажмите FORK в правом верхнем углу

-- -- Отпуска сотрудников
create table if not exists mysql.Vacation (
    ID_Employee int not null references Employee(ID), -- связь с родительской таблицей Employee
    DateBegin date not null,
    DateEnd date not null
    );

insert into mysql.Vacation (ID_Employee, DateBegin, DateEnd)
   values (1, '2022-01-11', '2022-01-25'),
            (2, '2022-01-11', '2022-01-25'), -- ситуация, когда несколько сотрудников отдыхают в один календарный период 
            (1, '2022-02-05', '2022-02-19'),
            (2, '2022-02-10', '2022-02-24'), -- ситуация, когда один из сотрудников ещё в отпуске -> отправился другой
                (3, '2022-02-10', '2022-02-24'); -- ситуация, когда один из сотрудников ещё в отпуске -> отправился другой
    
-- -- drop table mysql.Vacation; (удалить таблицу)
-- delete from mysql.Vacation; -- очистить данные 

SELECT * FROM mysql.Vacation ORDER BY DateBegin, DateEnd; -- исходные данные

-- - РЕШЕНИЕ 1: (не корректный вывод!)

-- WITH -- обобщенное табличное выражение
-- -- подзапрос №1 (1)
-- tab_new_dates as
--         ( SELECT new_dates, Inc
--             FROM -- подзапрос №2
--                 (SELECT DateBegin as new_dates, 0 as Inc FROM mysql.Vacation 
--                 UNION
--                 SELECT DateEnd as new_dates, 1 as Inc FROM mysql.Vacation
--                 ) as tab_union
--         ),
-- -- подзапрос №3 (2)
-- tab_crossing as 
--         ( SELECT V2.DateBegin as DE, V2.DateEnd as DB, count(V1.ID_Employee) over (partition by V1.ID_Employee) as new_Inc
--             FROM mysql.Vacation V1 JOIN mysql.Vacation V2 ON V1.ID_Employee != V2.ID_Employee
--             WHERE V1.DateEnd BETWEEN V2.DateBegin AND V2.DateEnd
--         ),
-- -- подзапрос №4 (3) 
--tab_results as 
--         (SELECT LAG(new_dates, 1) OVER (ORDER BY new_dates) as DateBegin, 
--                 new_dates as DateEnd, 
--                 (CASE ??????????? 
--                     WHEN new_dates = (SELECT DB FROM tab_crossing WHERE DB = new_dates LIMIT 1) 
                            -- THEN Inc + (SELECT new_Inc FROM tab_crossing WHERE DB = new_dates LIMIT 1)-1
--                     WHEN new_dates = (SELECT DE FROM tab_crossing WHERE DE = new_dates LIMIT 1) 
                            -- THEN Inc + (SELECT new_Inc FROM tab_crossing WHERE DE = new_dates LIMIT 1)-1
--                     ELSE Inc
--                 END) as Count
--         FROM tab_new_dates
--         )

-- -- ВЫВОД ДАННЫХ В ВИРТУАЛЬНЫХ ТАБЛИЦАХ ВЫПОЛНИТЬ ОДНОВРЕМЕННО НЕ ПОЛУЧИТСЯ!
-- -- 1. Объединила даты начала и окончания периода в один столбец new_data (с помощью union), установила счётчик, объединила в группы, чтобы посчитать кол-во в группах (каждая группа уникальна).
-- -- здесь new_dates (уникальные записи), которые нужно сравнить с диапозоном дат пересечений!
-- -- SELECT new_dates FROM tab_new_dates -- склеили строки значений DateBegin со значениями DateEnd

-- -- 2. Нашла возможные пересечения дат для разных работников (с помощью self join)
-- SELECT * FROM tab_crossing; -- нашли пересечения дат отпусков для всех дат, которые имеются в исходной таблице

-- -- 3.  В основном подзапросе (tab_results) с помощью оконной функции (функции смещения LAG) взяла предыдущее значение за begin, оставшееся - end, 
-- -- так как нам нужно взять дату окончания отпуска за дату начала отпуска следующей записи. Оператором case (if) сделала условие, когда выводим 
-- -- исходный count , также новый инкремент , если пересечение есть (причём нужные значения отбирались в разных столбцах, поэтому пришлось два when прописывать для разных столбцов...
-- -- SELECT * FROM tab_results; -- выполнили поздапросы в результирующем подзапросе, который вернул, также, таблицу

-- РЕШЕНИЕ 2: (ОК)
-- посчитать с помощью оконной функции получилось, УРА!
WITH
  tab_new_dates AS (
    SELECT new_dates, SUM(Inc) AS Inc
      FROM (
        SELECT '2022-01-01' AS new_dates, 0 AS `inc`
        UNION ALL
          SELECT '2022-12-31', 0
        UNION ALL
          SELECT DateBegin as new_dates, +1
            FROM mysql.Vacation
        UNION ALL
          SELECT DateEnd as new_dates, -1
            FROM mysql.Vacation
      ) AS tab_union
      GROUP BY new_dates
    )
SELECT LAG(new_dates, 1) OVER (ORDER BY new_dates) AS DateBegin,
       new_dates AS DateEnd,
       (SUM(Inc) OVER (ORDER BY new_dates)) - Inc AS Count
  FROM tab_new_dates
