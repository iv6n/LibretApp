import fs from "node:fs/promises";
import path from "node:path";
import { SpreadsheetFile, Workbook } from "@oai/artifact-tool";
import JSZip from "jszip";

const outputDir = "C:/Users/Master/Desktop/Code/LibretApp/outputs/01a010dd-4f76-7720-994b-95ed14c0ea52";
const workDir = "C:/Users/Master/Desktop/Code/LibretApp/outputs/01a010dd-4f76-7720-994b-95ed14c0ea52/artifact-work";
const snapshotPath = path.join(outputDir, "demo_snapshot.json");
const snapshot = JSON.parse(await fs.readFile(snapshotPath, "utf8"));

const colors = {
  green: "#166534",
  greenLight: "#DCFCE7",
  amber: "#FEF3C7",
  ink: "#172018",
  grid: "#D1D5DB",
  pale: "#F8FAFC",
  white: "#FFFFFF",
};

function toSpanishDate(value) {
  if (!value) return "";
  const date = new Date(value);
  const dd = String(date.getDate()).padStart(2, "0");
  const mm = String(date.getMonth() + 1).padStart(2, "0");
  return `${dd}/${mm}/${date.getFullYear()}`;
}

function toSpanishDateTime(value) {
  if (!value) return "";
  const date = new Date(value);
  const dd = String(date.getDate()).padStart(2, "0");
  const mm = String(date.getMonth() + 1).padStart(2, "0");
  const hh = String(date.getHours()).padStart(2, "0");
  const min = String(date.getMinutes()).padStart(2, "0");
  return `${dd}/${mm}/${date.getFullYear()} ${hh}:${min}`;
}

function writeTableSheet(workbook, name, headers, rows, widths, tableName) {
  const sheet = workbook.worksheets.add(name);
  sheet.showGridLines = false;
  const matrix = [headers, ...rows];
  const used = sheet.getRangeByIndexes(0, 0, matrix.length, headers.length);
  used.values = matrix;
  used.format.borders = { preset: "all", style: "thin", color: colors.grid };
  used.format.wrapText = true;
  sheet.getRangeByIndexes(0, 0, 1, headers.length).format = {
    fill: colors.green,
    font: { bold: true, color: colors.white },
    wrapText: true,
  };
  if (rows.length > 0) {
    const table = sheet.tables.add(`A1:${columnName(headers.length - 1)}${matrix.length}`, true, tableName);
    table.showFilterButton = true;
  }
  sheet.freezePanes.freezeRows(1);
  widths.forEach((width, index) => {
    sheet.getRangeByIndexes(0, index, matrix.length, 1).format.columnWidth = width;
  });
  return sheet;
}

function columnName(index) {
  let value = "";
  let n = index + 1;
  while (n > 0) {
    const remainder = (n - 1) % 26;
    value = String.fromCharCode(65 + remainder) + value;
    n = Math.floor((n - 1) / 26);
  }
  return value;
}

const animalsHeaders = [
  "N° Caravana", "Nombre", "Especie", "Categoría", "Sexo", "Raza",
  "Fecha Nac.", "Edad (meses)", "Peso (kg)", "Estado", "Estado Salud", "Propietario",
];
const animalsRows = snapshot.animals.map((animal) => [
  animal.earTag,
  animal.name,
  animal.species,
  animal.category,
  animal.sex,
  animal.breed,
  toSpanishDate(animal.birthDate),
  animal.ageMonths,
  animal.weight ?? null,
  animal.status,
  animal.healthStatus,
  animal.owner,
]);

const workbook = Workbook.create();

const animalsSheet = writeTableSheet(
  workbook,
  "Animales",
  animalsHeaders,
  animalsRows,
  [16, 20, 14, 16, 12, 18, 14, 14, 12, 14, 16, 22],
  "AnimalesDemo",
);
const animalsLastRow = animalsRows.length + 1;
animalsSheet.getRange(`H2:H${animalsLastRow}`).format.numberFormat = "0";
animalsSheet.getRange(`I2:I${animalsLastRow}`).format.numberFormat = "0.0";
animalsSheet.getRange(`C2:C${animalsLastRow}`).dataValidation = {
  rule: { type: "list", values: ["cattle", "goat", "sheep", "pig", "equine", "poultry", "canine", "other"] },
};
animalsSheet.getRange(`D2:D${animalsLastRow}`).dataValidation = {
  rule: { type: "list", values: ["calf", "heifer", "youngBull", "steer", "cow", "bull", "oxen", "weaned", "juvenile", "grower", "fattening", "production", "reproduction", "work", "guard", "other"] },
};
animalsSheet.getRange(`E2:E${animalsLastRow}`).dataValidation = {
  rule: { type: "list", values: ["female", "male"] },
};
animalsSheet.getRange(`J2:J${animalsLastRow}`).dataValidation = {
  rule: { type: "list", values: ["active", "sold", "dead", "archived"] },
};
animalsSheet.getRange(`K2:K${animalsLastRow}`).dataValidation = {
  rule: { type: "list", values: ["excellent", "good", "fair", "poor", "critical", "unknown"] },
};
const missingTagIndex = snapshot.animals.findIndex((animal) => !animal.earTag);
if (missingTagIndex >= 0) {
  const row = missingTagIndex + 2;
  animalsSheet.getRange(`A${row}:L${row}`).format = {
    fill: colors.amber,
    font: { color: colors.ink },
  };
}

