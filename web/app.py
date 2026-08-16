import os
import re
import tempfile

from flask import Flask, jsonify, render_template, request

app = Flask(__name__)

REPO_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ACCELEROMETER_TARGET = '°Accelerometer.cfg'

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


def resolve_accelerometer_file():
    override = os.environ.get('KLIPPER_ACCELEROMETER_FILE')
    if override:
        return override
    dot_copy = os.path.join(REPO_ROOT, '°Accelerometer.cfg')
    if os.path.isfile(dot_copy):
        return dot_copy
    return os.path.join(REPO_ROOT, 'Accelerometer.cfg')


def resolve_path_for(file_key):
    if file_key == 'accelerometer':
        return resolve_accelerometer_file()
    return resolve_config_file()


def read_include_block(lines, include_lineno):
    """Scan upward from include_lineno for an optional marker block:

        ## 3                       (order, optional)
        ## Name: Custom title      (title override, optional)
        ## Section: Other Section  (moves this item into a named section, optional)
        ## Description: EN text    (or a plain comment as fallback)
        ## IT: IT text             (optional)
        [include ...]

    Returns (order, name, section, description_en, description_it,
    block_start) where block_start is the index of the topmost consumed
    line (== include_lineno if nothing above it was part of the block).
    """
    order = None
    name = None
    section = None
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
        if text[:8].lower() == 'section:':
            section = text[8:].strip()
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

    return order, name, section, en, it, block_start


def render_include_block(order, name, section, description_en, description_it):
    block = []
    if order is not None:
        block.append(f'## {order}\n')
    if name:
        block.append(f'## Name: {name}\n')
    if section:
        block.append(f'## Section: {section}\n')
    if description_en:
        block.append(f'## Description: {description_en}\n')
    if description_it:
        block.append(f'## IT: {description_it}\n')
    return block


def label_from_target(target):
    base = os.path.basename(target)
    base = re.sub(r'\.cfg$', '', base, flags=re.IGNORECASE)
    return base.replace('_', ' ').replace('-', ' ').strip().title()


def slugify(text):
    key = re.sub(r'[^a-z0-9]+', '_', text.strip().lower()).strip('_')
    return key or 'section'


# Each marker is matched against a single stripped line; the first one found
# (top to bottom) starts a new section that runs until the next marker.
# Mirrors the ASCII-art banners that already separate advanced_macro.cfg into
# sections, so a section here always matches one there. A "## N - Name" (+
# optional "## IT: ...") line placed right after one of these markers
# overrides that section's order/name; placed anywhere else, it instead
# declares a brand new "virtual" section (see resolve_sections()) that
# includes can be moved into with a "## Section: Name" marker of their own,
# regardless of where they physically sit in the file.
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
    """Base section list (key, anchor_line, order, label_en, label_it) from
    the fixed ASCII-art banners, then apply any "## N - Name" / "## IT: ..."
    marker found right after one of those banners as a rename/reorder, or
    register it as a new standalone ("virtual") section otherwise."""
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

    anchor_plus_one = {s['anchor_line'] + 1: s for s in sections}
    virtual_by_key = {}
    for lineno, line in enumerate(lines):
        m = SECTION_OVERRIDE_RE.match(line.strip())
        if not m:
            continue
        order = int(m.group(1))
        label_en = m.group(2).strip()
        label_it = None
        if lineno + 1 < len(lines):
            m_it = SECTION_OVERRIDE_IT_RE.match(lines[lineno + 1].strip())
            if m_it:
                label_it = m_it.group(1).strip()

        owner = anchor_plus_one.get(lineno)
        if owner is not None:
            owner['order'] = order
            owner['label_en'] = label_en
            if label_it is not None:
                owner['label_it'] = label_it
        else:
            key = slugify(label_en)
            virtual_by_key[key] = {
                'key': key,
                'anchor_line': lineno,
                'order': order,
                'label_en': label_en,
                'label_it': label_it if label_it is not None else label_en,
                'virtual': True,
            }

    return sections + list(virtual_by_key.values())


def find_owning_section(sections, item_lineno, section_name):
    """Pick which section an include belongs to: an explicit "## Section:
    Name" marker wins (creating that section on the fly if it doesn't exist
    yet); otherwise fall back to whichever ASCII-art-banner section's anchor
    line is the closest one at or before this include."""
    if section_name:
        key = slugify(section_name)
        for section in sections:
            if section['key'] == key:
                return section
        fallback = {
            'key': key,
            'anchor_line': item_lineno,
            'order': 900_000 + item_lineno,
            'label_en': section_name,
            'label_it': section_name,
            'virtual': True,
        }
        sections.append(fallback)
        return fallback

    current = sections[0]
    for section in sections:
        if section.get('virtual'):
            continue
        if section['anchor_line'] > item_lineno:
            break
        current = section
    return current


