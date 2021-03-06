
///////////////////////////////////////////////////
//Служебные функции и процедуры
///////////////////////////////////////////////////

&НаКлиенте
// контекст фреймворка Vanessa-Behavior
Перем Ванесса;
 
&НаКлиенте
// Структура, в которой хранится состояние сценария между выполнением шагов. Очищается перед выполнением каждого сценария.
Перем Контекст Экспорт;
 
&НаКлиенте
// Структура, в которой можно хранить служебные данные между запусками сценариев. Существует, пока открыта форма Vanessa-Behavior.
Перем КонтекстСохраняемый Экспорт;

// Делает отключение модуля
&НаКлиенте
Функция ОтключениеМодуля() Экспорт

	Ванесса = Неопределено;
	Контекст = Неопределено;
	КонтекстСохраняемый = Неопределено;

КонецФункции

&НаКлиенте
// Функция экспортирует список шагов, которые реализованы в данной внешней обработке.
Функция ПолучитьСписокТестов(КонтекстФреймворкаBDD) Экспорт
	Ванесса = КонтекстФреймворкаBDD;
	
	ВсеТесты = Новый Массив;

	//описание параметров
	//Ванесса.ДобавитьШагВМассивТестов(ВсеТесты,Снипет,ИмяПроцедуры,ПредставлениеТеста,ОписаниеШага,ТипШага,Транзакция,Параметр);

	Ванесса.ДобавитьШагВМассивТестов(ВсеТесты,"ОжидаюВходящийДокументПоПрофилю(Парам01, Парам02)","ОжидаюВходящийДокументПоПрофилю","И ожидаю входящий документ ""ТипДокумента"" по профилю ""Имя профиля""","Ожидает поступление входящих сообщений на FTP.","Прочее.ОбменEDI");
	Ванесса.ДобавитьШагВМассивТестов(ВсеТесты,"СоздаюДокументовОбработкойПоПодобиюДокументаНомер(Парам01,Парам02,Парам03)","СоздаюДокументовОбработкойПоПодобиюДокументаНомер","И создаю 10 документов ""ЗаказКлиента"" обработкой по подобию документа номер ""ТД00-000001""","Создает документы в базе менеджере тестирования на основании указанного в качестве примера источника.","Прочее.ОбменEDI");
	
	Возврат ВсеТесты;
КонецФункции
	
&НаСервере
// Служебная функция.
Функция ПолучитьМакетСервер(ИмяМакета)
	ОбъектСервер = РеквизитФормыВЗначение("Объект");
	Возврат ОбъектСервер.ПолучитьМакет(ИмяМакета);
КонецФункции
	
&НаКлиенте
// Служебная функция для подключения библиотеки создания fixtures.
Функция ПолучитьМакетОбработки(ИмяМакета) Экспорт
	Возврат ПолучитьМакетСервер(ИмяМакета);
КонецФункции


///////////////////////////////////////////////////
//Работа со сценариями
///////////////////////////////////////////////////

&НаКлиенте
// Процедура выполняется перед началом каждого сценария
Процедура ПередНачаломСценария() Экспорт
	
КонецПроцедуры

&НаКлиенте
// Процедура выполняется перед окончанием каждого сценария
Процедура ПередОкончаниемСценария() Экспорт
	
КонецПроцедуры



///////////////////////////////////////////////////
//Реализация шагов
///////////////////////////////////////////////////         

&НаКлиенте
//И ожидаю входящий документ "ТипДокумента" по профилю "Имя профиля"
//@ОжидаюВходящийДокументПоПрофилю(Парам01, Парам02)
Процедура ОжидаюВходящийДокументПоПрофилю(ТипДокумента, ИмяПрофиляОбмена) Экспорт
	ОжидаюВходящийДокументНаСервере(ТипДокумента, ИмяПрофиляОбмена);
КонецПроцедуры

&НаСервереБезКонтекста
Процедура ОжидаюВходящийДокументНаСервере(ТипДокумента, ИмяПрофиляОбмена) Экспорт
	ПрофильОбмена = Справочники.ЭКОМ_ПрофилиОбмена.НайтиПоНаименованию(ИмяПрофиляОбмена);
	СерверFTP = ПолучитьFTPСоединениеВОбработке(ПрофильОбмена);
	
	ФайлНайден = Ложь;
	Пока Не ФайлНайден Цикл
		МассивФайловCFTP = СерверFTP.НайтиФайлы(ПрофильОбмена.ВходящийПутьFTP, ТипДокумента + "*.xml");
		Если МассивФайловCFTP.Количество() > 0 Тогда
			ФайлНайден = Истина;
		КонецЕсли;
	КонецЦикла;	
