"""Generate LibretApp's flat 2D icon source set.

The animals and the location family are deliberately excluded.  The generated
SVGs are the editable source of the bundled 256px WEBP assets.
"""

from pathlib import Path

OUT = Path(__file__).resolve().parents[1] / "assets" / "icons_2d"

P = {
    "green": "#547663",
    "green_dark": "#345848",
    "terra": "#C66B45",
    "gold": "#DAA54A",
    "cream": "#EAD8B8",
    "paper": "#FFF5DF",
    "blue": "#7E9DA2",
    "muted": "#90A18A",
    "ink": "#263E33",
}


def svg(title: str, body: str) -> str:
    return (
        '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 128 128" '
        'fill="none">'
        f"<title>{title}</title>{body}</svg>\n"
    )


def line(x1: int, y1: int, x2: int, y2: int, color: str, width: int = 5) -> str:
    return (
        f'<path d="M{x1} {y1}L{x2} {y2}" stroke="{color}" '
        f'stroke-width="{width}" stroke-linecap="round"/>'
    )


def rect(x: int, y: int, w: int, h: int, color: str, r: int = 0) -> str:
    radius = f' rx="{r}"' if r else ""
    return f'<rect x="{x}" y="{y}" width="{w}" height="{h}"{radius} fill="{color}"/>'


def circle(cx: int, cy: int, r: int, color: str) -> str:
    return f'<circle cx="{cx}" cy="{cy}" r="{r}" fill="{color}"/>'


