# TI-Nspire Library Builder

Проект для разработки и сборки пользовательских библиотек для калькулятора TI-Nspire CAS.

## Структура проекта

```
ti_program_build/
├── libs/                      # Исходники библиотек (TI-BASIC)
│   ├── econ/                  # Библиотека экономических формул
│   │   ├── Document.xml
│   │   ├── Problem1.xml
│   │   └── README.md
│   └── leontief/              # Библиотека модели Леонтьева
│       ├── Document.xml
│       ├── Problem1.xml
│       └── README.md
├── lua/                       # Lua программы
│   ├── economics.lua          # Экономический калькулятор
│   └── README.md              # Документация по Lua
├── build/                     # Собранные .tns файлы
│   ├── econ.tns               # Библиотеки
│   ├── leontief.tns
│   └── economics.tns          # Экономический калькулятор (Lua)
├── examples/                  # Примеры библиотек для изучения
│   ├── linalg/                # Линейная алгебра (официальный пример)
│   └── numtheory/             # Теория чисел (официальный пример)
├── tools/                     # Инструменты сборки
│   └── Luna/                  # Luna - компилятор TI-Nspire
├── scripts/                   # Скрипты сборки
│   ├── build.sh               # Сборка одной библиотеки (TI-BASIC)
│   ├── build-all.sh           # Сборка всех библиотек
│   └── build-lua.sh           # Сборка Lua программы
└── docs/                      # Документация
    ├── delta.md               # Базовые правила форматирования
    └── delta2.md              # Отладка и решение проблем
```

## Быстрый старт

### 1. Сборка Luna (первый раз)

```bash
cd tools/Luna
make
cd ../..
```

### 2. Сборка библиотеки

Сборка одной библиотеки:
```bash
./scripts/build.sh econ
# или
./scripts/build.sh leontief
```

Сборка всех библиотек:
```bash
./scripts/build-all.sh
```

### 3. Сборка Lua программы

```bash
./scripts/build-lua.sh economics
```

### 4. Установка на калькулятор

1. Подключите TI-Nspire к компьютеру
2. Скопируйте `build/<library>.tns` в папку `/MyLib` на калькуляторе
3. На калькуляторе: **Ctrl+Home** → **Refresh Libraries**
4. Библиотека доступна в Catalog

## Доступные библиотеки

### econ - Экономические формулы

Расчёт макроэкономических показателей: ВВП, CPI, инфляция, темп роста.

**Документация:** [libs/econ/README.md](libs/econ/README.md)

**Пример:**
```
econ\cpi(150, 100)
→ 150
```

### leontief - Модель Леонтьева

Проверка продуктивности матриц по модели межотраслевого баланса Леонтьева.

**Документация:** [libs/leontief/README.md](libs/leontief/README.md)

**Пример:**
```
leontief\is_productive([[0.04,0.02,0.06],[0.10,0.14,0.06],[0.06,0.04,0.08]])
→ 1
```

## Lua программы

### economics - Экономический калькулятор

Полнофункциональная Lua программа с текстовым интерфейсом для экономических расчётов.

**Документация:** [lua/README.md](lua/README.md)

**Функции:**
- **ВВП:**
  - Номинальный и реальный ВВП
  - Дефлятор ВВП
  - Реальный ВВП
- **ИПЦ и инфляция:**
  - Индекс Ласпейреса (ИПЦ)
  - Индекс Пааше
  - Индекс Фишера
  - Инфляция
  - Реальный доход
  - Покупательная способность

**Примечание:** Модель Леонтьева реализована в библиотеке `leontief` (см. выше).

**Использование:**
1. Собрать: `./scripts/build-lua.sh economics`
2. Скопировать `build/economics.tns` на калькулятор
3. Открыть файл на калькуляторе
4. Навигация: ↑↓ - выбор, Enter - открыть, ESC - назад, Tab - переход между полями

## Создание новой библиотеки

### Шаг 1: Создайте структуру

```bash
mkdir libs/mylib
```

### Шаг 2: Создайте файлы

**libs/mylib/Document.xml:**
```xml
<?xml version="1.0" encoding="UTF-8" ?><doc ver="1.0"><settings>...</settings><nps>1</nps></doc>
```

Скопируйте из `libs/econ/Document.xml` и адаптируйте при необходимости.

**libs/mylib/Problem1.xml:**
```xml
<?xml version="1.0" encoding="UTF-8" ?><prob xmlns="urn:TI.Problem" ver="1.0"><sym>
<e t="6" f="65536"><n>version</n><p></p><v>Func&#13;:Return "1.0.0"&#13;:EndFunc</v></e>
<e t="6" f="65536"><n>myfunction</n><p>x</p><v>Func&#13;:Return x*2&#13;:EndFunc</v></e>
</sym><card>...</card></prob>
```

### Шаг 3: Соберите и протестируйте

```bash
./scripts/build.sh mylib
```

### Шаг 4: Создайте README.md

```bash
cp libs/econ/README.md libs/mylib/README.md
# Отредактируйте под вашу библиотеку
```

## Документация

- **[docs/delta.md](docs/delta.md)** - Базовые правила форматирования TI-Nspire библиотек
- **[docs/delta2.md](docs/delta2.md)** - Отладка и решение проблем
- **[examples/](examples/)** - Официальные примеры библиотек от TI

## Важные правила

1. **Всегда используйте `Then` после `If`:**
   ```
   If условие Then
   :команды
   :EndIf
   ```

2. **XML-экранирование операторов:**
   - `<` → `&lt;`
   - `>` → `&gt;`
   - `&` → `&amp;`

3. **Используйте `&#13;` для переноса строк** в XML

4. **Func vs Prgm:**
   - `Func` - функции для вычислений (не могут использовать `Disp`)
   - `Prgm` - программы с выводом (могут использовать `Disp`)

## Требования

- Linux/macOS/WSL
- GCC компилятор (для сборки Luna)
- zlib development headers (`zlib1g-dev` на Ubuntu/Debian)

## Лицензия

Luna - см. `tools/Luna/LICENSE`

Библиотеки - MIT License
