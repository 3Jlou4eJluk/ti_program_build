# Lua Programs для TI-Nspire

Папка для Lua скриптов, которые конвертируются в .tns файлы с помощью Luna.

## 📊 Economics Calculator (economics.lua)

Интерактивный калькулятор для расчёта макроэкономических показателей на TI-Nspire.

### Возможности:

**1. GDP & Deflator** - Расчёты ВВП
- Номинальный и реальный ВВП
- GDP Deflator
- Real GDP

**2. CPI & Inflation** - Индексы цен
- CPI (Laspeyres) - индекс потребительских цен
- Inflation - уровень инфляции

**3. GDP Methods Guide** ⭐
- Справочник по 3 методам расчёта ВВП
- Общие правила расчёта
- Формулы для каждого метода:
  - Метод 1: По добавленной стоимости (DS)
  - Метод 2: По расходам (C + I + NX)
  - Метод 3: По доходам (Зарплата + Прибыль)
- Пояснения всех терминов (DS, Vyr, ZP, и т.д.)

**4. CPI Formulas Guide** ⭐ НОВОЕ
- 4 основные формулы ИПЦ (Ласпейреса)
- Формула 1: Стоимость корзины в году t
- Формула 2: ИПЦ_t (база год 0 = 100)
- Формула 3: Годовая инфляция
- Формула 4: Смена базы на год b
- Примеры расчётов для каждой формулы
- Пояснения терминов (IPC, pi, p_i_t, q_i_0)

### Использование:
```bash
# Сборка
./scripts/build-lua.sh economics

# Установка
# Скопировать build/economics.tns на калькулятор
```

### Управление:
- **↑↓** - навигация по меню
- **Enter** - выбор/расчёт
- **ESC** - возврат назад
- **0-9, ., -** - ввод чисел

## Структура

```
lua/
├── example.lua          # Пример Lua программы
├── your_program.lua     # Ваши Lua скрипты
└── README.md           # Эта документация
```

## Создание Lua программы

### 1. Создайте .lua файл

Пример (`example.lua`):
```lua
-- Simple calculator for TI-Nspire
function on.paint(gc)
    gc:drawString("Hello from Lua!", 10, 10, "top")
end

function calculate(a, b)
    return a + b
end
```

### 2. Конвертация в .tns

**Один Lua файл:**
```bash
./tools/Luna/luna lua/your_program.lua build/your_program.tns
```

**Несколько Lua файлов (первый будет главным):**
```bash
./tools/Luna/luna lua/main.lua lua/utils.lua build/program.tns
```

### 3. Установка на калькулятор

1. Подключите TI-Nspire к компьютеру
2. Скопируйте `build/your_program.tns` на калькулятор
3. Откройте файл на калькуляторе

## Особенности Lua на TI-Nspire

### API для работы с экраном
```lua
function on.paint(gc)
    gc:setColorRGB(0, 0, 0)  -- Черный цвет
    gc:drawString("Text", x, y, "top")
    gc:drawRect(x, y, width, height)
    gc:fillRect(x, y, width, height)
end
```

### Обработка событий
```lua
function on.enterKey()
    -- Обработка Enter
end

function on.charIn(char)
    -- Обработка ввода символа
end

function on.arrowKey(key)
    -- Обработка стрелок
    -- key: "up", "down", "left", "right"
end
```

### Математические функции
```lua
math.sqrt(x)
math.sin(x)
math.cos(x)
math.tan(x)
```

## Примеры

### Простой калькулятор
```lua
local result = 0

function on.paint(gc)
    gc:drawString("Result: " .. result, 10, 10, "top")
end

function on.charIn(char)
    if tonumber(char) then
        result = result * 10 + tonumber(char)
        platform.window:invalidate()
    end
end
```

### График функции
```lua
function on.paint(gc)
    local width, height = platform.window:width(), platform.window:height()

    -- Оси
    gc:drawLine(0, height/2, width, height/2)  -- X
    gc:drawLine(width/2, 0, width/2, height)   -- Y

    -- График y = sin(x)
    for x = 0, width do
        local xval = (x - width/2) / 20
        local yval = math.sin(xval)
        local y = height/2 - yval * 50
        gc:fillRect(x, y, 1, 1)
    end
end
```

## Отладка

Luna автоматически генерирует `Document.xml` если он не указан.

Для проверки содержимого .tns файла:
```bash
unzip -l build/your_program.tns
```

## Ресурсы

- [TI-Nspire Lua API Documentation](https://education.ti.com/en/product-resources/nspire-lua)
- [Inspired Lua Community](https://www.inspired-lua.org/)
- [Luna Compiler](https://github.com/ndless-nspire/Luna)
