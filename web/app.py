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


def label_from_comment(lines, include_lineno):
    i = include_lineno - 1
    while i >= 0:
        stripped = lines[i].strip()
        if not stripped:
            i -= 1
            continue
        if stripped.startswith('#'):
            text = stripped.lstrip('#').strip()
            if text.startswith('IT:'):
                i -= 1
                continue
            return text
        break
    return None


def label_from_target(target):
    base = os.path.basename(target)
    base = re.sub(r'\.cfg$', '', base, flags=re.IGNORECASE)
    return base.replace('_', ' ').replace('-', ' ').strip().title()


def parse_includes(path):
    with open(path, encoding='utf-8') as fh:
        lines = fh.readlines()

    includes = []
    for lineno, line in enumerate(lines):
        m = INCLUDE_RE.match(line)
        if not m:
            continue
        target = m.group('target').strip()
        enabled = m.group('hash') is None
        includes.append({
            'line': lineno,
            'target': target,
            'enabled': enabled,
            'title': label_from_target(target),
            'description': label_from_comment(lines, lineno),
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
