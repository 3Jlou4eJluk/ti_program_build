"""Build practice cards from the numerical MyLib function catalog."""

import json
from pathlib import Path
import runpy

ROOT = Path(__file__).resolve().parent


def solver_cards():
    path = ROOT / 'solver_entries.json'
    entries = json.loads(path.read_text(encoding='utf-8'))
    expected = {
        f'{source.stem}\\{name}'
        for source in (ROOT / 'libs').glob('kr*.py')
        for name in runpy.run_path(str(source))['FUNCTIONS']
        if name != 'version'
    }
    seen = set()
    for entry in entries:
        library, name = entry['library'], entry['name']
        qualified = f'{library}\\{name}'
        if qualified not in expected or qualified in seen:
            raise ValueError(f'{path}: unexpected or duplicate solver {qualified}')
        seen.add(qualified)

        title, tags, description, question, conditions, call, result = (
            entry[key].strip() for key in
            ('title', 'tags', 'description', 'question', 'conditions', 'example', 'result')
        )
        if not all((title, tags, description, question, conditions, call, result)):
            raise ValueError(f'{path}: empty field for {qualified}')
        if not call.startswith(f'{qualified}(') or not call.endswith(')'):
            raise ValueError(f'{path}: invalid example for {qualified}')

        yield {
            'section': 'practice',
            'id': qualified,
            'title': title,
            'tags': f'{qualified} {tags}',
            'description': description,
            'example': question,
            'body': '\n\n'.join((description, f'Условия. {conditions}', f'Пример задачи. {question}', f'{call}\n{result}')),
            'scope': f'Решатель · {library}',
        }
    if missing := expected - seen:
        raise ValueError(f'{path}: missing solver entries for {", ".join(sorted(missing))}')