const locationsSheet = writeTableSheet(
  workbook,
  "Ubicaciones",
  ["Nombre", "Tipo", "Superficie (m²)", "Capacidad", "Estado", "Fuente de Agua", "Tipo Terreno"],
  snapshot.locations.map((location) => [
    location.name,
    location.type,
    location.surfaceArea,
    location.capacity,
    location.status,
    location.waterSource,
    location.terrainType,
  ]),
  [30, 18, 18, 12, 16, 30, 36],
  "UbicacionesDemo",
);
locationsSheet.getRange("C2:C1000").format.numberFormat = "0.00";
locationsSheet.getRange("D2:D1000").format.numberFormat = "0";

const workersByName = new Map(snapshot.workers.map((worker) => [worker.id, worker.name]));
const teamsById = new Map(snapshot.workers.map((worker) => [worker.id, worker.name]));
const eventsSheet = writeTableSheet(
  workbook,
  "Eventos",
  ["Título", "Descripción", "Fecha", "Tipo", "ID Animal", "Ubicación", "Estado", "Prioridad", "Progreso", "Responsable", "Equipo", "Colaboradores", "Checklist", "Recurrencia", "Actualizada"],
  snapshot.events.map((event) => [
    event.title,
    event.description,
    toSpanishDateTime(event.date),
    event.type,
    event.animalIds,
    event.location,
    event.status,
    event.priority,
    event.progress,
    event.assignee,
    event.team,
    event.collaborators,
    event.checklist,
    event.recurrence,
    toSpanishDateTime(event.updatedAt),
  ]),
  [30, 42, 20, 18, 28, 30, 16, 14, 14, 28, 28, 28, 14, 18, 20],
  "EventosDemo",
);

writeTableSheet(
  workbook,
  "Lotes",
  ["Nombre", "Descripción", "Animales", "Activo"],
  snapshot.lots.map((lot) => [
    lot.name,
    lot.description,
    snapshot.animals.filter((animal) => animal.lotId === lot.uuid).length || lot.animalCount,
    lot.active ? "Sí" : "No",
  ]),
  [28, 50, 14, 12],
  "LotesDemo",
);

writeTableSheet(
  workbook,
  "Personal",
  ["Nombre", "Rol", "Teléfono", "Activo"],
  snapshot.workers.map((worker) => [worker.name, worker.role, worker.phone, worker.active ? "Sí" : "No"]),
  [32, 18, 18, 12],
  "PersonalDemo",
);

const catalogSheet = workbook.worksheets.add("Catalogos");
catalogSheet.showGridLines = false;
catalogSheet.getRange("A1:H1").values = [["Campo", "Valores válidos para importar", "Notas", null, null, null, null, null]];
catalogSheet.getRange("A1:C1").format = {
  fill: colors.green,
  font: { bold: true, color: colors.white },
};
catalogSheet.getRange("A2:C7").values = [
  ["Especie", "cattle | goat | sheep | pig | equine | poultry | canine | other", "Usar el identificador exacto."],
  ["Categoría", "calf | heifer | youngBull | steer | cow | bull | oxen | weaned | juvenile | grower | fattening | production | reproduction | work | guard | other", "Usar el identificador exacto."],
  ["Sexo", "female | male", "Usar el identificador exacto."],
  ["Estado animal", "active | sold | dead | archived", "Usar el identificador exacto."],
  ["Estado salud", "excellent | good | fair | poor | critical | unknown", "Usar el identificador exacto."],
  ["Fecha", "dd/MM/yyyy", "La importación de animales exige este formato."],
];
catalogSheet.getRange("A1:C7").format.borders = { preset: "all", style: "thin", color: colors.grid };
catalogSheet.getRange("A2:C7").format.wrapText = true;
catalogSheet.getRange("A2:A7").format.font = { bold: true, color: colors.green };
[22, 100, 52].forEach((width, index) => {
  catalogSheet.getRangeByIndexes(0, index, 7, 1).format.columnWidth = width;
});
catalogSheet.freezePanes.freezeRows(1);

