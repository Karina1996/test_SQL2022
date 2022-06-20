-- (Выберите: Run task4.sql)

-- В магазине на разных стеллажах (местах продаж) выложены товары. 
-- Информация об этом поступает в виде анкет (вопрос-ответ) из двух источников:
--     1. Анкета торгового агента (таблица gr_item1); 
--     2. Анкета аудитора (таблица gr_item2).

-- Необходимо выполнить сравнение анкет торгового агента с анкетами аудитора, 
-- чтобы понять, насколько достоверно торговый агент предоставил данные.

create table if not exists mysql.Group_ (
    ID int primary key,
    ByGroup bit
);

create table  if not exists mysql.gr_item1 (
    ID_Group int,
    Code varchar(100),
    Value_ varchar(100),
    IsPrimary bit,
    primary key (ID_Group, Code),
    foreign key(ID_Group) references mysql.Group_(ID)
);

create table  if not exists mysql.gr_item2 (
    ID_Group int,
    Code varchar(100),
    Value_ varchar(100),
    IsPrimary bit,
    primary key (ID_Group, Code),
    foreign key(ID_Group) references mysql.Group_(ID)
);

insert ignore into mysql.Group_ values (1, 1), (2, 0), (3, 0), (4, 0); 

insert ignore into mysql.gr_item1 values -- анкета агента
    (1, 'Место продаж', 'Основная полка', 0), (1, 'Длина полки', '3', 0),
    (1, 'Высота выкладки', '120', 0), (1, 'Кол-во товаров', '42', 0),
    (2, 'Место продаж', 'Навеска 1', 0), (2, 'Бренд', 'Greenland', 1),
    (2, 'Длина выкладки', '20', 0), (2, 'Кол-во товаров', '10', 0),
    (3, 'Место продаж', 'Навеска 2', 0), (3, 'Бренд', 'Freefly', 1),
    (3, 'Длина выкладки', '60', 0), (3, 'Кол-во товаров', '40', 0),
    (4, 'Место продаж', 'Навеска 3', 0), (4, 'Бренд', 'Coco', 1),
    (4, 'Длина выкладки', '50', 0), (4, 'Кол-во товаров', '30', 0);

insert ignore into mysql.gr_item2 values -- анкета аудитора
    (1, 'Место продаж', 'Основная полка', 1), (1, 'Длина полки', '4', 0), 
    (1, 'Высота выкладки', '125', 0), (1, 'Кол-во товаров', '42', 0),
    (2, 'Место продаж', 'Навеска 1', 0), (2, 'Бренд', 'Coco', 1),
    (2, 'Длина выкладки', '60', 0), (2, 'Кол-во товаров', '', 0),
    (3, 'Место продаж', 'Навеска 2', 0), (3, 'Бренд', 'Greenland', 1),
    (3, 'Длина выкладки', '30', 0) , (3, 'Кол-во товаров', '5', 0),
    (4, 'Место продаж', 'Навеска 3', 0), (4, 'Бренд', '', 1),
    (4, 'Длина выкладки', '', 0), (4, 'Кол-во товаров', '', 0);
    -- 1.1-3 - ложь, 2.2-4 - ложь, 3.2-4 - ложь, 4.2-4 - ложь; = 12 записей (результат)
    -- 1.4 - истина, 2.1 - истина, 3.1 - истина, 4.1 - истина = 4 записи

-- delete from mysql.Group_;
-- delete from mysql.gr_item1;
-- delete from mysql.gr_item2;

SELECT * FROM mysql.gr_item1; 
SELECT * FROM mysql.gr_item2;

-- Структура: Group_(ID, ByGroup), gr_item1(ID_Group, Code, Value_, IsPrimary), gr_item2(ID_Group, Code, Value_, IsPrimary)

-- Глоссарий:
    -- Группа элементов - Набор записей из таблиц ITEMx с одинаковым значением ID_Group (т.е. записи относящиеся к одной группе)
    -- Элемент - запись в таблицах ITEMx, которая идентифицируется полем Code. Одни и те же элементы могут присутствовать в разных группах
    -- Главный элемент - элемент группы, у которого IsPrimary = 1. Такой элемент в группе может быть только один

/*
Вывести: Code, ITEM1.ID_Group, ITEM1.Value и ITEM2.ID_Group, ITEM2.Value, сопоставленные по группам по следующим правилам:
1) элементы между группами сопоставляются по полю Code (т.е. всегда ITEM1.Code = ITEM2.Code)
2) группы элементов в ITEM1 сопоставляются с элементами группы в ITEM2 по следующему правилу:
  если в соответсвующей записи таблицы GROUP (связь с ITEMx по идентификатору ID_Group) флаг ByGroup = 1
    то: ITEM1 и ITEM2 сопоставляются по ID_Group, Code
    иначе: необходимо сопоставить группы и все их элементы из двух таблиц по значению Value_ в главном элементе
*/

WITH
-- таблица с уникальными значениями в поле Value_ для столбца ID_Group разных анкет
unique_val as 
	(SELECT it1.ID_Group as id1, it2.ID_Group as id2 
     FROM mysql.gr_item1 it1 JOIN mysql.gr_item2 it2 ON it1.Value_ = it2.Value_ 
    WHERE it1.IsPrimary = 1
    )
-- таблица 1   
SELECT it1.Code, it1.ID_Group, it1.Value_, it2.ID_Group, it2.Value_ -- те поля, которые хочет видеть заказчик
    FROM mysql.gr_item1 it1 JOIN mysql.gr_item2 it2 ON it1.ID_Group = it2.ID_Group AND it1.Code = it2.Code -- правило 1
    WHERE (SELECT ByGroup FROM mysql.Group_ WHERE ID = it1.ID_Group) = 1
UNION ALL 
-- таблица 2 
SELECT it1.Code, it1.ID_Group, it1.Value_, it2.ID_Group, it2.Value_ -- должны совпадать
    FROM mysql.gr_item1 it1 JOIN mysql.gr_item2 it2 ON it1.Code = it2.Code -- правило 1
    WHERE it1.ID_Group IN(SELECT id1 FROM unique_val) AND
        it2.ID_Group = (SELECT id2 FROM unique_val WHERE id1 = it1.ID_Group );

/*Cтруктура объектов, группы (ID) могут быть одинаковы (почему бы не использовать UNUION?), но информация может быть разной,
сравнила информацию в анкетах на достоверность по заданным правилам.

С помощью оператора UNION выполняю вертикальную склейку записей, причем gr_item1 соединяю с gr_item2 с заданными фильтрами для таблиц
(В gr_item1, для связи с gr_item2 используется jOIN).

Если в соответсвующей записи таблицы GROUP_  флаг ByGroup = 1, то есть поздапрос (SELECT ByGroup FROM mysql.Group_ WHERE ID = it1.ID_Group) вернул цифру 1, ТОГДА таблицу 1 сформировала с помощью таблиц-анкет по ID_Group, Code, ИНАЧЕ
сформировала записи для таблицы 2, в которой группы и все их элементы из таблиц-анкет по значению Value_ в главном элементе: в подзапросе unique_val (it1.Value_ = it2.Value_) сравниваю представленные значения в поле Value_ для разных анкет, также,
отбираю главные элементы групп, то есть у которого IsPrimary = 1 (единственный в группе).
*/
