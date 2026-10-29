"""Build a local, self-contained HTML index for pilot evidence already captured."""
import argparse
import html
from pathlib import Path


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--root', type=Path, default=Path('artifacts/directorio'))
    args = parser.parse_args()
    root = args.root
    cards = []
    labels = {'cattle': 'Bovino', 'goat': 'Caprino', 'sheep': 'Ovino',
              'pig': 'Porcino', 'equine': 'Équido', 'poultry': 'Ave',
              'canine': 'Canino', 'other': 'Otros'}
    for species, label in labels.items():
        for theme in ['light', 'dark']:
            before = f'before/profile-{species}-{theme}.png'
            after = f'after/profile-{species}-{theme}.png'
            if not (root / before).exists() or not (root / after).exists():
                continue
            cards.append(f'''<article data-species="{species}" data-theme="{theme}">
<h2>{label} · {'Claro' if theme == 'light' else 'Oscuro'}</h2>
<div class="pair"><figure><a href="{before}"><img loading="lazy" src="{before}" alt="{label}: antes"></a><figcaption>Antes · 360 dp</figcaption></figure>
<figure><a href="{after}"><img loading="lazy" src="{after}" alt="{label}: después"></a><figcaption>Después · 360 dp</figcaption></figure></div></article>''')
    native = []
    for path in sorted((root / 'android').glob('*.png')):
        label = html.escape(path.stem.replace('-', ' '))
        name = html.escape(path.name, quote=True)
        semantics = (f' · <a href="android/{html.escape(path.stem)}.xml">accesibilidad</a>'
                     if path.with_suffix('.xml').exists() else '')
        native.append(f'<figure><a href="android/{name}"><img loading="lazy" src="android/{name}" alt="{label}"></a><figcaption>{label}{semantics}</figcaption></figure>')
    options = ''.join(f'<option value="{key}">{value}</option>' for key, value in labels.items())
    page = '''<!doctype html><html lang="es"><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>LibretApp · revisión del piloto</title>
<style>:root{font:16px system-ui;color:#17372a;background:#f5f7f4}body{max-width:1200px;margin:auto;padding:24px}h1{font-size:clamp(24px,4vw,40px)}p{line-height:1.6;max-width:85ch}select{font:inherit;padding:12px;border-radius:10px;border:1px solid #8aa391;background:white;margin:0 12px 12px 0}article{background:white;padding:20px;border-radius:18px;margin:24px 0;box-shadow:0 4px 18px #143b1810}h2{margin-top:0}.pair{display:grid;grid-template-columns:1fr 1fr;gap:24px}figure{margin:0}img{display:block;width:100%;height:auto;background:#eee;border:1px solid #ccc;border-radius:8px}figcaption{padding:12px 0;font-weight:600}a{color:#176341}.native{display:grid;grid-template-columns:repeat(auto-fit,minmax(220px,1fr));gap:24px}.native img{max-height:680px;object-fit:contain}article[hidden]{display:none}.tag{display:inline-block;background:#ffe8b0;padding:7px 12px;border-radius:20px}footer{padding:32px 0;border-top:1px solid #bacaba}@media(max-width:600px){body{padding:16px}.pair{gap:12px}article{padding:12px}figcaption{font-size:14px}}</style>
<h1>Directorio atractivo y funcional</h1><span class="tag">Candidato offline · 0.1.1+4</span>
<p>Comparación del perfil original y del perfil implementado para las ocho especies. Se conservaron los desbordamientos del original como evidencia. Estas imágenes de widgets documentan QA; las capturas Android aparecen abajo. Las pruebas manuales pendientes se enumeran en la matriz.</p>
<p><a href="../../docs/piloto/README.md">Informe y aceptación</a> · <a href="../../docs/piloto/directorio-cobertura.csv">Matriz CSV</a> · <a href="../../docs/piloto/hallazgos.md">Hallazgos</a> · <a href="release-verification.json">Verificación del AAB</a></p>
<label>Especie <select id="species"><option value="all">Todas</option>''' + options + '''</select></label><label>Tema <select id="theme"><option value="all">Ambos</option><option value="light">Claro</option><option value="dark">Oscuro</option></select></label>
''' + ''.join(cards) + '''<h2>Capturas reales en Android</h2><p>Los nombres terminados en «final» corresponden al candidato de cierre. «16kb» identifica el segundo emulador con PAGE_SIZE=16384. Las capturas intermedias documentan recorridos y defectos encontrados.</p><div class="native">''' + ''.join(native) + '''</div><footer>La evidencia contiene únicamente el escenario ficticio demo. Se mantiene local y excluida de Git.</footer>
<script>const selects=[document.querySelector('#species'),document.querySelector('#theme')];function update(){for(const card of document.querySelectorAll('article'))card.hidden=(selects[0].value!=='all'&&card.dataset.species!==selects[0].value)||(selects[1].value!=='all'&&card.dataset.theme!==selects[1].value)}for(const select of selects)select.addEventListener('change',update);</script></html>'''
    root.mkdir(parents=True, exist_ok=True)
    (root / 'index.html').write_text(page, encoding='utf-8')
    print(f'Gallery: {len(cards)} comparisons, {len(native)} Android captures')


if __name__ == '__main__':
    main()
