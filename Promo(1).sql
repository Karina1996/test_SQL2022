
/*СТРУКТУРА ОБЪЕКТОВ ТИПА TABLE:
    Promo -> Акция (ID -> Код, Store -> Магазин, Product -> Товар, DateBegin -> Начало, DateEnd -> Окончание)
    ProductPrice -> Цена товара (Pricelist -> Прайс-лист , Product -> Товар, Price -> Цена)
(не увидела связи между таблицами)*/ 

-- Создание и добавление записей в таблицы
create table Promo (
	ID			int
	,Store		varchar(255)
	,Product	varchar(255)
	,DateBegin	date
	,DateEnd	date
	);

insert into Promo (ID, Store, Product, DateBegin, DateEnd)
    values
        (1,		'Tesco',	'Gum',			'2018-07-21',	'2018-07-29')
        ,(2,	'Tesco',	'Fish',			'2018-08-01',	'2018-08-17') -- дата Н и О пересекается с milk, sugar
        ,(3,	'Tesco',	'Juice',		'2018-06-06',	'2018-06-15')
        ,(6,	'Tesco',	'Shampoo',		'2018-06-28',	'2018-07-07')
        ,(7,	'Tesco',	'Coffee',		'2018-06-14',	'2018-06-30')
        ,(9,	'Tesco',	'Sugar',		'2018-07-05',	'2018-07-19')
        ,(10,	'Tesco',	'Tea',			'2018-06-01',	'2018-06-05')
        ,(11,	'Tesco',	'Milk',			'2018-08-03',	'2018-08-14')
        ,(12,	'Tesco',	'Wet Wipes',	'2018-08-20',	'2018-08-31')
        ,(13,	'Billa',	'Shampoo',		'2018-06-28',	'2018-07-07')
        ,(14,	'Billa',	'Coffee',		'2018-06-12',	'2018-06-27')
        ,(15,	'Billa',	'Sugar',		'2018-08-01',	'2018-08-12') 
        ,(16,	'Billa',	'Tea',			'2018-06-04',	'2018-06-18')
        ,(17,	'Billa',	'Milk',			'2018-07-07',	'2018-07-21')
        ,(18,	'Billa',	'Wet Wipes',	'2018-08-10',	'2018-08-25')
        ,(19,	'Auchan',	'Coffee',		'2018-06-05',	'2018-06-18')
        ,(20,	'Auchan',	'Fish',			'2018-07-22',	'2018-08-02')
        ,(21,	'Auchan',	'Sugar',		'2018-07-01',	'2018-07-31');
-- 21 запись

create table ProductPrice (
	Pricelist	varchar(255)
	,Product	varchar(255)
	,Price		decimal(18, 2)
	);

insert into ProductPrice (Pricelist, Product, Price)
    values
        ('Regular',		'T-shirt',		10)
        ,('Regular',	'Pants',		20)
        ,('Regular',	'Sweatshirt',	15)
        ,('Regular',	'Bike',			100)
        ,('Regular',	'Skate',		50)
        ,('Exclusive',	'T-shirt',		8)
        ,('Exclusive',	'Pants',		17)
        ,('Exclusive',	'Sweatshirt',	13)
        ,('Exclusive',	'Bike',			90)
        ,('Exclusive',	'Skate',		43)
        ,('Summer',		'T-shirt',		12)
        ,('Summer',		'Pants',		20)
        ,('Summer',		'Sweatshirt',	12)
        ,('Summer',		'Bike',			110)
        ,('Summer',		'Skate',		57)
-- 15 записей

/*
Для каждой таблицы нужно выполнить соответствующее задание
Код нужно писать сразу под заданием и комментировать после решения задачи
После выполнения всех задач, сохранить и прислать файл в формате *.sql или ссылку на страницу
*/

------------ 1. Таблица: dbo.Promo
-- Вывести номер акции, название магазина и название продукта, а также
-- номер акции и название продукта, где акция
-- пересекается по датам проведения с другими акциями для ДАННОГО магазина
-- * - желательно исключить повторяющуюся информацию о пересечениях

SELECT DISTINCT Pr1.ID, Pr1.Store, Pr1.Product, 
    Pr2.ID AS ID_1, Pr2.Product AS Product_1
FROM Promo Pr1 JOIN Promo Pr2 ON (Pr1.Store = Pr2.Store)
    AND (Pr1.DateBegin < Pr2.DateEnd)
    AND (Pr2.DateBegin < Pr1.DateEnd)

/*Выполняется самосоедение: столбцы таблицы сравниваются с теми же столбцами из той же таблицы 
(Store - для сравнения совпадающих магазинов , DateBegin, DateEnd - сравнение диапозона дат акций).
С помощью указанных псевдонимов (AS) можно ссылаться на имя одной и той же таблицы дважды.
Для объедения записей использую внутреннее соединение (INNER JOIN) при условии (ON), что Pr1.Store = Pr2.Store is True.
Оператор DISTINCT устраняет дубли (не увидела в запросе дублирующие записи).
Например, для магазина Tesco дата Н и О акции для продукта fish пересекается с продуктами milk, sugar.*/

------------- 2. Таблица: dbo.Promo
-- Вывести номер акции, название магазина и название продукта, а также
-- названия магазинов и название продуктов, где акция
-- пересекается по датам проведения с акциями в ДРУГИХ магазинах
-- * - желательно исключить повторяющуюся информацию о пересечениях

SELECT Pr1.ID, Pr1.Store, Pr1.Product,
    Pr2.Store AS Store_1,
    Pr2.Product AS Product_1
FROM Promo Pr1 JOIN Promo Pr2 ON (Pr1.Store != Pr2.Store)
    AND (Pr1.DateBegin < Pr2.DateEnd)
    AND (Pr2.DateBegin < Pr1.DateEnd)

/*Разница от предыдущего запроса в том, что сравниваются продукты разных магазинов
с помощью условия Pr1.Store != Pr2.Store*/

----------- 3. Таблица: dbo.ProductPrice
-- Написать запрос, который выводит цены
-- по каждому продукту (в строках) и прайс-листам (в столбцах)

SELECT Product, 
        sum(CASE WHEN Pricelist = 'Regular' THEN Price END) as Regular,
        sum(CASE WHEN Pricelist = 'Exclusive' THEN Price END) as Exclusive,
        sum(CASE WHEN Pricelist = 'Summer' THEN Price END) as Summer
    FROM ProductPrice
    GROUP BY Product
    ORDER BY Product DESC

/*Как известно, почти любую задачу можно решить несколькими способами,
мне привычнее использовать оператор CASE. Разворот (PIVOT) таблицы, доступен в СУБД SQL Server и Oracle..
CASE в зависимости от указанных условий возвращает одно из множества возможных значений. 
Если Pricelist = 'Regular' выполняется, то возвращается цена продукта для данного прайса, аналогично для других условий.
Чтобы получить цены для каждого продукта достаточно добавить группировку по полю Product.
Оператором ORDER BY отсортировала наименования продуктов по убыванию в алфавитном порядке (ASC действует по умолчанию).
Для корректного выполнения запроса нужна агрегирующая функция, в нашем случае - SUM.
*/

-- отбор данных вручную:
--              Regular   Exclusive   Summer 
-- T-shirt      10          8          12
-- Sweatshirt   15          13         12
-- Skate        50          43         47
-- Pants        20          17         20
-- Bike         100         90         110
