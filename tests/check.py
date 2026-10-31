"""Compile sources and run background logic checks without opening Studio."""
from pathlib import Path
import argparse
import json
import shutil
import subprocess
import re
import wave

ROOT = Path(__file__).resolve().parents[1]
parser = argparse.ArgumentParser()
parser.add_argument('--luau', default=shutil.which('luau') or str(ROOT / 'work/tools/luau/luau.exe'))
parser.add_argument('--compiler', default=shutil.which('luau-compile') or str(ROOT / 'work/tools/luau/luau-compile.exe'))
parser.add_argument('--api', type=Path, default=ROOT / 'work/roblox-api.json')
args = parser.parse_args()

sources = sorted((ROOT / 'src').rglob('*.luau'))
for source in sources:
    subprocess.run([args.compiler, '--null', str(source)], check=True, capture_output=True, text=True)
print(f'PASS: compiled {len(sources)} Luau files')

mapping = {'Platforms': 'src/shared/Platforms.luau', 'Games': 'src/shared/Games.luau',
           'UI': 'src/client/UI.luau', 'Client': 'src/client/init.client.luau',
           'Server': 'src/server/init.server.luau', 'XP': 'src/client/XP/init.luau'}
for name in ('Theme', 'State', 'WindowManager', 'Settings', 'Apps'):
    mapping[name] = f'src/client/XP/{name}.luau'
embedded = '{\n' + ',\n'.join(f'[{json.dumps(name)}] = [====[{(ROOT / path).read_text(encoding="utf-8")} ]====]'
                                     for name, path in mapping.items()) + '\n}'
api_properties = {}
if args.api.is_file():
    api_dump = json.loads(args.api.read_text(encoding='utf-8-sig'))
    classes = {entry['Name']: entry for entry in api_dump['Classes']}
    def properties(name):
        entry = classes[name]
        own = {member['Name'] for member in entry['Members'] if member['MemberType'] == 'Property'}
        parent = entry['Superclass']
        return own | (properties(parent) if parent in classes else set())
    api_properties = {name: properties(name) for name in classes}
api_lua = '{' + ','.join(f'[{json.dumps(name)}] = {{' + ','.join(f'[{json.dumps(prop)}]=true' for prop in sorted(props)) + '}'
                         for name, props in api_properties.items()) + '}'
harness = (ROOT / 'tests/logic.luau').read_text(encoding='utf-8').replace('__SOURCES__', embedded).replace('__API_PROPERTIES__', api_lua)
work = ROOT / 'work'
work.mkdir(exist_ok=True)
script = work / 'logic-check.luau'
script.write_text(harness, encoding='utf-8')
subprocess.run([args.luau, str(script)], check=True)
if api_properties:
    print('PASS: assigned instance properties exist in the installed Studio API dump')

for theme in ('blue', 'olive', 'silver'):
    for filename in ('FrameCaption-1.png', 'FrameCaption-2.png', 'button-1.png', 'button-2.png',
                     'button-3.png', 'TaskbarBackground.png', 'TaskbarTray.png', 'StartButton.png'):
        assert (ROOT / 'assets/xp/luna' / theme / filename).is_file(), (theme, filename)
for font in ('Tahoma', 'Trebuchet', 'LucidaConsole'):
    json.loads((ROOT / f'assets/xp/fonts/{font}.json').read_text())
print('PASS: theme assets and font definitions')
state = (ROOT / mapping['State']).read_text(encoding='utf-8')
for catalog, folder in (('avatars', 'users'), ('wallpapers', 'images')):
    literal = re.search(rf'State\.{catalog}\s*=\s*\{{([^}}]+)\}}', state).group(1)
    for filename in re.findall(r'"([^"]+)"', literal):
        if filename != 'None':
            assert (ROOT / 'assets/xp' / folder / filename).is_file(), filename
sounds = list((ROOT / 'assets/xp/sounds').glob('*.wav'))
for path in sounds:
    with wave.open(str(path)) as sound:
        assert sound.getnframes() > 0, path
print(f'PASS: every catalog wallpaper/account picture exists; {len(sounds)} WAV files decode')
print('LIMIT: simulated Roblox services; Studio rendering, sound playback and engine behavior are unverified')
