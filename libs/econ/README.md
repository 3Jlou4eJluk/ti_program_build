# Библиотека econ для TI-Nspire

Библиотека экономических формул для расчёта макроэкономических показателей.

## Файлы

- `Document.xml` - конфигурационный файл
- `Problem1.xml` - код функций

## Установка на калькулятор

1. Собрать библиотеку: `./scripts/build.sh econ`
2. Скопировать `build/econ.tns` в папку `/MyLib` на калькуляторе
3. Нажать **Ctrl+Home** → **Refresh Libraries**
4. Функции доступны в Catalog как `econ\function_name()`

## Функции

### `econ\version()`

Возвращает версию библиотеки.

### `econ\nominal_gdp(prices, quantities)`

Рассчитывает номинальный ВВП.

**Пример:**
```
econ\nominal_gdp({10,20,30}, {5,3,2})
→ 170
```

### `econ\real_gdp(base_prices, quantities)`

Рассчитывает реальный ВВП на основе базовых цен.

### `econ\gdp_deflator(nominal, real)`

Рассчитывает дефлятор ВВП.

**Формула:** (Номинальный ВВП / Реальный ВВП) × 100

### `econ\cpi(cost_current, cost_base)`

Рассчитывает индекс потребительских цен (CPI).

**Формула:** (Текущая стоимость / Базовая стоимость) × 100

### `econ\inflation_rate(cpi_current, cpi_previous)`

Рассчитывает уровень инфляции.

**Формула:** ((CPI текущий - CPI предыдущий) / CPI предыдущий) × 100

### `econ\basket_cost(prices, quantities)`

Рассчитывает стоимость потребительской корзины.

### `econ\cpi_from_baskets(p_current, p_base, quantities)`

Рассчитывает CPI на основе корзин с текущими и базовыми ценами.

### `econ\growth_rate(old_value, new_value)`

Рассчитывает темп роста.

**Формула:** ((Новое значение - Старое значение) / Старое значение) × 100

### `econ\help()`

Выводит справку по библиотеке.

## Сборка

```bash
./scripts/build.sh econ
```

Создаст файл `build/econ.tns`.