def icon_bodies() -> dict[str, str]:
    g, gd, t, y, c, p, b, m, ink = (
        P[k] for k in ("green", "green_dark", "terra", "gold", "cream", "paper", "blue", "muted", "ink")
    )
    return {
        # Inventory and finance.
        "inventory_feed": svg("Alimento", rect(31, 33, 66, 74, c, 10) + rect(38, 25, 52, 16, g, 6) +
            f'<path d="M42 48h44v48H42z" fill="{p}"/>' +
            f'<path d="M53 70c9-15 18-15 27 0-9 14-18 14-27 0" fill="{y}"/>' +
            line(52, 82, 77, 58, g, 4)),
        "inventory_medicine": svg("Medicamento", rect(38, 43, 52, 62, y, 10) + rect(45, 30, 38, 18, g, 5) +
            rect(52, 67, 24, 8, p, 3) + rect(60, 59, 8, 24, p, 3) + circle(64, 94, 5, t)),
        "inventory_tool": svg("Herramienta", f'<path d="M38 28a22 22 0 0 0 21 29L28 88a9 9 0 0 0 13 13l31-31a22 22 0 0 0 28-28L84 55l-12-12 13-13a22 22 0 0 0-22 5l-8 8-10-10z" fill="{g}"/>' + circle(34, 95, 7, t)),
        "inventory_low_stock": svg("Existencia baja", rect(23, 42, 82, 60, c, 8) + line(23, 60, 105, 60, g, 5) +
            line(64, 25, 64, 48, t, 7) + f'<path d="m52 38 12 13 12-13" stroke="{t}" stroke-width="7" stroke-linecap="round" stroke-linejoin="round"/>'),
        "inventory_income": svg("Ingreso", circle(59, 70, 34, y) + circle(59, 70, 25, p) +
            line(59, 84, 59, 56, g, 6) + f'<path d="m48 66 11-12 11 12" stroke="{g}" stroke-width="6" stroke-linecap="round" stroke-linejoin="round"/>'),
        "inventory_expense": svg("Gasto", rect(28, 20, 57, 83, c, 6) + line(40, 46, 71, 46, g, 5) + line(40, 60, 65, 60, g, 5) +
            line(56, 85, 56, 61, t, 6) + f'<path d="m45 76 11 12 11-12" stroke="{t}" stroke-width="6" stroke-linecap="round" stroke-linejoin="round"/>'),
        "inventory_sale": svg("Venta", rect(18, 45, 92, 58, c, 8) + f'<path d="m15 45 10-22h78l10 22z" fill="{t}"/>' +
            rect(29, 62, 23, 41, p, 3) + rect(61, 67, 33, 22, g, 4) + circle(69, 99, 6, g) + circle(88, 99, 6, g)),
        "inventory_profitability": svg("Rentabilidad", rect(21, 87, 18, 19, b, 4) + rect(48, 66, 18, 40, g, 4) + rect(75, 42, 18, 64, y, 4) +
            line(17, 108, 102, 108, ink, 5) + f'<path d="m22 62 20-18 20 12 27-31" stroke="{t}" stroke-width="6" stroke-linecap="round" stroke-linejoin="round"/>' + f'<path d="m82 25h9v9" stroke="{t}" stroke-width="6" stroke-linecap="round" stroke-linejoin="round"/>'),
        # Records.
        "record_production": svg("Producción", rect(23, 70, 18, 38, b, 4) + rect(51, 48, 18, 60, g, 4) + rect(79, 31, 18, 77, y, 4) +
            f'<path d="M26 43c12-21 31-12 39-27 6 13 19 16 37 8" stroke="{t}" stroke-width="6" stroke-linecap="round" stroke-linejoin="round"/>' + f'<path d="m92 22 10 2-4 10" stroke="{t}" stroke-width="6" stroke-linecap="round" stroke-linejoin="round"/>'),
        "record_movement": svg("Movimiento", f'<path d="M75 18a5 5 0 0 1 9-3l27 26a7 7 0 0 1 0 10L84 77a5 5 0 0 1-9-3V58H32a9 9 0 0 1-9-9v-6a9 9 0 0 1 9-9h43z" fill="{g}"/>' + f'<path d="M48 57a5 5 0 0 0-9-3L14 79a7 7 0 0 0 0 10l25 25a5 5 0 0 0 9-3V97h49a9 9 0 0 0 9-9v-6a9 9 0 0 0-9-9H48z" fill="{t}"/>'),
        "record_cost": svg("Costo", rect(21, 16, 63, 94, c, 5) + line(35, 43, 69, 43, g, 5) + line(35, 57, 62, 57, g, 5) + line(35, 71, 53, 71, g, 5) + circle(91, 86, 26, y) + circle(91, 86, 17, p) + line(83, 86, 99, 86, t, 5)),
        "record_sale": svg("Comercial", rect(18, 50, 92, 57, c, 7) + f'<path d="m14 50 11-26h78l11 26z" fill="{t}"/>' + rect(29, 65, 24, 42, p, 3) + rect(61, 70, 32, 24, g, 4) + circle(68, 102, 6, g) + circle(88, 102, 6, g)),
        "record_reproduction": svg("Reproducción", f'<path d="M64 106 55 96C28 72 20 58 25 42c5-16 26-19 39-4 13-15 34-12 39 4 5 16-3 30-30 54z" fill="{t}"/>' + f'<path d="M64 81c-9-9-14-16-14-24 0-6 5-11 11-11 4 0 7 2 9 6 2-4 5-6 9-6 6 0 11 5 11 11 0 8-7 15-16 24z" fill="{p}"/>'),
        "record_service": svg("Servicio", f'<path d="M38 28a22 22 0 0 0 20 31L28 89a9 9 0 0 0 13 13l31-31a22 22 0 0 0 28-28l-16 12-12-12 13-13a22 22 0 0 0-22 5l-8 8-10-10z" fill="{g}"/>' + circle(92, 89, 18, y) + circle(92, 89, 8, p) + f'<path d="M92 64v8M92 106v8M67 89h8M109 89h8" stroke="{y}" stroke-width="5" stroke-linecap="round"/>'),
        # Crops.
        "crop_field": svg("Campo", f'<path d="M15 84c18-19 35-26 49-26s31 7 49 26v27H15z" fill="{g}"/>' + f'<path d="M25 91c14-11 26-15 39-15s25 4 39 15M25 103c14-9 26-13 39-13s25 4 39 13" stroke="{p}" stroke-width="5" stroke-linecap="round"/>' + line(64, 59, 64, 35, t, 5) + f'<path d="M64 47c-13-4-18-11-18-18 12-1 18 5 18 18M64 42c13-4 18-11 18-18-12-1-18 5-18 18" fill="{y}"/>'),
        "crop_germinating": svg("Germinando", f'<path d="M18 92h92" stroke="{g}" stroke-width="8" stroke-linecap="round"/>' + f'<path d="M64 91V66c0-12 8-22 20-25 2 13-6 25-20 25M64 77c0-11-8-20-20-23-2 12 6 22 20 23" fill="{y}"/>' + circle(64, 98, 11, c)),
        "crop_vegetative": svg("Crecimiento", f'<path d="M64 109V53" stroke="{g}" stroke-width="8" stroke-linecap="round"/>' + f'<path d="M64 77C45 76 33 67 31 52c17-2 29 7 33 25M64 67c4-18 16-28 33-26-2 15-14 24-33 26M64 91C48 90 38 83 35 71c14-1 24 6 29 20M64 87c5-16 15-24 29-23-3 13-13 21-29 23" fill="{g}"/>'),
        "crop_flowering": svg("Floración", line(64, 107, 64, 58, g, 7) + f'<path d="M64 68c-20 0-30-9-29-23 13-1 24 5 29 18 5-13 16-19 29-18 1 14-9 23-29 23z" fill="{g}"/>' + circle(64, 42, 12, y) + circle(47, 34, 11, t) + circle(81, 34, 11, t) + circle(51, 51, 11, t) + circle(77, 51, 11, t)),
        "crop_fruiting": svg("Fructificación", line(64, 108, 64, 43, g, 7) + f'<path d="M64 54c-15-14-29-13-37-3 12 13 24 14 37 3M64 66c15-14 29-13 37-3-12 13-24 14-37 3" fill="{g}"/>' + circle(46, 75, 13, t) + circle(83, 84, 13, y) + circle(58, 92, 12, t)),
        "crop_ready_to_harvest": svg("Listo para cosecha", f'<path d="M26 80c13-20 27-29 38-29s25 9 38 29v27H26z" fill="{y}"/>' + f'<path d="m23 80 41-29 41 29" stroke="{g}" stroke-width="7" stroke-linecap="round" stroke-linejoin="round"/>' + line(64, 51, 64, 31, g, 5) + f'<path d="M64 40c-11-4-16-10-15-17 10 0 16 6 15 17M64 39c11-4 16-10 15-17-10 0-16 6-15 17" fill="{g}"/>'),
        "crop_harvested": svg("Cosechado", rect(25, 55, 78, 53, c, 7) + f'<path d="m25 55 9-23h60l9 23z" fill="{t}"/>' + f'<path d="M43 47c6-18 13-23 21-30 8 7 15 12 21 30z" fill="{y}"/>' + line(47, 72, 81, 72, g, 5) + line(47, 87, 75, 87, g, 5)),
        "crop_failed": svg("Cultivo fallido", f'<path d="M64 108V43" stroke="{g}" stroke-width="7" stroke-linecap="round"/>' + f'<path d="M64 66C45 63 34 53 35 40c16 1 26 9 29 26M64 78c-16-2-27-10-29-22 15 0 25 7 29 22M64 58c11-12 22-16 34-11-6 12-17 16-34 11" fill="{g}"/>' + f'<path d="m30 30 68 68M98 30 30 98" stroke="{t}" stroke-width="8" stroke-linecap="round"/>'),
        # Agenda tasks.
        "task_milking": svg("Ordeña", rect(37, 35, 54, 72, b, 12) + rect(31, 25, 66, 16, g, 6) + f'<path d="M64 53c-10 15-21 25-21 36a21 21 0 0 0 42 0c0-11-11-21-21-36" fill="{p}"/>'),
        "task_tick_bath": svg("Baño garrapaticida", circle(48, 71, 29, b) + f'<path d="M29 72c13-12 28-12 39 0-11 12-26 12-39 0" fill="{p}"/>' + circle(89, 51, 8, t) + line(89, 61, 89, 87, t, 5) + line(80, 73, 98, 73, t, 5) + circle(82, 97, 4, y) + circle(101, 97, 4, y)),
        "task_vitamins": svg("Vitaminas", rect(25, 49, 78, 34, c, 17) + f'<path d="M64 49v34" stroke="{g}" stroke-width="5"/>' + circle(43, 66, 8, y) + circle(85, 66, 8, t) + f'<path d="M38 66h10M80 66h10" stroke="{p}" stroke-width="4" stroke-linecap="round"/>'),
        "task_hoof_check": svg("Revisión de casco", f'<path d="M39 32c-4 16-10 33-7 49 3 19 17 28 32 28s29-9 32-28c3-16-3-33-7-49-4-13-17-12-22-3-5-9-18-10-28 3" fill="{g}"/>' + f'<path d="M46 61h36M45 74h38M50 87h28" stroke="{p}" stroke-width="5" stroke-linecap="round"/>'),
        "task_reproductive_check": svg("Chequeo reproductivo", f'<path d="M64 109 55 99C29 76 20 61 25 45c5-16 25-19 39-4 14-15 34-12 39 4 5 16-4 31-30 54z" fill="{t}"/>' + circle(64, 63, 15, p) + f'<path d="m55 63 7 7 14-16" stroke="{g}" stroke-width="6" stroke-linecap="round" stroke-linejoin="round"/>'),
        "task_fertilization": svg("Fertilización", f'<path d="M20 94c24-8 64-8 88 0v14H20z" fill="{c}"/>' + line(64, 91, 64, 47, g, 6) + f'<path d="M64 61C51 58 45 49 47 38c11 1 17 8 17 23M64 54c8-14 18-19 29-16-3 12-13 17-29 16" fill="{g}"/>' + circle(64, 105, 5, y)),
        "task_fumigation": svg("Fumigación", rect(21, 65, 45, 40, y, 8) + rect(29, 53, 29, 16, g, 5) + f'<path d="M66 79h19l18-25" stroke="{g}" stroke-width="7" stroke-linecap="round" stroke-linejoin="round"/>' + f'<path d="M92 35c9 7 12 15 9 25M103 31c10 9 12 19 8 31" stroke="{b}" stroke-width="6" stroke-linecap="round"/>' + circle(43, 86, 7, p)),
        "task_harvest": svg("Cosecha", f'<path d="M25 100c27-17 47-22 78-4" stroke="{g}" stroke-width="8" stroke-linecap="round"/>' + f'<path d="m29 90 56-57" stroke="{t}" stroke-width="9" stroke-linecap="round"/>' + f'<path d="M84 32c17-1 25 8 24 24-16 2-25-6-24-24z" fill="{y}"/>' + f'<path d="M45 98c-4-21 3-36 19-47 7 17 2 32-19 47z" fill="{g}"/>'),
        "task_deworming": svg("Desparasitación", rect(22, 53, 84, 25, c, 12) + f'<path d="M64 53v25" stroke="{g}" stroke-width="5"/>' + f'<path d="M35 67c6-8 12 8 18 0s12 8 18 0 12 8 18 0" stroke="{t}" stroke-width="5" stroke-linecap="round"/>' + circle(31, 65, 5, y) + circle(97, 65, 5, b)),
        "task_annual_vaccination": svg("Vacunación anual", rect(35, 44, 35, 61, y, 8) + rect(40, 31, 25, 16, g, 5) + rect(44, 68, 17, 9, p, 3) + f'<g transform="rotate(31 87 66)"><path d="M77 40h20v43a9 9 0 0 1-9 9h-2a9 9 0 0 1-9-9z" fill="{b}"/><path d="M82 43h10v35H82z" fill="{p}"/><path d="M87 22v18M78 20h18M74 41h26" stroke="{g}" stroke-width="6" stroke-linecap="round"/><path d="M87 92v17" stroke="{g}" stroke-width="3" stroke-linecap="round"/></g>'),
        # Operational states.
        "status_pending": svg("Pendiente", circle(64, 64, 40, c) + f'<circle cx="64" cy="64" r="28" stroke="{g}" stroke-width="7"/>' + line(64, 64, 64, 48, t, 6) + line(64, 64, 77, 72, t, 6)),
        "status_completed": svg("Completado", circle(64, 64, 42, g) + f'<path d="m40 65 16 16 33-36" stroke="{p}" stroke-width="9" stroke-linecap="round" stroke-linejoin="round"/>'),
        "status_overdue": svg("Vencido", rect(24, 30, 80, 78, c, 10) + rect(24, 30, 80, 23, t, 10) + line(43, 19, 43, 38, g, 7) + line(85, 19, 85, 38, g, 7) + line(64, 66, 64, 83, t, 7) + circle(64, 96, 4, t)),
        "status_in_progress": svg("En progreso", circle(64, 64, 39, c) + f'<path d="M64 25a39 39 0 0 1 35 22" stroke="{g}" stroke-width="9" stroke-linecap="round"/>' + f'<path d="M99 64a35 35 0 0 1-18 31" stroke="{t}" stroke-width="9" stroke-linecap="round"/>' + circle(64, 64, 10, y)),
        "status_canceled": svg("Cancelado", circle(64, 64, 41, t) + line(45, 45, 83, 83, p, 9) + line(83, 45, 45, 83, p, 9)),
        "status_critical": svg("Crítico", f'<path d="m64 15 49 92H15z" fill="{t}"/>' + line(64, 44, 64, 73, p, 8) + circle(64, 91, 5, p)),
        "status_quarantine": svg("Cuarentena", f'<path d="M19 49h90v57H19z" fill="{c}"/>' + line(19, 62, 109, 62, g, 6) + line(35, 49, 35, 106, g, 6) + line(64, 49, 64, 106, g, 6) + line(93, 49, 93, 106, g, 6) + circle(64, 38, 16, t) + line(56, 38, 72, 38, p, 6) + line(64, 30, 64, 46, p, 6)),
        "status_synced": svg("Sincronizado", circle(64, 64, 40, g) + f'<path d="M38 60a27 27 0 0 1 45-17l8 9M90 68a27 27 0 0 1-45 17l-8-9" stroke="{p}" stroke-width="7" stroke-linecap="round" stroke-linejoin="round"/>' + f'<path d="m83 36 8 16-17-1M45 92l-8-16 17 1" fill="{p}"/>'),
        "status_offline": svg("Sin conexión", circle(64, 66, 36, b) + f'<path d="M32 65c3-18 20-28 35-23 12-9 31 0 31 17 11 3 14 18 5 26H30c-12-4-10-20 2-20z" fill="{c}"/>' + f'<path d="m30 31 68 68" stroke="{t}" stroke-width="9" stroke-linecap="round"/>'),
        # Health and production detail.
        "health_vaccine": svg("Vacuna", rect(30, 43, 36, 61, y, 8) + rect(35, 30, 26, 16, g, 5) + rect(38, 68, 20, 10, p, 3) + f'<path d="M72 28h11v72a8 8 0 0 1-8 8h-3z" fill="{b}"/>' + line(77, 24, 77, 34, g, 5) + line(83, 55, 95, 55, g, 4) + line(83, 69, 95, 69, g, 4)),
        "health_treatment": svg("Tratamiento", rect(35, 44, 58, 63, y, 9) + rect(45, 29, 38, 19, g, 5) + rect(50, 68, 28, 8, p, 3) + rect(60, 58, 8, 28, p, 3) + circle(94, 89, 19, t) + f'<path d="M85 89h18M94 80v18" stroke="{p}" stroke-width="5" stroke-linecap="round"/>'),
        "health_diagnosis": svg("Diagnóstico", rect(24, 28, 58, 80, c, 8) + rect(39, 20, 28, 16, g, 5) + line(39, 52, 67, 52, g, 5) + line(39, 66, 60, 66, g, 5) + line(39, 80, 54, 80, g, 5) + circle(88, 82, 20, p) + f'<circle cx="88" cy="82" r="13" stroke="{t}" stroke-width="5"/>' + line(103, 97, 114, 108, t, 7)),
        "health_weight": svg("Peso", f'<path d="M40 25h48c8 0 12 5 14 13l12 58c2 9-4 15-13 15H27c-9 0-15-6-13-15l12-58c2-8 6-13 14-13" fill="{g}"/>' + f'<path d="M33 64a31 31 0 0 1 62 0v5H33z" fill="{p}"/>' + line(64, 38, 64, 45, b, 4) + line(64, 62, 76, 46, t, 5) + circle(64, 62, 6, t) + line(36, 87, 49, 87, m, 5) + line(79, 87, 92, 87, m, 5)),
        "health_body_condition": svg("Condición corporal", f'<path d="M30 82c-4-22 9-39 34-39s38 17 34 39c-4 18-16 27-34 27S34 100 30 82" fill="{y}"/>' + circle(49, 72, 6, p) + circle(79, 72, 6, p) + f'<path d="M50 90c9 7 19 7 28 0" stroke="{t}" stroke-width="5" stroke-linecap="round"/>' + f'<path d="M34 53c-14-9-20-1-18 13 9-1 15-5 18-13M94 53c14-9 20-1 18 13-9-1-15-5-18-13" fill="{g}"/>'),
        "health_birth": svg("Nacimiento", f'<path d="M64 107c-18-14-34-27-34-47 0-15 10-25 22-25 7 0 11 3 12 8 2-5 6-8 13-8 12 0 22 10 22 25 0 20-16 33-35 47z" fill="{c}"/>' + f'<path d="M64 84c-10-8-15-14-15-21 0-5 4-9 9-9 3 0 5 2 6 5 1-3 3-5 6-5 5 0 9 4 9 9 0 7-5 13-15 21z" fill="{t}"/>' + circle(64, 29, 8, y)),
        "health_reproduction": svg("Reproducción", f'<path d="M64 106 55 96C29 73 20 58 25 42c5-16 26-19 39-4 13-15 34-12 39 4 5 16-3 30-30 54z" fill="{t}"/>' + f'<path d="M31 30c12-9 24-9 33-1M97 30c-12-9-24-9-33-1" stroke="{g}" stroke-width="7" stroke-linecap="round"/>' + f'<path d="m30 30 3 14 12-6M98 30l-3 14-12-6" fill="{g}"/>'),
        "health_milk_production": svg("Producción de leche", rect(37, 34, 54, 73, b, 12) + rect(31, 24, 66, 16, g, 6) + f'<path d="M64 54c-10 15-21 25-21 36a21 21 0 0 0 42 0c0-11-11-21-21-36" fill="{p}"/>' + circle(64, 84, 6, y)),
        # Extra Registro / Agenda concepts, kept separate from the 53 location family.
        "record_animal": svg("Animal", f'<path d="M33 57c-12-11-19-4-17 8 2 12 10 14 19 6 5 13 13 20 29 20s24-7 29-20c9 8 17 6 19-6 2-12-5-19-17-8-8-14-15-20-31-20s-23 6-31 20" fill="{g}"/>' + circle(51, 64, 4, p) + circle(77, 64, 4, p) + f'<path d="M57 76c5 4 9 4 14 0" stroke="{t}" stroke-width="4" stroke-linecap="round"/>'),
        "record_lot": svg("Lote", circle(48, 48, 22, c) + circle(80, 48, 22, y) + circle(64, 82, 25, g) + circle(48, 48, 7, p) + circle(80, 48, 7, p) + circle(64, 82, 8, p)),
        "record_rfid": svg("RFID", f'<path d="M34 29h38a9 9 0 0 1 9 9v49a9 9 0 0 1-9 9H34a9 9 0 0 1-9-9V38a9 9 0 0 1 9-9" fill="{y}"/>' + rect(36, 48, 34, 25, p, 4) + f'<path d="M86 50c10 7 10 21 0 28M96 42c18 12 18 32 0 44" stroke="{g}" stroke-width="6" stroke-linecap="round"/>' + circle(53, 61, 5, t)),
        "record_location": svg("Ubicación", f'<path d="M64 112S29 76 29 52a35 35 0 1 1 70 0c0 24-35 60-35 60z" fill="{t}"/>' + circle(64, 51, 13, p) + circle(64, 51, 6, g)),
        "record_irrigation": svg("Riego", f'<path d="M29 31h33v66a9 9 0 0 1-9 9H38a9 9 0 0 1-9-9z" fill="{b}"/>' + rect(25, 23, 41, 15, g, 5) + f'<path d="M62 54h22l20 20" stroke="{g}" stroke-width="7" stroke-linecap="round" stroke-linejoin="round"/>' + circle(95, 84, 6, b) + circle(108, 98, 5, b) + circle(82, 96, 5, b)),
        "record_crop_health": svg("Salud de cultivo", f'<path d="M64 107V48" stroke="{g}" stroke-width="7" stroke-linecap="round"/>' + f'<path d="M64 70C45 68 34 57 35 43c15 1 26 9 29 27M64 61c8-15 19-21 34-18-3 14-14 20-34 18" fill="{g}"/>' + circle(91, 88, 21, t) + f'<path d="M82 88h18M91 79v18" stroke="{p}" stroke-width="5" stroke-linecap="round"/>'),
        "record_task": svg("Tarea", rect(27, 27, 74, 82, c, 9) + rect(44, 19, 40, 17, g, 5) + line(42, 55, 54, 55, g, 5) + line(42, 72, 54, 72, g, 5) + line(42, 89, 54, 89, g, 5) + f'<path d="m67 55 8 8 14-16M67 72l8 8 14-16M67 89l8 8 14-16" stroke="{t}" stroke-width="5" stroke-linecap="round" stroke-linejoin="round"/>'),
        "record_administration": svg("Administración", rect(18, 37, 92, 68, c, 9) + f'<path d="M27 37v-9h31l8 9h35v68H27z" fill="{y}"/>' + circle(80, 75, 18, g) + circle(80, 75, 7, p) + f'<path d="M80 52v7M80 91v7M57 75h7M96 75h7" stroke="{g}" stroke-width="5" stroke-linecap="round"/>'),
        "record_reminder": svg("Recordatorio", f'<path d="M35 84V57a29 29 0 0 1 58 0v27l8 10H27z" fill="{y}"/>' + circle(64, 104, 7, t) + line(64, 24, 64, 16, g, 5) + line(34, 35, 27, 28, g, 5) + line(94, 35, 101, 28, g, 5)),
        "record_care": svg("Cuidado", f'<path d="M64 108 55 98C29 75 20 60 25 44c5-16 26-19 39-4 13-15 34-12 39 4 5 16-3 30-30 54z" fill="{g}"/>' + f'<path d="M64 82c-10-9-15-15-15-23 0-6 5-11 11-11 4 0 7 2 9 6 2-4 5-6 9-6 6 0 11 5 11 11 0 8-5 14-16 23z" fill="{p}"/>'),
        "record_alert": svg("Alerta", f'<path d="m64 16 49 92H15z" fill="{t}"/>' + line(64, 44, 64, 72, p, 8) + circle(64, 90, 5, p)),
        "status_verified": svg("Verificado", circle(64, 64, 40, g) + f'<circle cx="64" cy="64" r="27" stroke="{p}" stroke-width="4"/>' + f'<path d="m46 65 12 12 24-29" stroke="{p}" stroke-width="8" stroke-linecap="round" stroke-linejoin="round"/>'),
        "status_reprogrammed": svg("Reprogramado", rect(24, 29, 80, 78, c, 10) + rect(24, 29, 80, 23, t, 10) + line(43, 19, 43, 38, g, 7) + line(85, 19, 85, 38, g, 7) + f'<path d="M46 78a22 22 0 0 0 37 11M82 83a22 22 0 0 0-37-11" stroke="{g}" stroke-width="6" stroke-linecap="round" stroke-linejoin="round"/>' + f'<path d="m77 88 7 1-1-8M51 67l-7-1 1 8" fill="{g}"/>'),
        "status_draft": svg("Borrador", rect(26, 20, 58, 87, c, 7) + line(40, 46, 69, 46, g, 5) + line(40, 61, 63, 61, g, 5) + f'<path d="m68 82 24-37a6 6 0 0 1 8-2l4 3a6 6 0 0 1 2 8L82 91 65 99z" fill="{t}"/>' + f'<path d="m68 82 14 9-17 8z" fill="{p}"/>'),
        "status_blocked": svg("Bloqueado", circle(64, 64, 42, c) + rect(45, 43, 12, 42, t, 4) + rect(71, 43, 12, 42, t, 4)),
    }


def main() -> None:
    bodies = icon_bodies()
    OUT.mkdir(parents=True, exist_ok=True)
    for name, content in bodies.items():
        (OUT / f"{name}.svg").write_text(content, encoding="utf-8")
    print(f"Generated {len(bodies)} editable SVG icons in {OUT}")


if __name__ == "__main__":
    main()
