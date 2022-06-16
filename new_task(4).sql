/* 

ЗАДАЧА:

В магазине на разных стеллажах (местах продаж) выложены товары. 

Информация об этом поступает в виде анкет (вопрос-ответ) из двух источников:

1. Анкета торгового агента

2. Анкета аудитора



Необходимо выполнить сравнение анкет торгового агента с анкетами аудитора, 

чтобы понять, насколько достоверно торговый агент предоставил данные.



ДАНО:

Три таблицы:

--------------------------------------------------------------------------

| GROUP       | ITEM1                       | ITEM2                      |

--------------------------------------------------------------------------

|(PK) ID      |(PK) ID_Group (fk GROUP.ID)  |(PK) ID_Group (fk GROUP.ID) |

|     ByGroup |(PK) Code                    |(PK) Code                   |

|             |     Value                   |     Value                  |

|             |     IsPrimary               |     IsPrimary              |

--------------------------------------------------------------------------



ГЛОССАРИЙ:

* Группа элементов - Набор записей из таблиц ITEMx с одинаковым значением ID_Group (т.е. записи относящиеся к одной группе)

* Элемент - запись в таблицах ITEMx, которая идентифицируется полем Code. Одни и те же элементы могут присутствовать в разных группах

* Главный элемент - элемент группы, у которого IsPrimary = 1. Такой элемент в группе может быть только один



ЗАДАЧА:

Вывести: Code, ITEM1.ID_Group, ITEM1.Value и ITEM2.ID_Group, ITEM2.Value, сопоставленные по группам по следующим правилам:

1) элементы между группами сопоставляются по полю Code (т.е. всегда ITEM1.Code = ITEM2.Code)

2) группы элементов в ITEM1 сопоставляются с элементами группы в ITEM2 по следующему правилу:

	если в соответсвующей записи таблицы GROUP (связь с ITEMx по идентификатору ID_Group) флаг ByGroup = 1

		то: ITEM1 и ITEM2 сопоставляются по ID_Group, Code

		иначе: необходимо сопоставить группы и все их элементы из двух таблиц по значению Value в главном элементе

*/



create table [Group]

(

    ID int primary key,

    ByGroup bit

)



create table ITEM1 (

    ID_Group int foreign key references [Group](ID),

    Code varchar(100),

    Value varchar(100),

    IsPrimary bit,

    primary key (ID_Group, Code)

)



create table ITEM2 (

    ID_Group int foreign key references [Group](ID),

    Code varchar(100),

    Value varchar(100),

    IsPrimary bit,

    primary key (ID_Group, Code)

)

------

delete from [Item1]

delete from [Item2]

delete from [Group]



insert into [Group] values (1, 1)

insert into [Group] values (2, 0)

insert into [Group] values (3, 0)

insert into [Group] values (4, 0)



-- Item1

insert into [Item1] values (1, 'Место продаж', 'Основная полка', 0)

insert into [Item1] values (1, 'Длина полки', '3', 0)

insert into [Item1] values (1, 'Высота выкладки', '120', 0)

insert into [Item1] values (1, 'Кол-во товаров', '42', 0)



insert into [Item1] values (2, 'Место продаж', 'Навеска 1', 0)

insert into [Item1] values (2, 'Бренд', 'Greenland', 1)

insert into [Item1] values (2, 'Длина выкладки', '20', 0)

insert into [Item1] values (2, 'Кол-во товаров', '10', 0)



insert into [Item1] values (3, 'Место продаж', 'Навеска 2', 0)

insert into [Item1] values (3, 'Бренд', 'Freefly', 1)

insert into [Item1] values (3, 'Длина выкладки', '60', 0)

insert into [Item1] values (3, 'Кол-во товаров', '40', 0)



insert into [Item1] values (4, 'Место продаж', 'Навеска 3', 0)

insert into [Item1] values (4, 'Бренд', 'Coco', 1)

insert into [Item1] values (4, 'Длина выкладки', '50', 0)

insert into [Item1] values (4, 'Кол-во товаров', '30', 0)



-- Item2

insert into [Item2] values (1, 'Место продаж', 'Основная полка', 1)

insert into [Item2] values (1, 'Длина полки', '4', 0)

insert into [Item2] values (1, 'Высота выкладки', '125', 0)

insert into [Item2] values (1, 'Кол-во товаров', '42', 0)



insert into [Item2] values (2, 'Место продаж', 'Навеска 1', 0)

insert into [Item2] values (2, 'Бренд', 'Coco', 1)

insert into [Item2] values (2, 'Длина выкладки', '60', 0)

insert into [Item2] values (2, 'Кол-во товаров', '', 0)



insert into [Item2] values (3, 'Место продаж', 'Навеска 2', 0)

insert into [Item2] values (3, 'Бренд', 'Greenland', 1)

insert into [Item2] values (3, 'Длина выкладки', '30', 0)

insert into [Item2] values (3, 'Кол-во товаров', '5', 0)



insert into [Item2] values (4, 'Место продаж', 'Навеска 3', 0)

insert into [Item2] values (4, 'Бренд', '', 1)

insert into [Item2] values (4, 'Длина выкладки', '', 0)

insert into [Item2] values (4, 'Кол-во товаров', '', 0)

