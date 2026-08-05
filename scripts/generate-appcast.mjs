import fs from "node:fs";
import path from "node:path";

const [version, dmgZipPath, outputPath, baseUrl, edSignature] = process.argv.slice(2);

if (!version || !dmgZipPath || !outputPath || !baseUrl) {
  console.error("Usage: generate-appcast.mjs <version> <dmg-zip-path> <output-path> <base-url> [ed-signature]");
  process.exit(1);
}

if (!fs.existsSync(dmgZipPath)) {
  console.error(`DMG-ZIP not found: ${dmgZipPath}`);
  process.exit(1);
}

const dmgZipName = path.basename(dmgZipPath);
const releaseUrl = `${baseUrl.replace(/\/$/, "")}/${encodeURIComponent(dmgZipName)}`;
const length = fs.statSync(dmgZipPath).size;
const pubDate = new Date().toUTCString();

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
      <sparkle:version>${version}</sparkle:version>
      <sparkle:shortVersionString>${version}</sparkle:shortVersionString>
      <enclosure url="${enclosureUrl}" length="${length}" type="application/octet-stream"${edSignatureAttr} />
    </item>
  </channel>
</rss>
`;

fs.writeFileSync(outputPath, xml);
console.log(`Generated ${outputPath}`);
