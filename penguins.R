cat("\014") # Clear console
rm(list = ls(all.names = TRUE)) # Clear the environment
# ---- load-sources ------------------------------------------------------------
base::source("./scripts/common-functions.R") # Load common functions for the project
# ---- load-packages -----------------------------------------------------------
library(palmerpenguins)
library(ggthemes)
# ---- declare-globals ---------------------------------------------------------

# ---- load-data ---------------------------------------------------------------
ds0 <- palmerpenguins::penguins
# ---- inspect-data-0 ----------------------------------------------------------
ds0
print(x = ds0, n = 5) # Print the dataset to see 5 rows
ds0 %>% print(n = 5) # Alternative way to print the dataset
ds0 %>% glimpse() # Inspect the structure of the dataset
# ---- tweak-data --------------------------------------------------------------

# ---- tweak-data-1 ------------------------------------------------------------

# ---- table-1 -----------------------------------------------------------------

# ---- graph-1 -----------------------------------------------------------------
# Візуалізувати взаємозвʼязок між довжиною плавників і масою тіла пінгвінів
# Використала підказку з документації ggplot2 27 - холст, 28 - пензлик
# ds0 %>%
#   ggplot2::ggplot(aes(x = flipper_length_mm, y = body_mass_g, color = species)) +
#   geom_point() +
#   # labs(
#   #   title = "Penguin Flipper Length vs Body Mass",
#   #   x = "Flipper Length (mm)",
#   #   y = "Body Mass (g)"
#   # ) +
#   # theme(
#   #   text = element_text(size = 12),
#   #   legend.position = "bottom"
#   # ) +
#   # scale_color_brewer(palette = "Set1") +
#   theme_minimal()

# Першим аргументом ggplot() є набір даних для використання в графіку,
# тому ggplot(data = penguins) створює порожній графік,
# який призначений для відображення даних про пінгвінів,
# але оскільки ми ще не розповіли, як їх візуалізувати, наразі він порожній.
ggplot(data = penguins)

# Далі нам потрібно вказати ggplot(), як інформація з наших даних
# буде візуально представлена.
# Аргумент mapping функції ggplot() визначає,
# як змінні у вашому наборі даних зіставляються
# з візуальними властивостями (естетикою) вашого графіка.
# Аргумент mapping завжди визначено у функції aes(),
# а аргументи x та y функції aes() вказують,
# які змінні слід зіставити з осями x та y.
# Наразі ми зіставимо лише довжину ласт з естетикою x та масу тіла з естетикою y.
# ggplot2 шукає зіставлені змінні в аргументі dataargument,
# у цьому випадку пінгвінів.)
ggplot(
  data = penguins,
  mapping = aes(x = flipper_length_mm, y = body_mass_g)
)
#> Повідомляє, що вилучено 2 рядки, що містять відсутні значення (geom_point()).

#> Додає точки до графіка, які представляють кожного пінгвіна
ggplot(
  data = penguins,
  mapping = aes(x = flipper_length_mm, y = body_mass_g)
) +
  geom_point()

#> Далі нам потрібно визначити геому (geom): геометричний обʼєкт,
#> який графік використовує для представлення даних.
#> Ці геометричні обʼєкти доступні в ggplot2
#> з функціями, які починаються з geom_.
#>
ggplot(
  data = penguins,
  mapping = aes(x = flipper_length_mm, y = body_mass_g, color = species)
) +
  geom_point()

#> Додаємо колір до точок, щоб відобразити різні види пінгвінів.
ggplot(
  data = penguins,
  mapping = aes(x = flipper_length_mm, y = body_mass_g, color = species)
) +
  geom_point() +
  geom_smooth(method = "lm")

#> Додаємо лінію регресії, щоб показати тренд даних.
ggplot(
  data = penguins,
  mapping = aes(x = flipper_length_mm, y = body_mass_g)
) +
  geom_point(mapping = aes(color = species)) +
  geom_smooth(method = "lm")
#> окрім кольору, ми також можемо зіставити види з естетикою форми
ggplot(
  data = penguins,
  mapping = aes(x = flipper_length_mm, y = body_mass_g)
) +
  geom_point(mapping = aes(color = species, shape = species)) +
  geom_smooth(method = "lm")
# Покращую підписи графіка за допомогою функції labs() у новому шарі
ggplot(
  data = penguins,
  mapping = aes(x = flipper_length_mm, y = body_mass_g)
) +
  geom_point(aes(color = species, shape = species)) +
  geom_smooth(method = "lm") +
  labs(
    title = "Body mass and flipper length",
    subtitle = "Dimensions for Adelie, Chinstrap, and Gentoo Penguins",
    x = "Flipper length (mm)", y = "Body mass (g)",
    color = "Species", shape = "Species"
  ) +
  scale_color_colorblind()

