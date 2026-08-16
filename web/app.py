import os
import re
import tempfile

from flask import Flask, jsonify, render_template, request

app = Flask(__name__)

REPO_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

INCLUDE_RE = re.compile(
    r'^(?P<indent>\s*)(?P<hash>#\s*)?\[include\s+(?P<target>[^\]]+)\]\s*(?P<trailing>#.*)?\s*$'
)


def resolve_config_file():
    override = os.environ.get('KLIPPER_CONFIG_MANAGER_FILE')
    if override:
        return override
    adv_copy = os.path.join(REPO_ROOT, '°ADV_macro.cfg')
    if os.path.isfile(adv_copy):
        return adv_copy
    return os.path.join(REPO_ROOT, 'advanced_macro.cfg')


def descriptions_from_comment(lines, include_lineno):
    it = None
    i = include_lineno - 1
    while i >= 0:
        stripped = lines[i].strip()
        if not stripped:
            i -= 1
            continue
        if not stripped.startswith('#'):
            break
        text = stripped.lstrip('#').strip()
        if text[:3].upper() == 'IT:':
            it = text[3:].strip()
            i -= 1
            continue
        if text[:12].lower() == 'description:':
            return text[12:].strip(), it
        return text, it
    return None, it


def label_from_target(target):
    base = os.path.basename(target)
    base = re.sub(r'\.cfg$', '', base, flags=re.IGNORECASE)
    return base.replace('_', ' ').replace('-', ' ').strip().title()


# Each marker is matched against a single stripped line; the first one found
# (top to bottom) starts a new section that runs until the next marker.
# Mirrors the ASCII-art banners that already separate advanced_macro.cfg into
# sections, so a section here always matches one there.
SECTION_MARKERS = [
    (re.compile(r'^#?\s*\[include\s+mainsail\.cfg\]$'), 'mainsail', 'Mainsail', 'Mainsail'),
    (re.compile(r'^\[gcode_macro _MACRO_VARIABLE\]$'), 'macros', 'Macros', 'Macro'),
    (re.compile(r'^#\s*KAMP$'), 'kamp', 'KAMP', 'KAMP'),
    (re.compile(r'^#\s*FANS$'), 'fans', 'Fans', 'Ventole'),
    (re.compile(r'^#\s*PROBE$'), 'probe', 'Probe', 'Sonda'),
    (re.compile(r'^#\s*mcu$'), 'mcu', 'MCU', 'MCU'),
    (re.compile(r'^#\s*INPUT SHAPING$'), 'input_shaping', 'Input Shaping & Accelerometer', 'Input Shaping e Accelerometro'),
    (re.compile(r'^#\s*Filament Runout or Encoder$'), 'filament', 'Filament (Load / Unload / Purge)', 'Filamento (Carico / Scarico / Spurgo)'),
    (re.compile(r'^#+\s*END - FILAMENT MACRO - END\s*#+$'), 'cutter', 'Cutter', 'Taglierina'),
    (re.compile(r'^#\s*LED$'), 'led', 'LED', 'LED'),
    (re.compile(r'^#\s*NEOPIXEL$'), 'neopixel', 'Neopixel & LED Effects', 'Neopixel ed Effetti LED'),
    (re.compile(r'^#\s*Only for MKS Robin Nano 1\.2$'), 'robin_nano', 'MKS Robin Nano 1.2', 'MKS Robin Nano 1.2'),
]
DEFAULT_SECTION = ('setup', 'Setup', 'Impostazioni')


def find_section_boundaries(lines):
    boundaries = []
    for lineno, line in enumerate(lines):
        stripped = line.strip()
        for pattern, key, label_en, label_it in SECTION_MARKERS:
            if pattern.match(stripped):
                boundaries.append((lineno, key, label_en, label_it))
                break
    return boundaries


def section_for_line(boundaries, lineno):
    current = DEFAULT_SECTION
    for boundary_lineno, key, label_en, label_it in boundaries:
        if boundary_lineno > lineno:
            break
        current = (key, label_en, label_it)
    return current


def parse_includes(path):
    with open(path, encoding='utf-8') as fh:
        lines = fh.readlines()

    boundaries = find_section_boundaries(lines)

    includes = []
    for lineno, line in enumerate(lines):
        m = INCLUDE_RE.match(line)
        if not m:
            continue
        target = m.group('target').strip()
        enabled = m.group('hash') is None
        description_en, description_it = descriptions_from_comment(lines, lineno)
        section, section_en, section_it = section_for_line(boundaries, lineno)
        includes.append({
            'line': lineno,
            'target': target,
            'enabled': enabled,
            'title': label_from_target(target),
            'description_en': description_en,
            'description_it': description_it,
            'section': section,
            'section_en': section_en,
            'section_it': section_it,
        })
    return includes


def toggle_include(path, lineno):
    with open(path, encoding='utf-8') as fh:
        lines = fh.readlines()

    if lineno < 0 or lineno >= len(lines):
        raise ValueError('line out of range')

    m = INCLUDE_RE.match(lines[lineno])
    if not m:
        raise ValueError('line is not an [include ...] line anymore')

    if m.group('hash') is None:
        lines[lineno] = m.group('indent') + '#' + lines[lineno][len(m.group('indent')):]
    else:
        lines[lineno] = m.group('indent') + lines[lineno][len(m.group('indent')) + len(m.group('hash')):]

    dir_name = os.path.dirname(os.path.abspath(path)) or '.'
    fd, tmp_path = tempfile.mkstemp(dir=dir_name, prefix='.config-manager-')
    try:
        with os.fdopen(fd, 'w', encoding='utf-8') as fh:
            fh.writelines(lines)
        os.replace(tmp_path, path)
    except Exception:
        os.unlink(tmp_path)
        raise


@app.route('/')
def index():
    return render_template('index.html', config_file=resolve_config_file())


@app.route('/api/includes')
def api_includes():
    path = resolve_config_file()
    return jsonify({'config_file': path, 'includes': parse_includes(path)})


@app.route('/api/includes/toggle', methods=['POST'])
def api_toggle():
    payload = request.get_json(force=True)
    lineno = payload.get('line')
    if not isinstance(lineno, int):
        return jsonify({'error': "'line' must be an integer"}), 400

    path = resolve_config_file()
    try:
        toggle_include(path, lineno)
    except ValueError as e:
        return jsonify({'error': str(e)}), 409

    return jsonify({'config_file': path, 'includes': parse_includes(path)})


if __name__ == '__main__':
    port = int(os.environ.get('PORT', 7136))
    app.run(host='0.0.0.0', port=port)
