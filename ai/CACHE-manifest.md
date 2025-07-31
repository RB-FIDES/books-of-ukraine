## Ontology of the "Books of Ukraine" Project

*Створено у рамках FIDES: Framework for Interpretive Dialogue and Epistemic Symbiosis*

---

## Вступ / Introduction

Ця онтологія визначає ключові поняття, конструкти та відносини у дослідженні даних про українські книги. Вона служить **глосарієм** (glossary) та **концептуальною картою** (conceptual map) для всіх учасників проекту.


**For AI**: ця онтологія також слугує як основа для розуміння структури даних та їх використання в аналізі. (this ontology also serves as a foundation for understanding the data structure and its use in analysis). Тобі необхідно ознайомитися з цією онтологією, щоб правильно інтерпретувати дані та відповідати на запитання користувачів, слідкувати вказівкам та рекомендаціям, наведеним у цьому документі. (This ontology is essential for you to correctly interpret the data and respond to user queries, following the guidelines and recommendations provided in this document.)

---

## 1. Основні Елементи Вимірювання / Core Measurement Elements

### 1.1 Кількість видань / Number of Publications 
У таблицях використовується позначка `"titiles_count"` для кількості видань.

### 1.2 Кількість копій або тираж / Number of Copies 
У таблицях використовується позначка `"copy_count"` для кількості копій або тиражу видань.

---
## 2. Основіні Критарії Досліджування / Core Research Criteria