const instructions = workbook.worksheets.add("INSTRUCCIONES");
instructions.showGridLines = false;
instructions.mergeCells("A1:H1");
instructions.getRange("A1").values = [["LibretApp · Formato Excel del demo"]];
instructions.getRange("A1:H1").format = {
  fill: colors.green,
  font: { bold: true, color: colors.white, size: 16 },
};
instructions.getRange("A3:B3").values = [["Contenido", "Cantidad"]];
instructions.getRange("A4:B8").values = [
  ["Animales", snapshot.animals.length],
  ["Ubicaciones", snapshot.locations.length],
  ["Lotes", snapshot.lots.length],
  ["Personal", snapshot.workers.length],
  ["Eventos", snapshot.events.length],
];
instructions.getRange("A3:B8").format.borders = { preset: "all", style: "thin", color: colors.grid };
instructions.getRange("A3:B3").format = { fill: colors.greenLight, font: { bold: true, color: colors.green } };
instructions.getRange("A10:H10").values = [["Cómo usarlo", null, null, null, null, null, null, null]];
instructions.getRange("A10:H10").merge();
instructions.getRange("A10:H10").format = { fill: colors.greenLight, font: { bold: true, color: colors.green } };
instructions.getRange("A11:H15").values = [
  ["1", "Para importar en el teléfono: abre LibretApp → Perfil → Ajustes → Importar animales desde Excel.", null, null, null, null, null, null],
  ["2", "El importador reconoce la hoja Animales y actualiza o crea registros por N° Caravana.", null, null, null, null, null, null],
  ["3", "Las hojas Ubicaciones, Eventos, Lotes y Personal documentan el demo y sirven para exportación/consulta.", null, null, null, null, null, null],
  ["4", "Fecha Nac. debe conservar dd/MM/yyyy; los identificadores de especie, categoría, sexo y estados deben conservarse tal como aparecen.", null, null, null, null, null, null],
  ["5", "La fila amarilla corresponde a una cría demo sin caravana; el importador la omite y muestra un aviso.", null, null, null, null, null, null],
];
for (let row = 11; row <= 15; row += 1) {
  instructions.mergeCells(`B${row}:H${row}`);
}
instructions.getRange("A11:H15").format = { wrapText: true, borders: { preset: "all", style: "thin", color: colors.grid } };
instructions.getRange("A11:A15").format.font = { bold: true, color: colors.green };
instructions.getRange("A17:H17").values = [["Fecha de referencia del demo", toSpanishDate(snapshot.referenceDate), null, null, null, null, null, null]];
instructions.getRange("A17:H17").format = { fill: colors.pale, font: { italic: true, color: colors.ink } };
instructions.getRange("A1:H20").format.rowHeight = 24;
instructions.getRange("A1:A20").format.columnWidth = 26;
instructions.getRange("B1:H20").format.columnWidth = 22;

await fs.mkdir(outputDir, { recursive: true });
const workbookSummary = await workbook.inspect({
  kind: "sheet,table",
  maxChars: 4000,
  tableMaxRows: 3,
  tableMaxCols: 5,
});
console.log(workbookSummary.ndjson);
const errors = await workbook.inspect({
  kind: "match",
  searchTerm: "#REF!|#DIV/0!|#VALUE!|#NAME\\?|#N/A",
  options: { useRegex: true, maxResults: 100 },
  summary: "formula error scan",
});
console.log(errors.ndjson);

for (const sheet of ["INSTRUCCIONES", "Animales", "Ubicaciones", "Eventos", "Lotes", "Personal", "Catalogos"]) {
  const preview = await workbook.render({ sheetName: sheet, autoCrop: "all", scale: 1, format: "png" });
  await fs.writeFile(path.join(workDir, `preview_${sheet}.png`), new Uint8Array(await preview.arrayBuffer()));
}

const output = await SpreadsheetFile.exportXlsx(workbook);
const rawPath = path.join(workDir, "raw_artifact_workbook.xlsx");
await output.save(rawPath);
const zip = await JSZip.loadAsync(await fs.readFile(rawPath));
for (const name of Object.keys(zip.files)) {
  if (!name.startsWith("xl/") || !name.endsWith(".xml") || name.includes("/_rels/")) continue;
  const entry = zip.file(name);
  if (!entry) continue;
  const xml = await entry.async("string");
  if (!xml.includes("x:")) continue;
  const normalizedXml = xml
    .replaceAll("x:", "")
    .replaceAll(
      'xmlns:x="http://schemas.openxmlformats.org/spreadsheetml/2006/main"',
      'xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main"',
    )
    .replace(/(<c\b[^>]*?) t="str"(\s*\/>)/g, "$1$2");
  zip.file(name, normalizedXml);
}
const workbookRels = zip.file("xl/_rels/workbook.xml.rels");
if (workbookRels) {
  const rels = await workbookRels.async("string");
  zip.file("xl/_rels/workbook.xml.rels", rels.replaceAll('Target="/xl/', 'Target="'));
}
const compatibleBytes = await zip.generateAsync({ type: "nodebuffer", compression: "DEFLATE" });
await fs.writeFile(path.join(outputDir, "libretapp_demo_import_export.xlsx"), compatibleBytes);
await fs.unlink(rawPath);
