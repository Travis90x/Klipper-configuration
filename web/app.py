import os
import re
import tempfile

from flask import Flask, jsonify, render_template, request

app = Flask(__name__)

REPO_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

INCLUDE_RE = re.compile(
    r'^(?P<indent>\s*)(?P<hash>#\s*)?\[include\s+(?P<target>[^\]]+)\]\s*(?P<trailing>#.*)?\s*$'
)
ORDER_RE = re.compile(r'^##\s*(\d+)\s*$')
SECTION_OVERRIDE_RE = re.compile(r'^##\s*(\d+)\s*-\s*(.+)$')
SECTION_OVERRIDE_IT_RE = re.compile(r'^##\s*IT:\s*(.+)$', re.IGNORECASE)


def resolve_config_file():
    override = os.environ.get('KLIPPER_CONFIG_MANAGER_FILE')
    if override:
        return override
    adv_copy = os.path.join(REPO_ROOT, '°ADV_macro.cfg')
    if os.path.isfile(adv_copy):
        return adv_copy
    return os.path.join(REPO_ROOT, 'advanced_macro.cfg')


def read_include_block(lines, include_lineno):
    """Scan upward from include_lineno for an optional marker block:

        ## 3                       (order, optional)
        ## Name: Custom title      (title override, optional)
        ## Description: EN text    (or a plain comment as fallback)
        ## IT: IT text             (optional)
        [include ...]

    Returns (order, name, description_en, description_it, block_start) where
    block_start is the index of the topmost consumed line (== include_lineno
    if nothing above it was part of the block).
    """
    order = None
    name = None
    it = None
    en = None
    have_en = False
    block_start = include_lineno
    i = include_lineno - 1
    while i >= 0:
        stripped = lines[i].strip()
        if not stripped:
            i -= 1
            continue
        if not stripped.startswith('#'):
            break

        m = ORDER_RE.match(stripped)
        if m:
            order = int(m.group(1))
            block_start = i
            i -= 1
            continue

        text = stripped.lstrip('#').strip()
        if text[:3].upper() == 'IT:':
            it = text[3:].strip()
            block_start = i
            i -= 1
            continue
        if text[:5].lower() == 'name:':
            name = text[5:].strip()
            block_start = i
            i -= 1
            continue
        if text[:12].lower() == 'description:' and not have_en:
            en = text[12:].strip()
            have_en = True
            block_start = i
            i -= 1
            continue
        if not have_en and en is None:
            en = text
            block_start = i
        break

    return order, name, en, it, block_start


def render_include_block(order, name, description_en, description_it):
    block = []
    if order is not None:
        block.append(f'## {order}\n')
    if name:
        block.append(f'## Name: {name}\n')
    if description_en:
        block.append(f'## Description: {description_en}\n')
    if description_it:
        block.append(f'## IT: {description_it}\n')
    return block


def label_from_target(target):
    base = os.path.basename(target)
    base = re.sub(r'\.cfg$', '', base, flags=re.IGNORECASE)
    return base.replace('_', ' ').replace('-', ' ').strip().title()


# Each marker is matched against a single stripped line; the first one found
# (top to bottom) starts a new section that runs until the next marker.
# Mirrors the ASCII-art banners that already separate advanced_macro.cfg into
# sections, so a section here always matches one there. A "## N - Name" (+
# optional "## IT: ...") line placed right after one of these markers
# overrides that section's order/name — see resolve_sections().
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


def resolve_sections(lines):
    """Base section list (key, anchor_line, order, label_en, label_it),
    ordered by anchor_line, then apply any "## N - Name" / "## IT: ..."
    overrides found in the file on top of it."""
    sections = [{
        'key': 'setup',
        'anchor_line': 0,
        'order': 0,
        'label_en': 'Setup',
        'label_it': 'Impostazioni',
    }]
    for lineno, line in enumerate(lines):
        stripped = line.strip()
        for pattern, key, label_en, label_it in SECTION_MARKERS:
            if pattern.match(stripped):
                sections.append({
                    'key': key,
                    'anchor_line': lineno,
                    'order': len(sections),
                    'label_en': label_en,
                    'label_it': label_it,
                })
                break

    for lineno, line in enumerate(lines):
        m = SECTION_OVERRIDE_RE.match(line.strip())
        if not m:
            continue
        owner = None
        for section in sections:
            if section['anchor_line'] <= lineno:
                owner = section
            else:
                break
        if owner is None:
            continue
        owner['order'] = int(m.group(1))
        owner['label_en'] = m.group(2).strip()
        if lineno + 1 < len(lines):
            m_it = SECTION_OVERRIDE_IT_RE.match(lines[lineno + 1].strip())
            if m_it:
                owner['label_it'] = m_it.group(1).strip()

    return sections


def section_for_line(sections, lineno):
    current = sections[0]
    for section in sections:
        if section['anchor_line'] > lineno:
            break
        current = section
    return current


