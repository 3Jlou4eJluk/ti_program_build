# Критические изменения для работы библиотеки TI-Nspire

## Проблема
Библиотека не появлялась на калькуляторе после сборки через Luna.

## Решение: строгое следование формату существующих примеров

### 1. Document.xml — использовать СТАРЫЙ формат `<doc>`

**НЕ РАБОТАЕТ** (новый формат из гайда):
```xml
<?xml version="1.0" encoding="UTF-8"?>
<document xmlns="urn:TI.Document" ver="1.0">
  <product>TI-Nspire</product>
  <platform>handheld</platform>
  ...
</document>
```

**РАБОТАЕТ** (старый формат из примеров):
```xml
<?xml version="1.0" encoding="UTF-8" ?><doc ver="1.0"><settings><assessmentMode>0</assessmentMode><devapd>0</devapd>...</settings><nps>1</nps></doc>
```

### 2. Problem1.xml — весь `<sym>` блок в ОДНУ строку

**НЕ РАБОТАЕТ** (с переносами строк и читаемым форматом):
```xml
<?xml version="1.0" encoding="UTF-8"?>
<prob xmlns="urn:TI.Problem" ver="1.0">
  <sym>
    <e t="6" f="65536">
      <n>nominal_gdp</n>
      <p>prices,quantities</p>
      <v>Func
:If dim(prices)≠dim(quantities) Then
: Return undef
:EndIf
:Return sum_prod(prices,quantities)
:EndFunc</v>
    </e>
  </sym>
</prob>
```

**РАБОТАЕТ** (вся строка `<sym>...</sym>` без переносов):
```xml
<?xml version="1.0" encoding="UTF-8" ?><prob xmlns="urn:TI.Problem" ver="1.0"><sym><e t="6" f="65536"><n>nominal_gdp</n><p>prices,quantities</p><v>Func&#13;:If dim(prices)≠dim(quantities) Then&#13;: Return undef&#13;:EndIf&#13;:Return sum_prod(prices,quantities)&#13;:EndFunc</v></e></sym></prob>
```

### 3. Переносы строк в TI-BASIC коде — ТОЛЬКО `&#13;`

**НЕ РАБОТАЕТ** (обычные переносы):
```xml
<v>Func
:Local i,s
:Return s
:EndFunc</v>
```

**РАБОТАЕТ** (с `&#13;`):
```xml
<v>Func&#13;:Local i,s&#13;:Return s&#13;:EndFunc</v>
```

### 4. Никаких комментариев

Luna **не поддерживает**:
- XML-комментарии: `<!-- comment -->`
- TI-BASIC комментарии: `:©comment`

Все комментарии нужно удалить перед сборкой.

### 5. Атрибуты функций/программ

```xml
<e t="6" f="65536">   <!-- публичная функция (Function) -->
<e t="6" f="196608">  <!-- приватная функция (LibPriv) -->
<e t="7" f="65536">   <!-- публичная программа (Program) -->
```

- `t="6"` — Function
- `t="7"` — Program
- `f="65536"` — публичная (LibPub)
- `f="196608"` — приватная (LibPriv)

## Итоговая команда сборки

```bash
./Luna/luna src/Document.xml src/Problem1.xml build/econ.tns
```

## Установка на калькулятор

1. Скопировать `build/econ.tns` в `/MyLib`
2. Ctrl+Home → **Refresh Libraries**
3. Открыть документ в **Program Editor**
4. Menu → **Library Access** → **LibPub**
5. **Check syntax & store**

Функции появятся в Catalog как `econ\function_name()`.

## Резюме

**Главное правило**: не следовать гайдам и документации, а **точно копировать формат из работающих примеров** (Doc.xml, Problem.xml). Даже если в официальных гайдах указан "современный" формат — он может не работать.