# Завдання 3 Створіть діаграму розсіювання bill_depth_mm проти bill_length_mm.
ggplot(
  data = penguins,
  mapping = aes(x = bill_depth_mm, y = bill_length_mm, color = species)
) +
  geom_point()
# Розсіювання не щільне, багато викидів, вірогідно для Adelie ці показники слабо корегуються

# Завлання 4 Що станеться, якщо створити діаграму розсіювання видів проти bill_depth_mm?
# Який вибір geom може бути кращим?
# Не розумію
# Завдання 4 - ПРАВИЛЬНЕ РІШЕННЯ:
# Species vs bill_depth_mm потребує іншого geom!

# Варіант А: Box plot (коробчаста діаграма)
ggplot(
  data = penguins,
  mapping = aes(x = species, y = bill_depth_mm, color = species)
) +
  geom_boxplot() +
  labs(
    title = "Bill Depth Distribution by Species",
    subtitle = "Comparison across Adelie, Chinstrap, and Gentoo",
    x = "Species (види)",
    y = "Bill Depth (мм)"
  )

# Варіант Б: Violin plot (скрипкова діаграма)
ggplot(
  data = penguins,
  mapping = aes(x = species, y = bill_depth_mm, fill = species)
) +
  geom_violin() +
  geom_point(position = "jitter", alpha = 0.5) +
  labs(
    title = "Bill Depth Distribution by Species",
    x = "Species",
    y = "Bill Depth (mm)"
  ) +
  scale_fill_colorblind()

# Варіант В: Strip chart (стрічкова діаграма)
ggplot(
  data = penguins,
  mapping = aes(x = species, y = bill_depth_mm, color = species)
) +
  geom_jitter(width = 0.2, alpha = 0.7) +
  stat_summary(fun = mean, geom = "point", size = 3, color = "black") +
  labs(
    title = "Individual Bill Depths by Species",
    x = "Species",
    y = "Bill Depth (mm)"
  )
# Завдання 5.	Чому наступне дає помилку і як би ви її виправили?
#ggplot(data = penguins) + 
  #geom_point()
# Task 6.1	What does the na.rm argument do in geom_point()? 
# Обробляє відсутні дані
# Task 6.2 What is the default value of the argument? 
# FALSE
# Task 6.3 What happens if you set na.rm = TRUE?
# - Ми встановлюємо na.rm = TRUE в загальних функціях R, щоб виключити відсутні (NA) значення.
# Task 7. Add the following caption to the plot you made in the previous exercise:
# “Data come from the palmerpenguins package.”
ggplot(
  data = penguins,
  mapping = aes(x = flipper_length_mm, y = body_mass_g, color = species)
) +
  geom_point() +
  labs(
    caption = "Data come from the palmerpenguins package."
  )
# Використовуємо labs() для додавання підпису до графіка. 
# Дані з https://ggplot2.tidyverse.org/reference/labs.html
# labs(
#   ...,
#   title = waiver(),
#   subtitle = waiver(),
#   caption = waiver(),
#   tag = waiver(),
#   alt = waiver(),
#   alt_insight = waiver()
# )

# xlab(label)
# 
# ylab(label)
# 
# ggtitle(label, subtitle = waiver())
# 
# get_labs(plot = last_plot())
# Tasc 8.1 8.	Відтворіть наступну візуалізацію.

# Tasc 8.2 З якою естетикою слід відіставити bill_depth_mm?
# Tasc 8.3 І чи слід це відображати на глобальному рівні чи на рівні геоми?
# ---- task-8-recreation-step-by-step ---------------------------------------
# Завдання 8.1: Відтворення візуалізації з penguins
# Крок 1: Ідентифікуємо компоненти target visualization
target_components <- list(
  x_axis = "flipper_length_mm", # горизонтальна вісь
  y_axis = "body_mass_g", # вертикальна вісь
  point_color = "species", # колір точок за видами
  point_size = "bill_depth_mm", # розмір точок за глибиною дзьоба
  geom_type = "geom_point", # тип геометрії
  additional_layer = "geom_smooth" # лінія тренду
)

# Крок 2: Базова структура
task_8_base <- ggplot(
  data = penguins,
  mapping = aes(
    x = flipper_length_mm,
    y = body_mass_g
  )
)