def parse_includes(path):
    with open(path, encoding='utf-8') as fh:
        lines = fh.readlines()

    sections = resolve_sections(lines)
    section_list = [dict(s, items=[]) for s in sorted(sections, key=lambda s: s['order'])]
    by_key = {s['key']: s for s in section_list}

    for lineno, line in enumerate(lines):
        m = INCLUDE_RE.match(line)
        if not m:
            continue
        target = m.group('target').strip()
        enabled = m.group('hash') is None
        order, name, description_en, description_it, _ = read_include_block(lines, lineno)
        section = section_for_line(sections, lineno)
        by_key[section['key']]['items'].append({
            'line': lineno,
            'target': target,
            'enabled': enabled,
            'title': name or label_from_target(target),
            'order': order,
            'description_en': description_en,
            'description_it': description_it,
        })

    for section in section_list:
        section['items'].sort(key=lambda item: (
            item['order'] if item['order'] is not None else 1_000_000,
            item['line'],
        ))

    return [s for s in section_list if s['items']]


def atomic_write(path, lines):
    dir_name = os.path.dirname(os.path.abspath(path)) or '.'
    fd, tmp_path = tempfile.mkstemp(dir=dir_name, prefix='.config-manager-')
    try:
        with os.fdopen(fd, 'w', encoding='utf-8') as fh:
            fh.writelines(lines)
        os.replace(tmp_path, path)
    except Exception:
        os.unlink(tmp_path)
        raise


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

    atomic_write(path, lines)


def clean_text(value):
    if value is None:
        return None
    value = value.replace('\r', ' ').replace('\n', ' ').strip()
    return value or None


def clean_order(value):
    if value is None or value == '':
        return None
    try:
        return int(value)
    except (TypeError, ValueError):
        raise ValueError("'order' must be an integer or null")


def edit_include(path, lineno, payload):
    with open(path, encoding='utf-8') as fh:
        lines = fh.readlines()

    if lineno < 0 or lineno >= len(lines) or not INCLUDE_RE.match(lines[lineno]):
        raise ValueError('line is not an [include ...] line anymore')

    cur_order, cur_name, cur_en, cur_it, block_start = read_include_block(lines, lineno)

    order = clean_order(payload['order']) if 'order' in payload else cur_order
    name = clean_text(payload['name']) if 'name' in payload else cur_name
    description_en = clean_text(payload['description_en']) if 'description_en' in payload else cur_en
    description_it = clean_text(payload['description_it']) if 'description_it' in payload else cur_it

    new_block = render_include_block(order, name, description_en, description_it)
    new_lines = lines[:block_start] + new_block + lines[lineno:]
    atomic_write(path, new_lines)


def edit_section(path, anchor_line, payload):
    with open(path, encoding='utf-8') as fh:
        lines = fh.readlines()

    if anchor_line < 0 or anchor_line >= len(lines):
        raise ValueError('anchor_line out of range')

    sections = resolve_sections(lines)
    current = next((s for s in sections if s['anchor_line'] == anchor_line), None)
    if current is None:
        raise ValueError('no section at anchor_line anymore')

    order = clean_order(payload['order']) if 'order' in payload else current['order']
    if order is None:
        raise ValueError("'order' is required for a section")
    label_en = clean_text(payload.get('label_en')) or current['label_en']
    label_it = clean_text(payload.get('label_it')) if 'label_it' in payload else current['label_it']

    insert_at = anchor_line + 1
    existing_span = 0
    if insert_at < len(lines) and SECTION_OVERRIDE_RE.match(lines[insert_at].strip()):
        existing_span = 1
        if insert_at + 1 < len(lines) and SECTION_OVERRIDE_IT_RE.match(lines[insert_at + 1].strip()):
            existing_span = 2

    new_block = [f'## {order} - {label_en}\n']
    if label_it:
        new_block.append(f'## IT: {label_it}\n')

    new_lines = lines[:insert_at] + new_block + lines[insert_at + existing_span:]
    atomic_write(path, new_lines)


@app.route('/')
def index():
    return render_template('index.html', config_file=resolve_config_file())


@app.route('/api/includes')
def api_includes():
    path = resolve_config_file()
    return jsonify({'config_file': path, 'sections': parse_includes(path)})


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

    return jsonify({'config_file': path, 'sections': parse_includes(path)})


@app.route('/api/include/edit', methods=['POST'])
def api_include_edit():
    payload = request.get_json(force=True)
    lineno = payload.get('line')
    if not isinstance(lineno, int):
        return jsonify({'error': "'line' must be an integer"}), 400

    path = resolve_config_file()
    try:
        edit_include(path, lineno, payload)
    except ValueError as e:
        return jsonify({'error': str(e)}), 409

    return jsonify({'config_file': path, 'sections': parse_includes(path)})


@app.route('/api/section/edit', methods=['POST'])
def api_section_edit():
    payload = request.get_json(force=True)
    anchor_line = payload.get('anchor_line')
    if not isinstance(anchor_line, int):
        return jsonify({'error': "'anchor_line' must be an integer"}), 400

    path = resolve_config_file()
    try:
        edit_section(path, anchor_line, payload)
    except ValueError as e:
        return jsonify({'error': str(e)}), 409

    return jsonify({'config_file': path, 'sections': parse_includes(path)})


if __name__ == '__main__':
    port = int(os.environ.get('PORT', 7136))
    app.run(host='0.0.0.0', port=port)
