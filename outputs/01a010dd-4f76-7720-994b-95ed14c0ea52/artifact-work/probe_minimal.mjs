import { SpreadsheetFile, Workbook } from "@oai/artifact-tool";
const workbook = Workbook.create();
const sheet = workbook.worksheets.add("Animales");
sheet.getRange("A1:C3").values = [["A", "B", "C"], ["x", 1, "17/08/2026"], ["y", 2, "18/08/2026"]];
const output = await SpreadsheetFile.exportXlsx(workbook);
await output.save("C:/Users/Master/Desktop/Code/LibretApp/outputs/01a010dd-4f76-7720-994b-95ed14c0ea52/artifact-work/probe_minimal.xlsx");
