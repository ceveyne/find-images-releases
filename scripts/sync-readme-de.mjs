#!/usr/bin/env node
import fs from "node:fs";
import path from "node:path";

const TODO_START = "<!-- README_DE_SYNC_TODO:";
const TODO_END = "<!-- /README_DE_SYNC_TODO -->";
const SOURCE_MARKER = "<!-- README_DE_SOURCE:";

function readFile(filePath) {
  return fs.readFileSync(filePath, "utf8");
}

function writeFile(filePath, content) {
  fs.mkdirSync(path.dirname(filePath), { recursive: true });
  fs.writeFileSync(filePath, content);
}

function sectionId(title) {
  return title.toLocaleLowerCase().replaceAll(/[^a-z0-9]+/g, "-").replaceAll(/^-|-$/g, "");
}

function parseSections(readme) {
  const matches = [...readme.matchAll(/^## (.+)$/gm)];
  const sections = new Map();
  for (const [index, match] of matches.entries()) {
    const title = match[1].trim();
    const id = sectionId(title);
    if (!id || sections.has(id)) throw new Error(`README contains a duplicate or invalid level-two heading: ${title}`);
    const start = match.index ?? 0;
    const end = matches[index + 1]?.index ?? readme.length;
    sections.set(id, { id, title, markdown: readme.slice(start, end).trimEnd() });
  }
  return sections;
}

function escapeRegularExpression(value) {
  return value.replaceAll(/[.*+?^${}()|[\]\\]/g, "\\$&");
}

function removeTodoBlocksForSection(readme, id) {
  const escapedStart = TODO_START.replaceAll(/[.*+?^${}()|[\]\\]/g, "\\$&");
  const escapedEnd = TODO_END.replaceAll(/[.*+?^${}()|[\]\\]/g, "\\$&");
  const escapedId = escapeRegularExpression(id);
  return readme.replace(new RegExp(`\\n?${escapedStart} (?:new|changed|removed):${escapedId} -->\\n[\\s\\S]*?${escapedEnd}\\n?`, "g"), "\n");
}

function addSourceMarkers(readme) {
  return readme.replace(/^## (.+)$/gm, (heading, title) => `${SOURCE_MARKER} ${sectionId(title)} -->\n${heading}`);
}

function markdownCodeBlock(markdown) {
  const fence = markdown.includes("```") ? "````" : "```";
  return `${fence}markdown\n${markdown}\n${fence}`;
}

function todoBlock(kind, id, text) {
  return `${TODO_START} ${kind}:${id} -->\n${text}\n${TODO_END}\n`;
}

function newSectionTodo(section) {
  const message = `> **TRANSLATION TODO:** Neues englisches Kapitel "${section.title}" übersetzen und diesen Platzhalter ersetzen.\n\n<details>\n<summary>Englische Quellfassung anzeigen</summary>\n\n${markdownCodeBlock(section.markdown)}\n\n</details>`;
  return `${SOURCE_MARKER} ${section.id} -->\n## TRANSLATION TODO: ${section.title}\n\n${todoBlock("new", section.id, message)}`;
}

function changedSectionTodo(section) {
  const message = `> **TRANSLATION TODO:** Das englische Kapitel "${section.title}" wurde geändert. Die deutsche Fassung anhand der aktuellen Quellfassung aktualisieren.\n\n<details>\n<summary>Aktuelle englische Quellfassung anzeigen</summary>\n\n${markdownCodeBlock(section.markdown)}\n\n</details>`;
  return todoBlock("changed", section.id, message);
}

function removedSectionTodo(section) {
  return todoBlock("removed", section.id, `> **TRANSLATION TODO:** Das englische Kapitel "${section.title}" wurde entfernt. Den entsprechenden deutschen Abschnitt prüfen und entfernen.`);
}

function markerPattern(id) {
  return new RegExp(`^${escapeRegularExpression(SOURCE_MARKER)} ${escapeRegularExpression(id)} -->\\n`, "m");
}

function insertTodoAfterHeading(readme, id, todo) {
  const marker = markerPattern(id);
  const markerMatch = marker.exec(readme);
  if (!markerMatch || markerMatch.index === undefined) throw new Error(`README_DE.md is missing source marker for section ${id}`);
  const headingEnd = readme.indexOf("\n", markerMatch.index + markerMatch[0].length);
  if (headingEnd < 0) throw new Error(`README_DE.md has no heading after source marker ${id}`);
  return `${readme.slice(0, headingEnd + 1)}\n${todo}\n${readme.slice(headingEnd + 1)}`;
}

function insertNewSection(readme, section, newSections) {
  const newIndex = newSections.findIndex((candidate) => candidate.id === section.id);
  const nextKnownSection = newSections.slice(newIndex + 1).find((candidate) => markerPattern(candidate.id).test(readme));
  const block = `\n${newSectionTodo(section)}`;
  if (!nextKnownSection) return `${readme.trimEnd()}\n${block}`;
  const nextMarker = markerPattern(nextKnownSection.id).exec(readme);
  if (!nextMarker || nextMarker.index === undefined) throw new Error(`README_DE.md is missing source marker for section ${nextKnownSection.id}`);
  return `${readme.slice(0, nextMarker.index)}${block}\n${readme.slice(nextMarker.index)}`;
}

function validateMarkers(readme, englishSections) {
  for (const id of englishSections.keys()) {
    if (!markerPattern(id).test(readme)) throw new Error(`README_DE.md is missing source marker for English section ${id}`);
  }
}

function syncGermanReadme(previousEnglishPath, currentEnglishPath, germanReadmePath, checkOnly) {
  const currentEnglish = readFile(currentEnglishPath);
  const currentSections = parseSections(currentEnglish);
  if (!fs.existsSync(germanReadmePath)) {
    if (checkOnly) throw new Error(`Missing German README: ${germanReadmePath}`);
    writeFile(germanReadmePath, addSourceMarkers(currentEnglish));
    console.log(`Created ${germanReadmePath}`);
    return;
  }

  let germanReadme = readFile(germanReadmePath);
  if (!fs.existsSync(previousEnglishPath)) {
    if (checkOnly) throw new Error(`Missing previous English README: ${previousEnglishPath}`);
    validateMarkers(germanReadme, currentSections);
    writeFile(germanReadmePath, germanReadme);
    return;
  }

  const previousSections = parseSections(readFile(previousEnglishPath));
  if (checkOnly) {
    validateMarkers(germanReadme, currentSections);
    return;
  }

  for (const section of currentSections.values()) {
    const previous = previousSections.get(section.id);
    if (!previous) {
      germanReadme = removeTodoBlocksForSection(germanReadme, section.id);
      germanReadme = insertNewSection(germanReadme, section, [...currentSections.values()]);
    } else if (previous.markdown !== section.markdown) {
      germanReadme = removeTodoBlocksForSection(germanReadme, section.id);
      germanReadme = insertTodoAfterHeading(germanReadme, section.id, changedSectionTodo(section));
    }
  }

  for (const section of previousSections.values()) {
    if (!currentSections.has(section.id)) {
      germanReadme = removeTodoBlocksForSection(germanReadme, section.id);
      germanReadme = insertTodoAfterHeading(germanReadme, section.id, removedSectionTodo(section));
    }
  }

  writeFile(germanReadmePath, germanReadme.trimEnd() + "\n");
  console.log(`Updated ${germanReadmePath}`);
}

const [mode, previousEnglishPath, currentEnglishPath, germanReadmePath] = process.argv.slice(2);
const checkOnly = mode === "--check";
const paths = checkOnly ? [previousEnglishPath, currentEnglishPath, germanReadmePath] : [mode, previousEnglishPath, currentEnglishPath];
if (paths.some((value) => !value)) {
  console.error("Usage: sync-readme-de.mjs [--check] <previous-english-readme> <current-english-readme> <german-readme>");
  process.exit(1);
}

const [previousPath, currentPath, germanPath] = paths;
syncGermanReadme(previousPath, currentPath, germanPath, checkOnly);