КонецПроцедуры

&НаСервереБезКонтекста
Функция ПолучитьFTPСоединениеВОбработке(ПараметрыОбъекта) Экспорт
	
	знИспользуетсяПрокси       = Вычислить("ЭКОМ_ОбщегоНазначения.НастройкиПрочитатьНаСервере(""ЭКОМ_ИспользуетсяПрокси"", Ложь)");
	знИмяПользователяПрокси    = Вычислить("ЭКОМ_ОбщегоНазначения.НастройкиПрочитатьНаСервере(""ЭКОМ_ИмяПользователяПрокси"")");
	знПарольПользователяПрокси = Вычислить("ЭКОМ_ОбщегоНазначения.НастройкиПрочитатьНаСервере(""ЭКОМ_ПарольПользователяПрокси"")");
	знПорт                     = ПараметрыОбъекта.Порт;
	
	знИмяПользователяFTP       = ПараметрыОбъекта.ИмяПользователяFTP;
	знПарольПользователяFTP    = ПараметрыОбъекта.ПарольПользователяFTP;
	знСерверОбмена             = ПараметрыОбъекта.СерверFTP;
	
	
	ПараметрыFTP = Новый Структура;
	ПараметрыFTP.Вставить("Сервер"                       , знСерверОбмена);
	ПараметрыFTP.Вставить("Порт"                         , знПорт);
	ПараметрыFTP.Вставить("ИмяПользователя"              , знИмяПользователяFTP);
	ПараметрыFTP.Вставить("ПарольПользователя"           , знПарольПользователяFTP);
	ПараметрыFTP.Вставить("ПассивноеСоединение"          , Истина);
	ПараметрыFTP.Вставить("Таймаут"                      , 0);
	ПараметрыFTP.Вставить("ЗащищенноеСоединение"         , Неопределено);
	ПараметрыFTP.Вставить("УровеньИспользованияЗащитыFTP", УровеньИспользованияЗащищенногоСоединенияFTP.Авто);
	ПараметрыFTP.Вставить("ИспользуетсяПрокси"           , знИспользуетсяПрокси);
	ПараметрыFTP.Вставить("ИмяПользователяПрокси"        , знИмяПользователяПрокси);
	ПараметрыFTP.Вставить("ПарольПользователяПрокси"     , знПарольПользователяПрокси);
	
	СерверFTP = ПолучитьСерверFTPОбщийМодульВОбработке(ПараметрыFTP);
	
	Возврат СерверFTP;
	
КонецФункции

&НаСервереБезКонтекста
Функция ПолучитьСерверFTPОбщийМодульВОбработке(ПараметрыFTP) Экспорт
	
	ИмяСобытия = "Получение сервера FTP, модуль обработки";
	СерверFTP    = Неопределено;
	ПроксиСервер = Новый ИнтернетПрокси();	     			
	Если ПараметрыFTP.ИспользуетсяПрокси = Истина Тогда	
		ПроксиСервер.Пользователь = СокрЛП(ПараметрыFTP.ИмяПользователяПрокси);
		ПроксиСервер.Пароль       = СокрЛП(ПараметрыFTP.ПарольПользователяПрокси);
		ПараметрыFTP.Вставить("Прокси", ПроксиСервер);
	КонецЕсли;
	
	знПорт = ?(ТипЗнч(ПараметрыFTP.Порт) = Тип("Число"), ПараметрыFTP.Порт, Вычислить("ЭКОМ_ОбщегоНазначения.ЭКОМ_ПреобразоватьВЧислоОбщегоНазначения(ПараметрыFTP.Порт)"));
	ПараметрыFTP.Вставить("Порт"  , знПорт);
	ПараметрыFTP.Вставить("Прокси", ПроксиСервер);
	
	Если Вычислить("ЭКОМ_ОбщегоНазначения.ВерсияПлатформыНаСервере()") >= 8309 Тогда
		Попытка
			Выполнить("СерверFTP = Новый FTPСоединение(
			|ПараметрыFTP.Сервер, 
			|ПараметрыFTP.Порт, 
			|ПараметрыFTP.ИмяПользователя, 
			|ПараметрыFTP.ПарольПользователя,
			|ПараметрыFTP.Прокси,
			|ПараметрыFTP.ПассивноеСоединение,
			|ПараметрыFTP.Таймаут,
			|ПараметрыFTP.ЗащищенноеСоединение,
			|ПараметрыFTP.УровеньИспользованияЗащитыFTP);");					
		Исключение
			
		КонецПопытки;	
	Иначе
		Попытка
			СерверFTP = Новый FTPСоединение(
			ПараметрыFTP.Сервер, 
			ПараметрыFTP.Порт, 
			ПараметрыFTP.ИмяПользователя, 
			ПараметрыFTP.ПарольПользователя,
			ПараметрыFTP.Прокси,
			ПараметрыFTP.ПассивноеСоединение,
			ПараметрыFTP.Таймаут);			
		Исключение
			
		КонецПопытки;
	КонецЕсли;
	
	Если СерверFTP = Неопределено Тогда
		
	КонецЕсли;
	
	Возврат СерверFTP;
	