# Крок 3: Додаємо aesthetics поетапно
task_8_with_aesthetics <- ggplot(
  data = penguins,
  mapping = aes(
    x = flipper_length_mm,
    y = body_mass_g,
    size = bill_depth_mm, # SIZE для bill_depth_mm
    color = species # COLOR для species
  )
)

# Крок 4: Повна візуалізація
task_8_complete <- task_8_with_aesthetics +
  geom_point(alpha = 0.6) +
  geom_smooth(method = "lm", se = FALSE) +
  scale_color_colorblind() +
  labs(
    title = "Body mass and flipper length",
    subtitle = "Dimensions for Adelie, Chinstrap, and Gentoo Penguins",
    x = "Flipper length (mm)",
    y = "Body mass (g)",
    size = "Bill depth (mm)",
    color = "Species",
    caption = "Data come from the palmerpenguins package."
  )

# Виводимо результат
task_8_complete
# Відповідність кольторів та розмірів
# ---- task-8-color-solutions -----------------------------------------------

# ВАРІАНТ 1: Точне відтворення R4DS book (default colors)
task_8_book_exact <- ggplot(
  data = penguins,
  mapping = aes(
    x = flipper_length_mm,
    y = body_mass_g,
    size = bill_depth_mm,
    color = species
  )
) +
  geom_point(alpha = 0.6) +
  geom_smooth(method = "lm", se = FALSE) +
  # НЕ ДОДАЄМО scale_color_* - використовуємо default
  labs(
    title = "Body mass and flipper length",
    subtitle = "Dimensions for Adelie, Chinstrap, and Gentoo Penguins",
    x = "Flipper length (mm)",
    y = "Body mass (g)",
    size = "Bill depth (mm)",
    color = "Species",
    caption = "Data come from the palmerpenguins package."
  )

# ВАРІАНТ 2: Accessibility-focused (твоя поточна версія)
task_8_accessible <- task_8_book_exact +
  scale_color_colorblind()

# ВАРІАНТ 3: Manual color specification (повний контроль)
task_8_manual_colors <- task_8_book_exact +
  scale_color_manual(
    values = c(
      "Adelie" = "#F8766D", # Default ggplot2 red
      "Chinstrap" = "#00BA38", # Default ggplot2 green
      "Gentoo" = "#619CFF" # Default ggplot2 blue
    )
  )

# Виводимо book-exact версію для відповідності:
task_8_book_exact

# ---- task-8-final-book-reproduction ---------------------------------------

# ШІ: Остаточна версія для співпадіння з книжкою:
task_8_final <- ggplot(
  data = penguins,
  mapping = aes(
    x = flipper_length_mm,
    y = body_mass_g,
    size = bill_depth_mm,    # SIZE aesthetic - GLOBAL level
    color = species          # COLOR aesthetic - GLOBAL level
  )
) +
  geom_point(alpha = 0.6) +
  geom_smooth(method = "lm", se = FALSE) +
  # ВИДАЛЯЄМО scale_color_colorblind() для book reproduction
  labs(
    title = "Body mass and flipper length",
    subtitle = "Dimensions for Adelie, Chinstrap, and Gentoo Penguins",
    x = "Flipper length (mm)",
    y = "Body mass (g)",
    size = "Bill depth (mm)",
    color = "Species",
    caption = "Data come from the palmerpenguins package."
  )

# Display результат:
task_8_final

# Task 9
ggplot(
  data = penguins,
  mapping = aes(x = flipper_length_mm, y = body_mass_g, color = island)
  ) +
  geom_point() +
  geom_smooth(se = FALSE)
# Task 10 Will these two graphs look different? Why/why not?
ggplot(
  data = penguins,
  mapping = aes(x = flipper_length_mm, y = body_mass_g)
) +
  geom_point() +
  geom_smooth()

ggplot() +
  geom_point(
    data = penguins,
    mapping = aes(x = flipper_length_mm, y = body_mass_g)
  ) +
  geom_smooth(
    data = penguins,
    mapping = aes(x = flipper_length_mm, y = body_mass_g)
  )

### 1.3 ggplot2 "Дзвінки"
ggplot(
  data = penguins,
  mapping = aes(x = flipper_length_mm, y = body_mass_g)
) +
  geom_point()
ggplot(penguins, aes(x = flipper_length_mm, y = body_mass_g)) + 
  geom_point()
penguins |> 
  ggplot(aes(x = flipper_length_mm, y = body_mass_g)) + 
  geom_point()
# Розподіл категорійної змінної - використовуйте гістограму
ggplot(penguins, aes(x = species)) +
  geom_bar()