### 2.1 Жанрова структура / Genre Structure (used in `ds_genre`)
- **Політична і соціально-економічна література (Political and Socio-Economic Literature)**
- **Природничо-наукова література (Natural Sciences Literature)**
- **Технічна література (Technical Literature)**
- **Сільськогосподарська література (Agricultural Literature)**
- **Охорона здоров'я. Медична література (Health & Medical Literature)**
- **Література з фізичної культури і спорту (Physical Culture & Sports Literature)**
- **Література з освіти і культури (Education & Culture Literature)**
- **Друк у цілому. Книгознавство. Преса. Поліграфія (Publishing, Book Science, Press, Printing)**
- **Мистецтво. Мистецтвознавство (Art & Art Studies)**
- **Література з філологічних наук (Philological Sciences Literature)**
- **Художня література. Фольклор (Fiction & Folklore)**
- **Дитяча література (Children's Literature)**
- **Література універсального змісту (Universal Content Literature)**

### 2.2 Типи видань / Publication Types (used in `ds_pubtype`)
- **Наукові видання (Scientific Publications)**
- **Науково-популярні видання для дорослих (Popular Science for Adults)**
- **Нормативні та виробничо-практичні видання (Normative & Practical Publications)**
- **Офіційні видання (Official Publications)**
- **Громадсько-політичні видання (Socio-Political Publications)**
- **Навчальні та методичні видання (Educational & Methodical Publications)**
- **Літературно-художні видання для дорослих (Literary & Artistic for Adults)**
- **Видання для дітей та юнацтва (Children & Youth Publications)**
- **Довідкові видання (Reference Publications)**
- **Інформаційні видання (Information Publications)**
- **Бібліографічні видання (Bibliographic Publications)**
- **Видання для організації дозвілля (Leisure Publications)**
- **Рекламні видання (Advertising Publications)**
- **Література релігійного змісту (Religious Literature)**

### 2.3 Мовна структура / Language Structure (used in `ds_language`)
- **Українська (Ukrainian)**
- **Російська (Russian)**
- **Англійська (English)**
- **Польська (Polish)**
- **Німецька (German)**
- **Французька (French)**
- **Інші мови (Other languages)**
- **Кількома мовами (Multilingual)**

**P.s**: у списку вказані тільки найпопулярніші мови, які відповідають таким критеріям (дані містять мови, які не відповідають цим критеріям): 
- **Кількість різних публікацій** (`titles_count`) > 10  
 - **Кількість копій** (`copy_count`) > 10 000

### 2.4 Географічна структура / Geographic Structure (used in `ds_geography`)

- **Автономна Республіка Крим (Autonomous Republic of Crimea)**
- **Вінницька область (Vinnytsia Oblast)**
- **Волинська область (Volyn Oblast)**
- **Дніпропетровська область (Dnipropetrovsk Oblast)**
- **Донецька область (Donetsk Oblast)**
- **Житомирська область (Zhytomyr Oblast)**
- **Закарпатська область (Zakarpattia Oblast)**
- **Запорізька область (Zaporizhzhia Oblast)**
- **Івано-Франківська область (Ivano-Frankivsk Oblast)**
- **Київська область (Kyiv Oblast)**
- **Кіровоградська область (Kirovohrad Oblast)**
- **Луганська область (Luhansk Oblast)**
- **Львівська область (Lviv Oblast)**
- **Миколаївська область (Mykolaiv Oblast)**
- **Одеська область (Odesa Oblast)**
- **Полтавська область (Poltava Oblast)**
- **Рівненська область (Rivne Oblast)**
- **Сумська область (Sumy Oblast)**
- **Тернопільська область (Ternopil Oblast)**
- **Харківська область (Kharkiv Oblast)**
- **Херсонська область (Kherson Oblast)**
- **Хмельницька область (Khmelnytskyi Oblast)**
- **Черкаська область (Cherkasy Oblast)**
- **Чернівецька область (Chernivtsi Oblast)**
- **Чернігівська область (Chernihiv Oblast)**
- **м. Київ (Kyiv City)** (столиця України)
- **м. Севастополь (Sevastopol City)** (місто з особливим статусом)


**P.s**: для аналізу у файлі `Data-visualization.qmd` використовується групування областей України відповідно до класифікації `ds_geography` (географічна група / geographic group):

- **Північ (North)**: Київська (Kyiv), Чернігівська (Chernihiv), Сумська (Sumy), Житомирська (Zhytomyr)
- **Південь (South)**: Одеська (Odesa), Миколаївська (Mykolaiv), Херсонська (Kherson), Запорізька (Zaporizhzhia), Автономна Республіка Крим (Autonomous Republic of Crimea), м. Севастополь (Sevastopol City)
- **Схід (East)**: Харківська (Kharkiv), Донецька (Donetsk), Луганська (Luhansk), Дніпропетровська (Dnipropetrovsk)
- **Захід (West)**: Львівська (Lviv), Івано-Франківська (Ivano-Frankivsk), Тернопільська (Ternopil), Закарпатська (Zakarpattia), Волинська (Volyn), Рівненська (Rivne), Хмельницька (Khmelnytskyi), Чернівецька (Chernivtsi)
- **Центр (Center)**: Вінницька (Vinnytsia), Полтавська (Poltava), Кіровоградська (Kirovohrad), Черкаська (Cherkasy), м. Київ (Kyiv City)

*Ці групи використовуються для макрорегіонального аналізу (macroregional analysis) та відповідають структурі даних у `ds_geography`.*


---

## 3. Структура Даних / Data Structure

Усі дані організовано у вигляді **таблиці (table)**, де **кожен рядок (row)** відповідає **одному року (one year)** спостереження. Це означає, що для кожної комбінації критеріїв (наприклад, жанр, тип видання, мова, регіон) фіксується окремий запис за кожен календарний рік.

Кожен рік має відповідні значення для обох мір вимірювання: для кількості видань (`titles_count`) та кількості копій (`copy_count`). 

---

## 4.  Розподіл Даних  у таблиці / Data Table Adaptation

Всі таблиці мають таку класифікацію:

 - `ds` - аббревіатура для "data structure" (структура даних) або "data set" (набір даних)
 - `_name` - назва таблиці, що вказує на її зміст

### 4.1 `ds_language`

Таблиця містить інформацію про кількість видань та копій різними мовами (languages).  
**Рядок (Row):** кожен рядок — це окремий рік спостереження для певного типу виміру (`titles_count` або `copy_count`).  
**Стовпці (Columns):**
- **#1** — `yr` — рік спостереження (year)
- **#2** — `measure` — тип виміру (`titles_count` або `copy_count`)
- **#3–#N** — назва мови (language name), для якої ведеться підрахунок

---

### 4.2 `ds_genre`

Таблиця відображає розподіл видань за жанрами (genres).  
**Рядок (Row):** рік спостереження для певного жанру та типу виміру.  
**Стовпці (Columns):**
- **#1** — `yr` — рік спостереження (year)
- **#2** — `measure` — тип виміру (`titles_count` або `copy_count`)
- **#3–#N** — назва жанру (genre name)

---

### 4.3 `ds_geography`

Таблиця містить дані про кількість видань та копій у різних регіонах (regions) України. (та Київ і Севастополь)  
**Рядок (Row):** рік спостереження для кожного регіону та типу виміру.  
**Стовпці (Columns):**
- **#1** — `yr` — рік спостереження (year)
- **#2** — `measure` — тип виміру (`titles_count` або `copy_count`)
- **#3–#N** — назва регіону (region name)

---

### 4.4 `ds_pubtype`

Таблиця відображає розподіл видань за типами (publication types).  
**Рядок (Row):** рік спостереження для кожного типу видання та типу виміру.  
**Стовпці (Columns):**
- **#1** — `yr` — рік спостереження (year)
- **#2** — `measure` — тип виміру ( `titles_count` або `copy_count`)
- **#3–#N** — назва типу видання (publication type name)

---

### 4.5 `ds_year`

Таблиця містить загальні підсумкові дані за кожен рік (annual summary data).  
**Рядок (Row):** кожен рядок — це окремий рік спостереження для певного типу виміру.  
**Стовпці (Columns):**
- **#1** — `yr` — рік спостереження (year)
- **#2** — `measure` — тип виміру (`titles_count` або `copy_count`)
- **#3** — `value` — загальна кількість видань або копій за рік (total number of publications or copies per year)

---

### 4.6 `ds_ukr_rus`

Таблиця відображає співвідношення між українськомовними та російськомовними виданнями (Ukrainian vs Russian language publications).  
**Рядок (Row):** кожен рядок — це окремий рік спостереження для певного типу виміру.  
**Стовпці (Columns):**
- **#1** — `yr` — рік спостереження (year)
- **#2** — `measure` — тип виміру (`titles_count` або `copy_count`)
- **#3** — `ukr` — кількість українськомовних видань/копій (number of Ukrainian-language publications/copies)
- **#4** — `rus` — кількість російськомовних видань/копій (number of Russian-language publications/copies)
- **#5** — `perc_ukr` — частка українських видань/копій серед загальної кількості (share of Ukraniane-language among total)
- **#6** — `perc_rus` — частка російських видань/копій серед загальної кількості (share of Russian-language among total)

---

## 5. Тип даних / Data Type

Всі наявні таблиці будуть доступні у форматах **CSV** (Comma-Separated Values), **RDS** (R Data Serialization) та будуть поміщені до **SQLite** бази даних для зручного доступу та аналізу.

Щоб отримати доступ до цих форматів даних, необхідно "запустити" код з файлу `/manipulation/0-ellis-sasha.R` та виконати його у RStudio. Після цього дані будуть доступні у директорії `data-private/derived/manipulation/`.

Також дані можна переглянути у форматі **QMD** (Quarto Markdown) у файлі `Data-visualization.qmd` або у форматі **HTML** у файлі [Data-visualization.html](https://raw.githack.com/RB-FIDES/books-of-ukraine/main/analysis/Data-visualization/Data-visual.html).

Крім того, дані знаходяться у **Google Spreadsheets** для зручності доступу та візуалізації. Ви можете знайти їх у [Data](https://docs.google.com/spreadsheets/d/1OOKeZnMFEAzHyr_M51zaOe76uv1yuqNmveHXSKpeqpo/edit?gid=2036395854#gid=2036395854).

**P.s**: знайти дані можна у `data-private/derived/manipulation/` 

---

## 6. Глосарій Термінів / Glossary of Terms

### Українською / In Ukrainian

- **Онтологія** — формалізований опис понять, відносин і структур у певній предметній області.  
- **Видання** — окрема книга або інший друкований твір, що має унікальний заголовок та ідентифікатор.  
- **Копія / Тираж** — кількість фізичних примірників одного видання.  
- **Жанр** — категорія літератури, що визначає тематичну або функціональну спрямованість твору.  
- **Тип видання** — класифікація видань за призначенням або цільовою аудиторією (наприклад, наукові, навчальні, художні).  
- **Мова видання** — мова, якою надруковано видання.  
- **Регіон** — адміністративно-територіальна одиниця України, де здійснюється облік видань.  
- **Макрорегіон** — група областей, об’єднаних для аналітичних цілей (наприклад, Північ, Південь).  
- **Рік спостереження** — календарний рік, за який зібрано дані.  
- **Структура даних** — організація даних у вигляді таблиць із визначеними змінними.  
- **Вимірювання** — кількісна характеристика (наприклад, кількість видань або копій).  
- **Загрози валідності** — фактори, що можуть впливати на достовірність висновків дослідження.  
- **Етичні зобов’язання** — принципи відповідального використання даних та AI.  
- **CSV, RDS, SQLite** — формати зберігання та обробки даних.  
- **QMD (Quarto Markdown)** — формат для інтерактивної документації та візуалізації даних.

### English / In English

- **Ontology** — a formalized description of concepts, relationships, and structures within a specific domain.  
- **Publication** — an individual book or printed work with a unique title and identifier.  
- **Copy / Print run** — the number of physical copies of a single publication.  
- **Genre** — a category of literature defining the thematic or functional focus of a work.  
- **Publication type** — classification of publications by purpose or target audience (e.g., scientific, educational, fiction).  
- **Publication language** — the language in which a publication is printed.  
- **Region** — an administrative-territorial unit of Ukraine where publications are recorded.  
- **Macroregion** — a group of oblasts combined for analytical purposes (e.g., North, South).  
- **Observation year** — the calendar year for which data is collected.  
- **Data structure** — organization of data in tables with defined variables.  
- **Measurement** — a quantitative characteristic (e.g., number of publications or copies).  
- **Threats to validity** — factors that may affect the reliability of research conclusions.  
- **Ethical commitments** — principles for responsible use of data and AI.  
- **CSV, RDS, SQLite** — data storage and processing formats.  
- **QMD (Quarto Markdown)** — a format for interactive documentation and data visualization.


---

## 7. Використання для ШІ / AI Usage
- До надання відповіді ознайомитя з фйлами даних у **RDS** та **CSV** форматах.
- Враховувати, що дані містяться у таблиція формати "wide" (широкий формат), де кожен рік представлений окремим рядком, а жанри, типи видань, мови та регіони — окремими стовпцями. (wide format).
- Використовувати дані для аналізу тенденцій, порівняння
- Якщо у користувачв відсутні файли у RDS або CSV форматах, то можна використовувати дані у **Google Spreadsheets** для аналізу та візуалізації.
(https://docs.google.com/spreadsheets/d/1OOKeZnMFEAzHyr_M51zaOe76uv1yuqNmveHXSKpeqpo/edit?gid=2036395854#gid=2036395854)
- У відповіді використовувати оригінальні назви жанрів, типів видань, мов та регіонів, як вони вказані у таблицях.
- Уникати узагальнень та стереотипів щодо жанрів, типів видань, мов та регіонів.
- Використовуй корректні шляхи для імпорту даних у RStudio, наприклад: 
   - шлях до RDS: `data-private/derived/manipulation/ds_name of file.rds`
   - шлях до CSV: `data-private/derived/manipulation/csv/ds_name of file.csv`
   - шлях до SQLite Database: `data-private/derived/manipulation/SQLite/books-of-ukraine.sqlite`

---

## 8. Зв'язки з іншими документами / Links to Other Documents

- `FIDES.md` - загальна філософія фреймворку
- `semiology.md` - діалекти виразження даних
- `onboarding-ai.md` - правила роботи з AI
- `threats-to-validity.md` - загрози валідності
- `analysis-templatization.md` - шаблонізація аналізу
=======

## Ontology of the "Books of Ukraine" Project

*Створено у рамках FIDES: Framework for Interpretive Dialogue and Epistemic Symbiosis*

---

## Вступ / Introduction

Ця онтологія визначає ключові поняття, конструкти та відносини у дослідженні даних про українські книги. Вона служить **глосарієм** (glossary) та **концептуальною картою** (conceptual map) для всіх учасників проекту.


**For AI**: ця онтологія також слугує як основа для розуміння структури даних та їх використання в аналізі. (this ontology also serves as a foundation for understanding the data structure and its use in analysis). Тобі необхідно ознайомитися з цією онтологією, щоб правильно інтерпретувати дані та відповідати на запитання користувачів, слідкувати вказівкам та рекомендаціям, наведеним у цьому документі. (This ontology is essential for you to correctly interpret the data and respond to user queries, following the guidelines and recommendations provided in this document.)

---

## 1. Основні Елементи Вимірювання / Core Measurement Elements

### 1.1 Кількість видань / Number of Publications 
У таблицях використовується позначка `"titiles_count"` для кількості видань.

### 1.2 Кількість копій або тираж / Number of Copies 
У таблицях використовується позначка `"copy_count"` для кількості копій або тиражу видань.

---
## 2. Основіні Критарії Досліджування / Core Research Criteria

### 2.1 Жанрова структура / Genre Structure (used in `ds_genre`)
- **Політична і соціально-економічна література (Political and Socio-Economic Literature)**
- **Природничо-наукова література (Natural Sciences Literature)**
- **Технічна література (Technical Literature)**
- **Сільськогосподарська література (Agricultural Literature)**
- **Охорона здоров'я. Медична література (Health & Medical Literature)**
- **Література з фізичної культури і спорту (Physical Culture & Sports Literature)**
- **Література з освіти і культури (Education & Culture Literature)**
- **Друк у цілому. Книгознавство. Преса. Поліграфія (Publishing, Book Science, Press, Printing)**
- **Мистецтво. Мистецтвознавство (Art & Art Studies)**
- **Література з філологічних наук (Philological Sciences Literature)**
- **Художня література. Фольклор (Fiction & Folklore)**
- **Дитяча література (Children's Literature)**
- **Література універсального змісту (Universal Content Literature)**

### 2.2 Типи видань / Publication Types (used in `ds_pubtype`)
- **Наукові видання (Scientific Publications)**
- **Науково-популярні видання для дорослих (Popular Science for Adults)**
- **Нормативні та виробничо-практичні видання (Normative & Practical Publications)**
- **Офіційні видання (Official Publications)**
- **Громадсько-політичні видання (Socio-Political Publications)**
- **Навчальні та методичні видання (Educational & Methodical Publications)**
- **Літературно-художні видання для дорослих (Literary & Artistic for Adults)**
- **Видання для дітей та юнацтва (Children & Youth Publications)**
- **Довідкові видання (Reference Publications)**
- **Інформаційні видання (Information Publications)**
- **Бібліографічні видання (Bibliographic Publications)**
- **Видання для організації дозвілля (Leisure Publications)**
- **Рекламні видання (Advertising Publications)**
- **Література релігійного змісту (Religious Literature)**

### 2.3 Мовна структура / Language Structure (used in `ds_language`)
- **Українська (Ukrainian)**
- **Російська (Russian)**
- **Англійська (English)**
- **Польська (Polish)**
- **Німецька (German)**
- **Французька (French)**
- **Інші мови (Other languages)**
- **Кількома мовами (Multilingual)**

**P.s**: у списку вказані тільки найпопулярніші мови, які відповідають таким критеріям (дані містять мови, які не відповідають цим критеріям): 
- **Кількість різних публікацій** (`titles_count`) > 10  
 - **Кількість копій** (`copy_count`) > 10 000

### 2.4 Географічна структура / Geographic Structure (used in `ds_geography`)

- **Автономна Республіка Крим (Autonomous Republic of Crimea)**
- **Вінницька область (Vinnytsia Oblast)**
- **Волинська область (Volyn Oblast)**
- **Дніпропетровська область (Dnipropetrovsk Oblast)**
- **Донецька область (Donetsk Oblast)**
- **Житомирська область (Zhytomyr Oblast)**
- **Закарпатська область (Zakarpattia Oblast)**
- **Запорізька область (Zaporizhzhia Oblast)**
- **Івано-Франківська область (Ivano-Frankivsk Oblast)**
- **Київська область (Kyiv Oblast)**
- **Кіровоградська область (Kirovohrad Oblast)**
- **Луганська область (Luhansk Oblast)**
- **Львівська область (Lviv Oblast)**
- **Миколаївська область (Mykolaiv Oblast)**
- **Одеська область (Odesa Oblast)**
- **Полтавська область (Poltava Oblast)**
- **Рівненська область (Rivne Oblast)**
- **Сумська область (Sumy Oblast)**
- **Тернопільська область (Ternopil Oblast)**
- **Харківська область (Kharkiv Oblast)**
- **Херсонська область (Kherson Oblast)**
- **Хмельницька область (Khmelnytskyi Oblast)**
- **Черкаська область (Cherkasy Oblast)**
- **Чернівецька область (Chernivtsi Oblast)**
- **Чернігівська область (Chernihiv Oblast)**
- **м. Київ (Kyiv City)** (столиця України)
- **м. Севастополь (Sevastopol City)** (місто з особливим статусом)


**P.s**: для аналізу у файлі `Data-visualization.qmd` використовується групування областей України відповідно до класифікації `ds_geography` (географічна група / geographic group):

- **Північ (North)**: Київська (Kyiv), Чернігівська (Chernihiv), Сумська (Sumy), Житомирська (Zhytomyr)
- **Південь (South)**: Одеська (Odesa), Миколаївська (Mykolaiv), Херсонська (Kherson), Запорізька (Zaporizhzhia), Автономна Республіка Крим (Autonomous Republic of Crimea), м. Севастополь (Sevastopol City)
- **Схід (East)**: Харківська (Kharkiv), Донецька (Donetsk), Луганська (Luhansk), Дніпропетровська (Dnipropetrovsk)
- **Захід (West)**: Львівська (Lviv), Івано-Франківська (Ivano-Frankivsk), Тернопільська (Ternopil), Закарпатська (Zakarpattia), Волинська (Volyn), Рівненська (Rivne), Хмельницька (Khmelnytskyi), Чернівецька (Chernivtsi)
- **Центр (Center)**: Вінницька (Vinnytsia), Полтавська (Poltava), Кіровоградська (Kirovohrad), Черкаська (Cherkasy), м. Київ (Kyiv City)

*Ці групи використовуються для макрорегіонального аналізу (macroregional analysis) та відповідають структурі даних у `ds_geography`.*


---

## 3. Структура Даних / Data Structure

Усі дані організовано у вигляді **таблиці (table)**, де **кожен рядок (row)** відповідає **одному року (one year)** спостереження. Це означає, що для кожної комбінації критеріїв (наприклад, жанр, тип видання, мова, регіон) фіксується окремий запис за кожен календарний рік.

Кожен рік має відповідні значення для обох мір вимірювання: для кількості видань (`titles_count`) та кількості копій (`copy_count`). 

---

## 4.  Розподіл Даних  у таблиці / Data Table Adaptation

Всі таблиці мають таку класифікацію:

 - `ds` - аббревіатура для "data structure" (структура даних) або "data set" (набір даних)
 - `_name` - назва таблиці, що вказує на її зміст

### 4.1 `ds_language`

Таблиця містить інформацію про кількість видань та копій різними мовами (languages).  
**Рядок (Row):** кожен рядок — це окремий рік спостереження для певного типу виміру (`titles_count` або `copy_count`).  
**Стовпці (Columns):**
- **#1** — `yr` — рік спостереження (year)
- **#2** — `measure` — тип виміру (`titles_count` або `copy_count`)
- **#3–#N** — назва мови (language name), для якої ведеться підрахунок

---

### 4.2 `ds_genre`

Таблиця відображає розподіл видань за жанрами (genres).  
**Рядок (Row):** рік спостереження для певного жанру та типу виміру.  
**Стовпці (Columns):**
- **#1** — `yr` — рік спостереження (year)
- **#2** — `measure` — тип виміру (`titles_count` або `copy_count`)
- **#3–#N** — назва жанру (genre name)

---

### 4.3 `ds_geography`

Таблиця містить дані про кількість видань та копій у різних регіонах (regions) України. (та Київ і Севастополь)  
**Рядок (Row):** рік спостереження для кожного регіону та типу виміру.  
**Стовпці (Columns):**
- **#1** — `yr` — рік спостереження (year)
- **#2** — `measure` — тип виміру (`titles_count` або `copy_count`)
- **#3–#N** — назва регіону (region name)

---

### 4.4 `ds_pubtype`

Таблиця відображає розподіл видань за типами (publication types).  
**Рядок (Row):** рік спостереження для кожного типу видання та типу виміру.  
**Стовпці (Columns):**
- **#1** — `yr` — рік спостереження (year)
- **#2** — `measure` — тип виміру ( `titles_count` або `copy_count`)
- **#3–#N** — назва типу видання (publication type name)

---

### 4.5 `ds_year`

Таблиця містить загальні підсумкові дані за кожен рік (annual summary data).  
**Рядок (Row):** кожен рядок — це окремий рік спостереження для певного типу виміру.  
**Стовпці (Columns):**
- **#1** — `yr` — рік спостереження (year)
- **#2** — `measure` — тип виміру (`titles_count` або `copy_count`)
- **#3** — `value` — загальна кількість видань або копій за рік (total number of publications or copies per year)

---

### 4.6 `ds_ukr_rus`

Таблиця відображає співвідношення між українськомовними та російськомовними виданнями (Ukrainian vs Russian language publications).  
**Рядок (Row):** кожен рядок — це окремий рік спостереження для певного типу виміру.  
**Стовпці (Columns):**
- **#1** — `yr` — рік спостереження (year)
- **#2** — `measure` — тип виміру (`titles_count` або `copy_count`)
- **#3** — `ukr` — кількість українськомовних видань/копій (number of Ukrainian-language publications/copies)
- **#4** — `rus` — кількість російськомовних видань/копій (number of Russian-language publications/copies)
- **#5** — `perc_ukr` — частка українських видань/копій серед загальної кількості (share of Ukraniane-language among total)
- **#6** — `perc_rus` — частка російських видань/копій серед загальної кількості (share of Russian-language among total)

---

## 5. Тип даних / Data Type

Всі наявні таблиці будуть доступні у форматах **CSV** (Comma-Separated Values), **RDS** (R Data Serialization) та будуть поміщені до **SQLite** бази даних для зручного доступу та аналізу.

Щоб отримати доступ до цих форматів даних, необхідно "запустити" код з файлу `/manipulation/0-ellis-sasha.R` та виконати його у RStudio. Після цього дані будуть доступні у директорії `data-private/derived/manipulation/`.

Також дані можна переглянути у форматі **QMD** (Quarto Markdown) у файлі `Data-visualization.qmd` або у форматі **HTML** у файлі [Data-visualization.html](https://raw.githack.com/RB-FIDES/books-of-ukraine/main/analysis/Data-visualization/Data-visual.html).

Крім того, дані знаходяться у **Google Spreadsheets** для зручності доступу та візуалізації. Ви можете знайти їх у [Data](https://docs.google.com/spreadsheets/d/1OOKeZnMFEAzHyr_M51zaOe76uv1yuqNmveHXSKpeqpo/edit?gid=2036395854#gid=2036395854).

**P.s**: знайти дані можна у `data-private/derived/manipulation/` 

---

## 6. Глосарій Термінів / Glossary of Terms

### Українською / In Ukrainian

- **Онтологія** — формалізований опис понять, відносин і структур у певній предметній області.  
- **Видання** — окрема книга або інший друкований твір, що має унікальний заголовок та ідентифікатор.  
- **Копія / Тираж** — кількість фізичних примірників одного видання.  
- **Жанр** — категорія літератури, що визначає тематичну або функціональну спрямованість твору.  
- **Тип видання** — класифікація видань за призначенням або цільовою аудиторією (наприклад, наукові, навчальні, художні).  
- **Мова видання** — мова, якою надруковано видання.  
- **Регіон** — адміністративно-територіальна одиниця України, де здійснюється облік видань.  
- **Макрорегіон** — група областей, об’єднаних для аналітичних цілей (наприклад, Північ, Південь).  
- **Рік спостереження** — календарний рік, за який зібрано дані.  
- **Структура даних** — організація даних у вигляді таблиць із визначеними змінними.  
- **Вимірювання** — кількісна характеристика (наприклад, кількість видань або копій).  
- **Загрози валідності** — фактори, що можуть впливати на достовірність висновків дослідження.  
- **Етичні зобов’язання** — принципи відповідального використання даних та AI.  
- **CSV, RDS, SQLite** — формати зберігання та обробки даних.  
- **QMD (Quarto Markdown)** — формат для інтерактивної документації та візуалізації даних.

### English / In English

- **Ontology** — a formalized description of concepts, relationships, and structures within a specific domain.  
- **Publication** — an individual book or printed work with a unique title and identifier.  
- **Copy / Print run** — the number of physical copies of a single publication.  
- **Genre** — a category of literature defining the thematic or functional focus of a work.  
- **Publication type** — classification of publications by purpose or target audience (e.g., scientific, educational, fiction).  
- **Publication language** — the language in which a publication is printed.  
- **Region** — an administrative-territorial unit of Ukraine where publications are recorded.  
- **Macroregion** — a group of oblasts combined for analytical purposes (e.g., North, South).  
- **Observation year** — the calendar year for which data is collected.  
- **Data structure** — organization of data in tables with defined variables.  
- **Measurement** — a quantitative characteristic (e.g., number of publications or copies).  
- **Threats to validity** — factors that may affect the reliability of research conclusions.  
- **Ethical commitments** — principles for responsible use of data and AI.  
- **CSV, RDS, SQLite** — data storage and processing formats.  
- **QMD (Quarto Markdown)** — a format for interactive documentation and data visualization.


---

## 7. Використання для ШІ / AI Usage
- До надання відповіді ознайомитя з фйлами даних у **RDS** та **CSV** форматах.
- Враховувати, що дані містяться у таблиція формати "wide" (широкий формат), де кожен рік представлений окремим рядком, а жанри, типи видань, мови та регіони — окремими стовпцями. (wide format).
- Використовувати дані для аналізу тенденцій, порівняння
- Якщо у користувачв відсутні файли у RDS або CSV форматах, то можна використовувати дані у **Google Spreadsheets** для аналізу та візуалізації.
(https://docs.google.com/spreadsheets/d/1OOKeZnMFEAzHyr_M51zaOe76uv1yuqNmveHXSKpeqpo/edit?gid=2036395854#gid=2036395854)
- У відповіді використовувати оригінальні назви жанрів, типів видань, мов та регіонів, як вони вказані у таблицях.
- Уникати узагальнень та стереотипів щодо жанрів, типів видань, мов та регіонів.
- Використовуй корректні шляхи для імпорту даних у RStudio, наприклад: 
   - шлях до RDS: `data-private/derived/manipulation/ds_name of file.rds`
   - шлях до CSV: `data-private/derived/manipulation/csv/ds_name of file.csv`
   - шлях до SQLite Database: `data-private/derived/manipulation/SQLite/books-of-ukraine.sqlite`

---

## 8. Зв'язки з іншими документами / Links to Other Documents

- `FIDES.md` - загальна філософія фреймворку
- `semiology.md` - діалекти виразження даних
- `onboarding-ai.md` - правила роботи з AI
- `threats-to-validity.md` - загрози валідності
- `analysis-templatization.md` - шаблонізація аналізу
=======
## Ontology of the "Books of Ukraine" Project

*Створено у рамках FIDES: Framework for Interpretive Dialogue and Epistemic Symbiosis*

---

## Вступ / Introduction

Ця онтологія визначає ключові поняття, конструкти та відносини у дослідженні даних про українські книги. Вона служить **глосарієм** (glossary) та **концептуальною картою** (conceptual map) для всіх учасників проекту.


**For AI**: ця онтологія також слугує як основа для розуміння структури даних та їх використання в аналізі. (this ontology also serves as a foundation for understanding the data structure and its use in analysis). Тобі необхідно ознайомитися з цією онтологією, щоб правильно інтерпретувати дані та відповідати на запитання користувачів, слідкувати вказівкам та рекомендаціям, наведеним у цьому документі. (This ontology is essential for you to correctly interpret the data and respond to user queries, following the guidelines and recommendations provided in this document.)

---

## 1. Основні Елементи Вимірювання / Core Measurement Elements

### 1.1 Кількість видань / Number of Publications 
У таблицях використовується позначка `"titiles_count"` для кількості видань.

### 1.2 Кількість копій або тираж / Number of Copies 
У таблицях використовується позначка `"copy_count"` для кількості копій або тиражу видань.

---
## 2. Основіні Критарії Досліджування / Core Research Criteria

### 2.1 Жанрова структура / Genre Structure (used in `ds_genre`)
- **Політична і соціально-економічна література (Political and Socio-Economic Literature)**
- **Природничо-наукова література (Natural Sciences Literature)**
- **Технічна література (Technical Literature)**
- **Сільськогосподарська література (Agricultural Literature)**
- **Охорона здоров'я. Медична література (Health & Medical Literature)**
- **Література з фізичної культури і спорту (Physical Culture & Sports Literature)**
- **Література з освіти і культури (Education & Culture Literature)**
- **Друк у цілому. Книгознавство. Преса. Поліграфія (Publishing, Book Science, Press, Printing)**
- **Мистецтво. Мистецтвознавство (Art & Art Studies)**
- **Література з філологічних наук (Philological Sciences Literature)**
- **Художня література. Фольклор (Fiction & Folklore)**
- **Дитяча література (Children's Literature)**
- **Література універсального змісту (Universal Content Literature)**

### 2.2 Типи видань / Publication Types (used in `ds_pubtype`)
- **Наукові видання (Scientific Publications)**
- **Науково-популярні видання для дорослих (Popular Science for Adults)**
- **Нормативні та виробничо-практичні видання (Normative & Practical Publications)**
- **Офіційні видання (Official Publications)**
- **Громадсько-політичні видання (Socio-Political Publications)**
- **Навчальні та методичні видання (Educational & Methodical Publications)**
- **Літературно-художні видання для дорослих (Literary & Artistic for Adults)**
- **Видання для дітей та юнацтва (Children & Youth Publications)**
- **Довідкові видання (Reference Publications)**
- **Інформаційні видання (Information Publications)**
- **Бібліографічні видання (Bibliographic Publications)**
- **Видання для організації дозвілля (Leisure Publications)**
- **Рекламні видання (Advertising Publications)**
- **Література релігійного змісту (Religious Literature)**

### 2.3 Мовна структура / Language Structure (used in `ds_language`)
- **Українська (Ukrainian)**
- **Російська (Russian)**
- **Англійська (English)**
- **Польська (Polish)**
- **Німецька (German)**
- **Французька (French)**
- **Інші мови (Other languages)**
- **Кількома мовами (Multilingual)**

**P.s**: у списку вказані тільки найпопулярніші мови, які відповідають таким критеріям (дані містять мови, які не відповідають цим критеріям): 
- **Кількість різних публікацій** (`titles_count`) > 10  
 - **Кількість копій** (`copy_count`) > 10 000

### 2.4 Географічна структура / Geographic Structure (used in `ds_geography`)

- **Автономна Республіка Крим (Autonomous Republic of Crimea)**
- **Вінницька область (Vinnytsia Oblast)**
- **Волинська область (Volyn Oblast)**
- **Дніпропетровська область (Dnipropetrovsk Oblast)**
- **Донецька область (Donetsk Oblast)**
- **Житомирська область (Zhytomyr Oblast)**
- **Закарпатська область (Zakarpattia Oblast)**
- **Запорізька область (Zaporizhzhia Oblast)**
- **Івано-Франківська область (Ivano-Frankivsk Oblast)**
- **Київська область (Kyiv Oblast)**
- **Кіровоградська область (Kirovohrad Oblast)**
- **Луганська область (Luhansk Oblast)**
- **Львівська область (Lviv Oblast)**
- **Миколаївська область (Mykolaiv Oblast)**
- **Одеська область (Odesa Oblast)**
- **Полтавська область (Poltava Oblast)**
- **Рівненська область (Rivne Oblast)**
- **Сумська область (Sumy Oblast)**
- **Тернопільська область (Ternopil Oblast)**
- **Харківська область (Kharkiv Oblast)**
- **Херсонська область (Kherson Oblast)**
- **Хмельницька область (Khmelnytskyi Oblast)**
- **Черкаська область (Cherkasy Oblast)**
- **Чернівецька область (Chernivtsi Oblast)**
- **Чернігівська область (Chernihiv Oblast)**
- **м. Київ (Kyiv City)** (столиця України)
- **м. Севастополь (Sevastopol City)** (місто з особливим статусом)


**P.s**: для аналізу у файлі `Data-visualization.qmd` використовується групування областей України відповідно до класифікації `ds_geography` (географічна група / geographic group):

- **Північ (North)**: Київська (Kyiv), Чернігівська (Chernihiv), Сумська (Sumy), Житомирська (Zhytomyr)
- **Південь (South)**: Одеська (Odesa), Миколаївська (Mykolaiv), Херсонська (Kherson), Запорізька (Zaporizhzhia), Автономна Республіка Крим (Autonomous Republic of Crimea), м. Севастополь (Sevastopol City)
- **Схід (East)**: Харківська (Kharkiv), Донецька (Donetsk), Луганська (Luhansk), Дніпропетровська (Dnipropetrovsk)
- **Захід (West)**: Львівська (Lviv), Івано-Франківська (Ivano-Frankivsk), Тернопільська (Ternopil), Закарпатська (Zakarpattia), Волинська (Volyn), Рівненська (Rivne), Хмельницька (Khmelnytskyi), Чернівецька (Chernivtsi)
- **Центр (Center)**: Вінницька (Vinnytsia), Полтавська (Poltava), Кіровоградська (Kirovohrad), Черкаська (Cherkasy), м. Київ (Kyiv City)

*Ці групи використовуються для макрорегіонального аналізу (macroregional analysis) та відповідають структурі даних у `ds_geography`.*


---

## 3. Структура Даних / Data Structure

Усі дані організовано у вигляді **таблиці (table)**, де **кожен рядок (row)** відповідає **одному року (one year)** спостереження. Це означає, що для кожної комбінації критеріїв (наприклад, жанр, тип видання, мова, регіон) фіксується окремий запис за кожен календарний рік.

Кожен рік має відповідні значення для обох мір вимірювання: для кількості видань (`titles_count`) та кількості копій (`copy_count`). 

---

## 4.  Розподіл Даних  у таблиці / Data Table Adaptation

Всі таблиці мають таку класифікацію:

 - `ds` - аббревіатура для "data structure" (структура даних) або "data set" (набір даних)
 - `_name` - назва таблиці, що вказує на її зміст

### 4.1 `ds_language`

Таблиця містить інформацію про кількість видань та копій різними мовами (languages).  
**Рядок (Row):** кожен рядок — це окремий рік спостереження для певного типу виміру (`titles_count` або `copy_count`).  
**Стовпці (Columns):**
- **#1** — `yr` — рік спостереження (year)
- **#2** — `measure` — тип виміру (`titles_count` або `copy_count`)
- **#3–#N** — назва мови (language name), для якої ведеться підрахунок

---

### 4.2 `ds_genre`

Таблиця відображає розподіл видань за жанрами (genres).  
**Рядок (Row):** рік спостереження для певного жанру та типу виміру.  
**Стовпці (Columns):**
- **#1** — `yr` — рік спостереження (year)
- **#2** — `measure` — тип виміру (`titles_count` або `copy_count`)
- **#3–#N** — назва жанру (genre name)

---

### 4.3 `ds_geography`

Таблиця містить дані про кількість видань та копій у різних регіонах (regions) України. (та Київ і Севастополь)  
**Рядок (Row):** рік спостереження для кожного регіону та типу виміру.  
**Стовпці (Columns):**
- **#1** — `yr` — рік спостереження (year)
- **#2** — `measure` — тип виміру (`titles_count` або `copy_count`)
- **#3–#N** — назва регіону (region name)

---

### 4.4 `ds_pubtype`

Таблиця відображає розподіл видань за типами (publication types).  
**Рядок (Row):** рік спостереження для кожного типу видання та типу виміру.  
**Стовпці (Columns):**
- **#1** — `yr` — рік спостереження (year)
- **#2** — `measure` — тип виміру ( `titles_count` або `copy_count`)
- **#3–#N** — назва типу видання (publication type name)

---

### 4.5 `ds_year`

Таблиця містить загальні підсумкові дані за кожен рік (annual summary data).  
**Рядок (Row):** кожен рядок — це окремий рік спостереження для певного типу виміру.  
**Стовпці (Columns):**
- **#1** — `yr` — рік спостереження (year)
- **#2** — `measure` — тип виміру (`titles_count` або `copy_count`)
- **#3** — `value` — загальна кількість видань або копій за рік (total number of publications or copies per year)

---

### 4.6 `ds_ukr_rus`

Таблиця відображає співвідношення між українськомовними та російськомовними виданнями (Ukrainian vs Russian language publications).  
**Рядок (Row):** кожен рядок — це окремий рік спостереження для певного типу виміру.  
**Стовпці (Columns):**
- **#1** — `yr` — рік спостереження (year)
- **#2** — `measure` — тип виміру (`titles_count` або `copy_count`)
- **#3** — `ukr` — кількість українськомовних видань/копій (number of Ukrainian-language publications/copies)
- **#4** — `rus` — кількість російськомовних видань/копій (number of Russian-language publications/copies)
- **#5** — `perc_ukr` — частка українських видань/копій серед загальної кількості (share of Ukraniane-language among total)
- **#6** — `perc_rus` — частка російських видань/копій серед загальної кількості (share of Russian-language among total)

---

## 5. Тип даних / Data Type

Всі наявні таблиці будуть доступні у форматах **CSV** (Comma-Separated Values), **RDS** (R Data Serialization) та будуть поміщені до **SQLite** бази даних для зручного доступу та аналізу.

Щоб отримати доступ до цих форматів даних, необхідно "запустити" код з файлу `/manipulation/0-ellis-sasha.R` та виконати його у RStudio. Після цього дані будуть доступні у директорії `data-private/derived/manipulation/`.

Також дані можна переглянути у форматі **QMD** (Quarto Markdown) у файлі `Data-visualization.qmd` або у форматі **HTML** у файлі [Data-visualization.html](https://raw.githack.com/RB-FIDES/books-of-ukraine/main/analysis/Data-visualization/Data-visual.html).

Крім того, дані знаходяться у **Google Spreadsheets** для зручності доступу та візуалізації. Ви можете знайти їх у [Data](https://docs.google.com/spreadsheets/d/1OOKeZnMFEAzHyr_M51zaOe76uv1yuqNmveHXSKpeqpo/edit?gid=2036395854#gid=2036395854).

**P.s**: знайти дані можна у `data-private/derived/manipulation/` 

---

## 6. Глосарій Термінів / Glossary of Terms

### Українською / In Ukrainian

- **Онтологія** — формалізований опис понять, відносин і структур у певній предметній області.  
- **Видання** — окрема книга або інший друкований твір, що має унікальний заголовок та ідентифікатор.  
- **Копія / Тираж** — кількість фізичних примірників одного видання.  
- **Жанр** — категорія літератури, що визначає тематичну або функціональну спрямованість твору.  
- **Тип видання** — класифікація видань за призначенням або цільовою аудиторією (наприклад, наукові, навчальні, художні).  
- **Мова видання** — мова, якою надруковано видання.  
- **Регіон** — адміністративно-територіальна одиниця України, де здійснюється облік видань.  
- **Макрорегіон** — група областей, об’єднаних для аналітичних цілей (наприклад, Північ, Південь).  
- **Рік спостереження** — календарний рік, за який зібрано дані.  
- **Структура даних** — організація даних у вигляді таблиць із визначеними змінними.  
- **Вимірювання** — кількісна характеристика (наприклад, кількість видань або копій).  
- **Загрози валідності** — фактори, що можуть впливати на достовірність висновків дослідження.  
- **Етичні зобов’язання** — принципи відповідального використання даних та AI.  
- **CSV, RDS, SQLite** — формати зберігання та обробки даних.  
- **QMD (Quarto Markdown)** — формат для інтерактивної документації та візуалізації даних.

### English / In English

- **Ontology** — a formalized description of concepts, relationships, and structures within a specific domain.  
- **Publication** — an individual book or printed work with a unique title and identifier.  
- **Copy / Print run** — the number of physical copies of a single publication.  
- **Genre** — a category of literature defining the thematic or functional focus of a work.  
- **Publication type** — classification of publications by purpose or target audience (e.g., scientific, educational, fiction).  
- **Publication language** — the language in which a publication is printed.  
- **Region** — an administrative-territorial unit of Ukraine where publications are recorded.  
- **Macroregion** — a group of oblasts combined for analytical purposes (e.g., North, South).  
- **Observation year** — the calendar year for which data is collected.  
- **Data structure** — organization of data in tables with defined variables.  
- **Measurement** — a quantitative characteristic (e.g., number of publications or copies).  
- **Threats to validity** — factors that may affect the reliability of research conclusions.  
- **Ethical commitments** — principles for responsible use of data and AI.  
- **CSV, RDS, SQLite** — data storage and processing formats.  
- **QMD (Quarto Markdown)** — a format for interactive documentation and data visualization.


---

## 7. Використання для ШІ / AI Usage
- До надання відповіді ознайомитя з фйлами даних у **RDS** та **CSV** форматах.
- Враховувати, що дані містяться у таблиція формати "wide" (широкий формат), де кожен рік представлений окремим рядком, а жанри, типи видань, мови та регіони — окремими стовпцями. (wide format).
- Використовувати дані для аналізу тенденцій, порівняння
- Якщо у користувачв відсутні файли у RDS або CSV форматах, то можна використовувати дані у **Google Spreadsheets** для аналізу та візуалізації.
(https://docs.google.com/spreadsheets/d/1OOKeZnMFEAzHyr_M51zaOe76uv1yuqNmveHXSKpeqpo/edit?gid=2036395854#gid=2036395854)
- У відповіді використовувати оригінальні назви жанрів, типів видань, мов та регіонів, як вони вказані у таблицях.
- Уникати узагальнень та стереотипів щодо жанрів, типів видань, мов та регіонів.
- Використовуй корректні шляхи для імпорту даних у RStudio, наприклад: 
   - шлях до RDS: `data-private/derived/manipulation/ds_name of file.rds`
   - шлях до CSV: `data-private/derived/manipulation/csv/ds_name of file.csv`
   - шлях до SQLite Database: `data-private/derived/manipulation/SQLite/books-of-ukraine.sqlite`

---

## 8. Зв'язки з іншими документами / Links to Other Documents

- `FIDES.md` - загальна філософія фреймворку
- `semiology.md` - діалекти виразження даних
- `onboarding-ai.md` - правила роботи з AI
- `threats-to-validity.md` - загрози валідності
- `analysis-templatization.md` - шаблонізація аналізу