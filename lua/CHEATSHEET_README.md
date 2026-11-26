# Economics reference browser

`econ_cheatsheet.lua` is a TI-Nspire Lua example that displays 35 economics questions and notes. The material is in transliterated Russian and covers national accounts, inflation, money and banking, input-output models, consumer theory, equilibrium and growth.

## Build and open

From the repository root, run `./scripts/build-lua.sh econ_cheatsheet`. Transfer `build/econ_cheatsheet.tns` to the TI-Nspire and open it as a document. [Lua build instructions](README.md)

## Browse questions

- In the main menu, type a question number and press **Enter**. You can also select a question with **↑** or **↓**.
- From the main menu, press **Tab** to list all questions. Use the arrow keys to select an entry and **Enter** to open it.
- In a question, use **↑** and **↓** to scroll line by line, and **←** and **→** to switch questions.
- Use **Tab**, **+** or **=** to page down. Use **-** or **_** to page up. **Esc** returns to the main menu.

## Search

- Type `1488` in the main menu to search titles.
- Type `228` in the main menu to search titles and question text. The result list shows one match per question.
- After opening a question, press **F** to search that question's text. Matches are highlighted, and the view scrolls to the first match. Press **Esc** to close the search.

Search uses case-insensitive substring matching. For example, open question 12, press **F** and type `Leont` to find lines containing that spelling.

[Lua source](econ_cheatsheet.lua) · [Original Russian notes](CHEATSHEET_README.ru.md)