КонецФункции

&НаКлиенте
//И создаю 10 документов "ЗаказКлиента" обработкой по подобию документа номер "ТД00-000001"
//@СоздаюДокументовОбработкойПоПодобиюДокументаНомер(Парам01,Парам02,Парам03)
Процедура СоздаюДокументовОбработкойПоПодобиюДокументаНомер(КоличествоОбъектов, ТипДокумента, НомерДокументаИсточника) Экспорт
	Если КоличествоОбъектов < 1 Тогда
		Возврат;
	КонецЕсли;
	
	СозданиеДокументовНаСервере(КоличествоОбъектов, ТипДокумента, НомерДокументаИсточника);	
КонецПроцедуры


&НаСервереБезКонтекста
Процедура СозданиеДокументовНаСервере(КоличествоОбъектов, ТипДокумента, НомерДокументаИсточника)
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	ТипДокумента.Ссылка КАК Ссылка
	|ИЗ
	|	&ТипДокумента КАК ТипДокумента
	|ГДЕ
	|	ТипДокумента.Номер = &НомерДокументаИсточника";
	Запрос.Текст = СтрЗаменить(Запрос.Текст, "&ТипДокумента", "Документ." + ТипДокумента);
	Запрос.УстановитьПараметр("НомерДокументаИсточника", НомерДокументаИсточника);
	Источник = Неопределено;
	Попытка
		Выборка = Запрос.Выполнить().Выбрать();
		Если Выборка.Следующий() Тогда
			Источник = Выборка.Ссылка;
		Иначе
			ЭКОМ_ОбщегоНазначения.СообщитьПользователю("Не удалось найти источник по указанному номеру");
			Возврат;
		КонецЕсли;
	Исключение
		ЭКОМ_ОбщегоНазначения.СообщитьПользователю("Не удалось создать документы с указанным типом");
		Возврат;
	КонецПопытки;

	// Поиск реквизитов с типом Дата.
	РучноеЗаполнение 	= Новый Массив;
	ИсточникМетаданные 	= Источник.Метаданные();
	Для Каждого Реквизит Из ИсточникМетаданные.СтандартныеРеквизиты Цикл
		Если Строка(Реквизит.Тип) = "Дата" Тогда
			РучноеЗаполнение.Добавить(Реквизит.Имя);
		КонецЕсли;
	КонецЦикла;
	Для Каждого Реквизит Из ИсточникМетаданные.Реквизиты Цикл
		Если Строка(Реквизит.Тип) = "Дата" Тогда
			РучноеЗаполнение.Добавить(Реквизит.Имя);
		КонецЕсли;
	КонецЦикла;
	
	ДокументОбъект = Источник.ПолучитьОбъект();
	Для Счетчик = 1 По КоличествоОбъектов Цикл
		НовыйДокумент = ДокументОбъект.Скопировать();
		Для Каждого РеквзитИмя Из РучноеЗаполнение Цикл
			НовыйДокумент[РеквзитИмя] = ?(РеквзитИмя = "Дата", ТекущаяДатаСеанса(), ДокументОбъект[РеквзитИмя]);
		КонецЦикла;
		Попытка
			НовыйДокумент.Записать(?(ДокументОбъект.Проведен, РежимЗаписиДокумента.Проведение, РежимЗаписиДокумента.Запись));
		Исключение
			Сообщить(ОписаниеОшибки());
			Возврат;
		КонецПопытки;
	КонецЦикла;
	
КонецПроцедуры

