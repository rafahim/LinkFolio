#!/usr/bin/env sh
set -eu
ROOT="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
cd "$ROOT"
if [ ! -f SOURCE-CODE.txt ]; then
  printf '%s\n' 'SOURCE-CODE.txt is required to rebuild the project files.' >&2
  exit 1
fi
python3 - <<'PY'
from pathlib import Path
import re
root = Path.cwd()
source = (root / 'SOURCE-CODE.txt').read_text(encoding='utf-8')
parts = re.split(r'(?m)^===FILE: (.+?)===\r?\n', source)
if len(parts) < 3:
    raise SystemExit('No file sections were found in SOURCE-CODE.txt')
created = []
for index in range(1, len(parts), 2):
    name = parts[index].strip()
    content = parts[index + 1]
    target = (root / name).resolve()
    if root.resolve() not in target.parents and target != root.resolve():
        raise SystemExit('Unsafe output path: ' + name)
    target.parent.mkdir(parents=True, exist_ok=True)
    target.write_text(content, encoding='utf-8', newline='')
    created.append(name)
print('Created or refreshed', len(created), 'project files.')
PY
python3 - <<'PY'
from pathlib import Path
from zipfile import ZipFile, ZIP_DEFLATED
import os, tempfile
root = Path.cwd()
fd, temp_name = tempfile.mkstemp(prefix='linkfolio-', suffix='.zip')
os.close(fd)
try:
    with ZipFile(temp_name, 'w', ZIP_DEFLATED) as archive:
        for folder, directories, files in os.walk(root):
            directories[:] = sorted(d for d in directories if d != '.git' and d != '__pycache__')
            for filename in sorted(files):
                path = Path(folder) / filename
                if path.name == 'LinkFolio.zip' or path.suffix == '.pyc':
                    continue
                archive.write(path, path.relative_to(root).as_posix())
    Path('LinkFolio.zip').unlink(missing_ok=True)
    Path(temp_name).replace(root / 'LinkFolio.zip')
    print('Created LinkFolio.zip')
finally:
    if os.path.exists(temp_name):
        os.remove(temp_name)
PY
