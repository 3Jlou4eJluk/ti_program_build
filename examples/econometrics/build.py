"""Build TI-Nspire MyLib documents with Luna. Run with --help for usage."""
import argparse
import json
import os
from pathlib import Path
import runpy
import shutil
import subprocess
import sys
import tempfile
from xml.sax.saxutils import escape
from zipfile import ZIP_DEFLATED, ZipFile

ROOT = Path(__file__).resolve().parent
HEADER = '<?xml version="1.0" encoding="UTF-8" ?>'
CARD = ('<card clay="0" h1="10000" h2="10000" w1="10000" w2="10000"><flag>0</flag>'
        '<wdgt xmlns:np="urn:TI.Notepad" type="TI.Notepad" ver="1.0">'
        '<np:mFlags>0</np:mFlags><np:value>3</np:value><np:txt>')
END_CARD = '</np:txt></wdgt></card>'


def function_xml(name, args, source):
    lines = source.strip().splitlines()
    if lines[0] != 'Func' or lines[-1] != ':EndFunc' or any(not line.startswith(':') for line in lines[1:]):
        raise ValueError(f'{name}: invalid TI-BASIC function layout')
    value = '&#13;'.join(escape(line) for line in lines)
    return f'<e t="6" f="65536" c="0"><n>{name}</n><p>{args}</p><v>{value}</v></e>'


def build(luna, name, symbols, pages):
    cards = ''.join(CARD + escape(page) + END_CARD for page in pages)
    problem = f'{HEADER}<prob xmlns="urn:TI.Problem" ver="1.0"><sym>{symbols}</sym>{cards}</prob>'
    output = ROOT / 'build'
    output.mkdir(exist_ok=True)
    with tempfile.TemporaryDirectory(dir=output) as wd:
        wd = Path(wd)
        shutil.copyfile(ROOT / 'Document.xml', wd / 'Document.xml')
        (wd / 'Problem1.xml').write_text(problem, encoding='utf-8')
        subprocess.run([luna, 'Document.xml', 'Problem1.xml', f'{name}.tns'], cwd=wd, check=True)
        os.replace(wd / f'{name}.tns', output / f'{name}.tns')

def read_cards():
    guide_dir = ROOT / 'guide'
    # Keep exam walkthroughs ahead of the supplementary topics.
    paths = sorted(guide_dir.glob('*.json'), key=lambda path: (path.stem == 'walk_course', path.name))
    for path in paths:
        for card in json.loads(path.read_text(encoding='utf-8')):
            if card['section'] not in ('theory', 'practice', 'guide'):
                raise ValueError(f'{path}: invalid section')
            fields = {key: card[key].strip() for key in ('section', 'title', 'tags', 'body')}
            if not all(fields.values()):
                raise ValueError(f'{path}: empty card field')
            if fields['section'] == 'guide':
                fields['scope'] = 'Пошаговый разбор'
            else:
                fields['scope'] = ('Расширение курса' if path.stem in ('extra', 'connections')
                                   else 'Тема с фото')
            yield fields


def walkthrough_markdown():
    cards = [card for card in read_cards() if card['section'] == 'guide']
    if not cards:
        raise ValueError('The walkthrough section is empty')
    lines = ['# Эконометрика. Как решать задачи', '',
             'Выбери разбор по данным в условии. В каждом есть промежуточные вычисления и вывод, который можно записать в работе.', '']
    for i, card in enumerate(cards, 1):
        lines.append(f"{i}. [{card['title']}](#task-{i})")
    for i, card in enumerate(cards, 1):
        lines.extend(['', f'<a id="task-{i}"></a>', '', f"## {card['title']}"])
        for paragraph in card['body'].split('\n\n'):
            rows = [row.strip().replace('*', r'\*') for row in paragraph.splitlines()]
            lines.extend(['', '<br>\n'.join(rows)])
    return '\n'.join(lines) + '\n'


def handbook_source():
    cards = ['{' + ','.join(key + '=' + json.dumps(value, ensure_ascii=False)
                             for key, value in card.items()) + '}'
             for card in read_cards()]
    template = (ROOT / 'handbook.lua').read_text(encoding='utf-8')
    font = (ROOT / 'font.lua').read_text(encoding='utf-8')
    return ('local CARDS = {\n' + ',\n'.join(cards) + '\n}\n'
            + 'local BITMAPS = (function()\n' + font + 'end)()\n' + template)


def package():
    output = ROOT / 'build'
    with tempfile.TemporaryDirectory(dir=output) as wd:
        archive = Path(wd) / 'econometrics-cx-ii-t.zip'
        guide_name = 'how-to-solve.ru.md'
        guide_path = Path(wd) / guide_name
        guide_path.write_text(walkthrough_markdown(), encoding='utf-8')
        with ZipFile(archive, 'w', ZIP_DEFLATED) as bundle:
            bundle.write(guide_path, guide_name)
            bundle.write(output / 'krguide.tns', 'krguide.tns')
            for source in sorted((ROOT / 'libs').glob('kr*.py')):
                filename = source.stem + '.tns'
                bundle.write(output / filename, 'MyLib/' + filename)
            for source in [*sorted(ROOT.glob('README*.md')), *sorted((ROOT / 'guide').rglob('*.md')),
                           *sorted(ROOT.glob('*LICENSE*'))]:
                bundle.write(source, source.relative_to(ROOT))
        os.replace(guide_path, output / guide_name)
        os.replace(archive, output / archive.name)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--luna', default='luna', help='Luna binary or absolute path')
    parser.add_argument('--guide-source', action='store_true', help='Write the generated guide Lua to stdout')
    args = parser.parse_args()
    if args.guide_source:
        sys.stdout.buffer.write(handbook_source().encode('utf-8'))
        return
    luna = shutil.which(args.luna)
    if not luna:
        parser.error('Luna not found. Pass --luna /path/to/Luna/luna')
    luna = str(Path(luna).resolve())
    for path in sorted((ROOT / 'libs').glob('kr*.py')):
        functions = runpy.run_path(str(path))['FUNCTIONS']
        symbols = ''.join(function_xml(k, *v) for k, v in functions.items())
        notes = [f'{path.stem} / MyLib\n' + '\n'.join(f'{k}({args})' for k, (args, _) in functions.items())]
        build(luna, path.stem, symbols, notes)
    with tempfile.TemporaryDirectory(dir=ROOT / 'build') as wd:
        wd = Path(wd)
        (wd / 'krguide.lua').write_text(handbook_source(), encoding='utf-8')
        subprocess.run([luna, 'krguide.lua', 'krguide.tns'], cwd=wd, check=True)
        os.replace(wd / 'krguide.tns', ROOT / 'build' / 'krguide.tns')
        subprocess.run([luna, str(ROOT / 'tests' / 'krcheck.lua'), 'krcheck.tns'], cwd=wd, check=True)
        os.replace(wd / 'krcheck.tns', ROOT / 'build' / 'krcheck.tns')
    package()


if __name__ == '__main__':
    main()