def resolve_all_sections(lines):
    """resolve_sections() plus any "virtual" section that only exists so far
    because some include references it with a "## Section: Name" marker,
    without a matching "## N - Name" definition anywhere yet."""
    sections = resolve_sections(lines)
    for lineno, line in enumerate(lines):
        if not INCLUDE_RE.match(line):
            continue
        _, _, section_name, _, _, _ = read_include_block(lines, lineno)
        find_owning_section(sections, lineno, section_name)
    return sections


def parse_includes(path):
    with open(path, encoding='utf-8') as fh:
        lines = fh.readlines()

    sections = resolve_all_sections(lines)

    parsed_items = []
    for lineno, line in enumerate(lines):
        m = INCLUDE_RE.match(line)
        if not m:
            continue
        target = m.group('target').strip()
        enabled = m.group('hash') is None
        order, name, section_name, description_en, description_it, _ = read_include_block(lines, lineno)
        owner = find_owning_section(sections, lineno, section_name)
        parsed_items.append((owner['key'], {
            'line': lineno,
            'target': target,
            'enabled': enabled,
            'title': name or label_from_target(target),
            'order': order,
            'description_en': description_en,
            'description_it': description_it,
        }))

    section_list = [dict(s, items=[]) for s in sorted(sections, key=lambda s: s['order'])]
    by_key = {s['key']: s for s in section_list}
    for key, item in parsed_items:
        by_key[key]['items'].append(item)

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

    cur_order, cur_name, cur_section, cur_en, cur_it, block_start = read_include_block(lines, lineno)

    order = clean_order(payload['order']) if 'order' in payload else cur_order
    name = clean_text(payload['name']) if 'name' in payload else cur_name
    section = clean_text(payload['section']) if 'section' in payload else cur_section
    description_en = clean_text(payload['description_en']) if 'description_en' in payload else cur_en
    description_it = clean_text(payload['description_it']) if 'description_it' in payload else cur_it

    new_block = render_include_block(order, name, section, description_en, description_it)
    new_lines = lines[:block_start] + new_block + lines[lineno:]
    atomic_write(path, new_lines)


def edit_section(path, anchor_line, payload):
    with open(path, encoding='utf-8') as fh:
        lines = fh.readlines()

    if anchor_line < 0 or anchor_line >= len(lines):
        raise ValueError('anchor_line out of range')

    sections = resolve_all_sections(lines)
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


def build_response():
    """Main file's sections, plus (when the °Accelerometer.cfg shortcut is
    enabled) the sections parsed from that separate file spliced in right
    after it, so the page can toggle its includes too without leaving the
    main list."""
    main_path = resolve_config_file()
    main_sections = parse_includes(main_path)
    for section in main_sections:
        section['file'] = 'main'
        for item in section['items']:
            item['file'] = 'main'

    accel_enabled = any(
        item['enabled']
        for section in main_sections
        for item in section['items']
        if item['target'] == ACCELEROMETER_TARGET
    )

    if accel_enabled:
        accel_path = resolve_accelerometer_file()
        if os.path.isfile(accel_path):
            accel_sections = parse_includes(accel_path)
            for section in accel_sections:
                section['key'] = 'accel_' + section['key']
                section['file'] = 'accelerometer'
                for item in section['items']:
                    item['file'] = 'accelerometer'
            insert_at = next(
                (i + 1 for i, s in enumerate(main_sections) if s['key'] == 'setup'),
                0,
            )
            main_sections[insert_at:insert_at] = accel_sections

    return {'config_file': main_path, 'sections': main_sections}


@app.route('/')
def index():
    return render_template('index.html', config_file=resolve_config_file())


@app.route('/api/includes')
def api_includes():
    return jsonify(build_response())


@app.route('/api/includes/toggle', methods=['POST'])
def api_toggle():
    payload = request.get_json(force=True)
    lineno = payload.get('line')
    if not isinstance(lineno, int):
        return jsonify({'error': "'line' must be an integer"}), 400

    path = resolve_path_for(payload.get('file', 'main'))
    try:
        toggle_include(path, lineno)
    except ValueError as e:
        return jsonify({'error': str(e)}), 409

    return jsonify(build_response())


@app.route('/api/include/edit', methods=['POST'])
def api_include_edit():
    payload = request.get_json(force=True)
    lineno = payload.get('line')
    if not isinstance(lineno, int):
        return jsonify({'error': "'line' must be an integer"}), 400

    path = resolve_path_for(payload.get('file', 'main'))
    try:
        edit_include(path, lineno, payload)
    except ValueError as e:
        return jsonify({'error': str(e)}), 409

    return jsonify(build_response())


@app.route('/api/section/edit', methods=['POST'])
def api_section_edit():
    payload = request.get_json(force=True)
    anchor_line = payload.get('anchor_line')
    if not isinstance(anchor_line, int):
        return jsonify({'error': "'anchor_line' must be an integer"}), 400

    path = resolve_path_for(payload.get('file', 'main'))
    try:
        edit_section(path, anchor_line, payload)
    except ValueError as e:
        return jsonify({'error': str(e)}), 409

    return jsonify(build_response())


if __name__ == '__main__':
    port = int(os.environ.get('PORT', 7136))
    app.run(host='0.0.0.0', port=port)
