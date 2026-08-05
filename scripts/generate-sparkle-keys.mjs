import fs from "node:fs";
import path from "node:path";
import nacl from "tweetnacl";
import { fileURLToPath } from "node:url";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const appRepoDir = path.resolve(__dirname, "../../find-images");
const keyDir = path.join(appRepoDir, "packaging", "sparkle-ed25519");
const privateKeyPath = path.join(keyDir, "sparkle-ed25519-private.key");

if (!fs.existsSync(keyDir)) {
  fs.mkdirSync(keyDir, { recursive: true });
}

if (fs.existsSync(privateKeyPath)) {
  console.error(`Private key already exists: ${privateKeyPath}`);
  console.error("Delete it first if you want to generate a new key pair.");
  process.exit(1);
}

const keyPair = nacl.sign.keyPair();
fs.writeFileSync(privateKeyPath, Buffer.from(keyPair.secretKey).toString("base64"));
fs.chmodSync(privateKeyPath, 0o600);

const publicKeyBase64 = Buffer.from(keyPair.publicKey).toString("base64");

console.log("Generated Sparkle EdDSA key pair.");
console.log(`Private key saved to: ${privateKeyPath}`);
console.log(`Public key (add to Info.plist as SUPublicEDKey):\n${publicKeyBase64}`);
