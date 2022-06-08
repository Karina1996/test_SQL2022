-- Если существует таблица - выполнится удаление??
-- drop table if exists Employee 
-- drop table if exists Vacation

-- Справочник сотрудников
create table Employee (
    ID int not null primary key,
    Code varchar(10) not null unique,
    Name_ varchar(255) 
)

insert into Employee (ID, Code, Name)
    values (1, 'E01', 'Ivanov Ivan Ivanovich'),
    (2, 'E02', 'Petrov Petr Petrovich'),
    (3, 'E03', 'Sidorov Sidr Sidorovich')

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

-- Задача. Вывести имена сотрудников, которые не были в отпуске в 2020 году
-- Должно вернуться 2 строки: Petrov Petr Petrovich, Sidorov Sidr Sidorovich
-- * - задание желательно решить без использования Distinct

-- SELECT Name_ FROM Employee E JOIN Vacation V ON E.ID = V.ID_Employee
-- WHERE V.ID_Employee NOT EXISTS (SELECT YEAR(DateBegin) =)

SELECT Name_ FROM Employee
    WHERE ID NOT IN(SELECT ID_Employee FROM Vacation 
                    WHERE DateEnd BETWEEN '01.01.2020' AND '31.12.2020')


-- ????

