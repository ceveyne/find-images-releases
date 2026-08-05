import fs from "node:fs";
import path from "node:path";
import nacl from "tweetnacl";
import { fileURLToPath } from "node:url";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const appRepoDir = path.resolve(__dirname, "../../find-images");
const privateKeyPath = path.join(appRepoDir, "packaging", "sparkle-ed25519", "sparkle-ed25519-private.key");

const filePath = process.argv[2];
if (!filePath) {
  console.error("Usage: sign-update.mjs <file-to-sign>");
  process.exit(1);
}

if (!fs.existsSync(filePath)) {
  console.error(`File not found: ${filePath}`);
  process.exit(1);
}

if (!fs.existsSync(privateKeyPath)) {
  console.error(`Private key not found: ${privateKeyPath}`);
  console.error("Run generate-sparkle-keys.mjs first.");
  process.exit(1);
}

const secretKeyBase64 = fs.readFileSync(privateKeyPath, "utf8").trim();
const secretKey = Buffer.from(secretKeyBase64, "base64");
if (secretKey.length !== 64) {
  console.error(`Invalid private key length: expected 64 bytes, got ${secretKey.length}`);
  process.exit(1);
}

const message = fs.readFileSync(filePath);
const signature = nacl.sign.detached(message, secretKey);
console.log(Buffer.from(signature).toString("base64"));
