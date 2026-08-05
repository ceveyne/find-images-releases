import fs from "node:fs";
import path from "node:path";

const [version, dmgPath, outputPath, baseUrl, edSignature] = process.argv.slice(2);

if (!version || !dmgPath || !outputPath || !baseUrl) {
  console.error("Usage: generate-appcast.mjs <version> <dmg-path> <output-path> <base-url> [ed-signature]");
  process.exit(1);
}

if (!fs.existsSync(dmgPath)) {
  console.error(`DMG not found: ${dmgPath}`);
  process.exit(1);
}

function normalizeVersionForComparison(versionString) {
  // Convert display versions like "0.1.51-9" to numeric versions like "0.1.51.9"
  // so Sparkle's standard comparator treats "10" as greater than "9".
  return versionString.replace(/-(\d+)$/, ".$1");
}

const dmgName = path.basename(dmgPath);
const releaseUrl = `${baseUrl.replace(/\/$/, "")}/${encodeURIComponent(dmgName)}`;
const length = fs.statSync(dmgPath).size;
const pubDate = new Date().toUTCString();
const comparisonVersion = normalizeVersionForComparison(version);

const enclosureUrl = releaseUrl
  .replace(/&/g, "&amp;")
  .replace(/</g, "&lt;")
  .replace(/>/g, "&gt;")
  .replace(/"/g, "&quot;");

const edSignatureAttr = edSignature
  ? ` sparkle:edSignature="${edSignature.replace(/&/g, "&amp;").replace(/"/g, "&quot;")}"`
  : "";

const xml = `<?xml version="1.0" encoding="utf-8"?>
<rss xmlns:sparkle="http://www.andymatuschak.org/xml-namespaces/sparkle" version="2.0">
  <channel>
    <title>Find Images Appcast</title>
    <link>https://github.com/ceveyne/find-images-releases/releases</link>
    <description>Appcast feed for Find Images updates.</description>
    <language>en</language>
    <item>
      <title>Find Images ${version}</title>
      <pubDate>${pubDate}</pubDate>
      <sparkle:version>${comparisonVersion}</sparkle:version>
      <sparkle:shortVersionString>${version}</sparkle:shortVersionString>
      <enclosure url="${enclosureUrl}" length="${length}" type="application/octet-stream"${edSignatureAttr} />
    </item>
  </channel>
</rss>
`;

fs.writeFileSync(outputPath, xml);
console.log(`Generated ${outputPath}`);