# Перетворення змінної на фактор для перевпорядкування стовпців на основі їхніх частот
ggplot(penguins, aes(x = fct_infreq(species))) +
  geom_bar()
# A numerical variable, histogram
ggplot(penguins, aes(x = body_mass_g)) +
  geom_histogram(binwidth = 200)
# ширина стовпчика
ggplot(penguins, aes(x = body_mass_g)) +
  geom_histogram(binwidth = 20)
ggplot(penguins, aes(x = body_mass_g)) +
  geom_histogram(binwidth = 2000)
# графік щільності
ggplot(penguins, aes(x = body_mass_g)) +
  geom_density()
#> Warning: Removed 2 rows containing non-finite outside the scale range
#> (`stat_density()`).
### Tasks
# Task 1. Побудуйте стовпчикову діаграму видів пінгвінів, 
# де ви призначите види естетиці y.
ggplot(penguins, aes(y = species)) +
  geom_bar() +
  labs(title = "Penguin Species Count", y = "Species")
# Task 2.1.	Чим відрізняються наступні два графіки? 
ggplot(penguins, aes(x = species)) +
  geom_bar(color = "red")

ggplot(penguins, aes(x = species)) +
  geom_bar(fill = "red")
# ✅ (fill - це естетика, яка визначає колір заливки стовпців)
# Task 2.2. Яка естетика, колір чи заливка, 
#є більш корисною для зміни кольору стовпців?
# ✅ заливка (fill) є більш корисною для зміни кольору стовпців
# Task 3 Що робить аргумент bins у geom_histogram()?
# ✅ визначає кількість інтервалів, на які буде розділено діапазон значень 
# Task 4. Створіть гістограму змінної carat у наборі даних diamonds
ggplot(diamonds, aes(x = carat)) +
  geom_bar(bins = 20, fill = "red")
# ❓ Чому Ignoring unknown parameters: `binwidth`and `bins`?
ggplot(diamonds, aes(x = carat)) +
  geom_bar(width = 20, fill = "red")
# ✅  Якщо ти мала на увазі ширину стовпця, то треба використати "width" замість "binwidth"
# Ця помилка виникає, коли використовуєш параметр якого не існує в даному geom_.
ds1 <- diamonds
# ---- inspect-data-0 ----------------------------------------------------------
ds1
# A tibble: 53,940 × 10

# Експериментуйте з різною шириною бінів. ⁉️Як⁉️
# Яка ширина бінів виявляє найцікавіші закономірності?
### Візуалізація звʼязків
ggplot(penguins, aes(x = species, y = body_mass_g)) +
  geom_boxplot()

ggplot(penguins, aes(x = body_mass_g, color = species)) +
  geom_density(linewidth = 0.75) # Linewidth (ширина лінії)

ggplot(penguins, aes(x = body_mass_g, color = species)) +
  geom_density(linewidth = 1) # Збільшила ширину ліній

ggplot(penguins, aes(x = body_mass_g, color = species, fill = species)) +
  geom_density(alpha = 0.5)

# ⚠️ Note the terminology we have used here:
#   •	We map variables to aesthetics if we want the visual attribute represented by that aesthetic to vary based on the values of that variable.
#   •	Otherwise, we set the value of an aesthetic.
# Зверніть увагу на термінологію, яку ми використовували тут:
#   •	Ми зіставляємо змінні з естетикою, якщо хочемо, щоб візуальний атрибут, представлений цією естетикою, змінювався на основі значень цієї змінної.
#   •	В іншому випадку ми встановлюємо значення естетики.
### Two categorical variables
ggplot(penguins, aes(x = island, fill = species)) +
  geom_bar()

# графік відносної частоти
ggplot(penguins, aes(x = island, fill = species)) +
  geom_bar(position = "fill")

# Три або більше змінних
ggplot(penguins, aes(x = flipper_length_mm, y = body_mass_g)) +
  geom_point(aes(color = species, shape = island))
# to split your plot into facets
ggplot(penguins, aes(x = flipper_length_mm, y = body_mass_g)) +
  geom_point(aes(color = species, shape = species)) +
  facet_wrap(~island)

### Вправи
?mpg
# 1. Які змінні в mpg є категорійними?
# ✅  "type" of car, fuel type, drv, number of cylinders, 
#year, displ, model, manufacturer, 
# Які змінні в mpg є числовими?
# ✅  "cty" (city miles per gallon), "hwy" (highway miles per gallon),

# 2. Створіть графік розсіювання for highway mpg.








