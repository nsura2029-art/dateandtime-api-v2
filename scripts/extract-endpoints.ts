/**
 * Extract endpoint definitions from src/routes/*.ts and src/index.ts.
 * Output a markdown table for README.md.
 *
 * Usage:
 *   tsx scripts/extract-endpoints.ts                    # print to stdout
 *   tsx scripts/extract-endpoints.ts --check            # exit 1 if README is out of sync
 *   tsx scripts/extract-endpoints.ts --update <readme>  # update markers in <readme>
 *
 * Convention for routes:
 *   - File in src/routes/<resource>.ts
 *   - Exports a Hono sub-app: const <resource> = new Hono<{...}>();
 *   - Defines endpoints: <resource>.get("/path", handler);
 *   - Each route has JSDoc above: /** Description *\/
 *   - Methods we extract: get, post, put, delete, on (HEAD/OPTIONS)
 */
import * as fs from "node:fs";
import * as path from "node:path";
import { fileURLToPath } from "node:url";

type Method = "GET" | "POST" | "PUT" | "DELETE" | "PATCH" | "HEAD" | "OPTIONS";
type Endpoint = { method: Method; path: string; description: string; file: string };

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const REPO_ROOT = path.resolve(__dirname, "..");
const ROUTES_DIR = path.join(REPO_ROOT, "src/routes");

/** Walk a routes file and extract endpoint definitions. */
function parseRoutesFile(filePath: string): Endpoint[] {
  const content = fs.readFileSync(filePath, "utf-8");
  const fileBase = path.relative(REPO_ROOT, filePath);

  // Find the sub-app variable name: `const <name> = new Hono<...>()`
  const subAppMatch = content.match(/const\s+(\w+)\s*=\s*new\s+Hono\s*</);
  if (!subAppMatch) return [];
  const subAppName = subAppMatch[1];

  // Split content by line, find route definitions
  const lines = content.split("\n");
  const endpoints: Endpoint[] = [];

  for (let i = 0; i < lines.length; i++) {
    const line = lines[i];

    // Try two patterns:
    //   1. <subApp>.get/post/put/delete/patch("path", handler)
    //   2. <subApp>.on("METHOD", "/path", handler)
    const simpleMatch = line.match(
      new RegExp(`^\\s*${subAppName}\\.(get|post|put|delete|patch)\\s*\\(\\s*["']([^"']+)["']`)
    );
    const onMatch = line.match(
      new RegExp(`^\\s*${subAppName}\\.on\\s*\\(\\s*["'](\\w+)["']\\s*,\\s*["']([^"']+)["']`)
    );

    let method: Method | null = null;
    let routePath: string | null = null;

    if (simpleMatch) {
      method = simpleMatch[1].toUpperCase() as Method;
      routePath = simpleMatch[2];
    } else if (onMatch) {
      const onMethodRaw = onMatch[1].toUpperCase();
      if (["GET", "POST", "PUT", "DELETE", "PATCH", "HEAD", "OPTIONS"].includes(onMethodRaw)) {
        method = onMethodRaw as Method;
        routePath = onMatch[2];
      }
    }

    if (!method || !routePath) continue;

    // Find JSDoc on the line(s) above
    let description = "";
    for (let j = i - 1; j >= 0; j--) {
      const prev = lines[j].trim();
      if (prev === "") continue;
      if (prev.startsWith("//")) {
        // Skip comment dividers
        if (prev.startsWith("// ===") || prev.startsWith("// ---")) continue;
        // Use the last single-line comment as description
        description = prev.replace(/^\/\/\s*/, "").replace(/^-\s*/, "").trim();
        break;
      }
      if (prev.endsWith("*/")) {
        // Multi-line JSDoc — find the start
        let jsdoc = "";
        for (let k = j; k >= Math.max(0, j - 20); k--) {
          const ln = lines[k] ?? "";
          jsdoc = ln + "\n" + jsdoc;
          if (ln.trim().startsWith("/**")) break;
        }
        const jsdocMatch = jsdoc.match(/\/\*\*\s*([\s\S]*?)\s*\*\//);
        if (jsdocMatch) {
          description = jsdocMatch[1]
            .split("\n")
            .map((l) => l.replace(/^\s*\*\s?/, "").trim())
            .filter((l) => l && !l.startsWith("@"))
            .join(" ")
            .trim();
        }
        break;
      }
      // Hit non-comment, non-empty line — stop
      break;
    }

    if (!description) {
      description = `${method} ${routePath}`;
    }

    endpoints.push({ method, path: routePath, description, file: fileBase });
  }

  return endpoints;
}

/** Read src/index.ts to find the mount order (which file maps to which path). */
function getMountInfo(): Map<string, string> {
  const indexPath = path.join(REPO_ROOT, "src/index.ts");
  if (!fs.existsSync(indexPath)) return new Map();
  const content = fs.readFileSync(indexPath, "utf-8");

  // Match: app.route("/mount", resourceName);
  const mounts = new Map<string, string>(); // resourceName → mountPath
  const mountRegex = /app\.route\(\s*["']([^"']*)["']\s*,\s*(\w+)\s*\)/g;
  for (const match of content.matchAll(mountRegex)) {
    const m2 = match[2];
    const m1 = match[1];
    if (m1 && m2) mounts.set(m2, m1);
  }
  return mounts;
}

/** Compute the full path for an endpoint (mount path + route path). */
function fullPath(mount: string, routePath: string): string {
  if (routePath === "/") return mount || "/";
  if (mount === "/") return routePath;
  if (mount.endsWith("/") && routePath.startsWith("/")) return mount + routePath.slice(1);
  if (!mount.endsWith("/") && !routePath.startsWith("/")) return mount + "/" + routePath;
  return mount + routePath;
}

/** Generate a markdown table from endpoints. */
function toMarkdown(endpoints: Endpoint[], mountInfo: Map<string, string>): string {
  if (endpoints.length === 0) {
    return "_No endpoints defined yet._\n";
  }

  // Sort: GET first, then POST, then others. Within method, sort by path.
  const methodOrder: Method[] = ["GET", "POST", "PUT", "DELETE", "PATCH", "HEAD", "OPTIONS"];
  const sorted = [...endpoints].sort((a, b) => {
    const ma = methodOrder.indexOf(a.method);
    const mb = methodOrder.indexOf(b.method);
    if (ma !== mb) return ma - mb;
    return a.path.localeCompare(b.path);
  });

  const rows = sorted.map((e) => {
    // Find mount for this endpoint's file
    const fileBase = path.basename(e.file, ".ts");
    const mount = mountInfo.get(fileBase) ?? "/";
    const full = fullPath(mount, e.path);
    return `| \`${e.method}\` | \`${full}\` | ${e.description} |`;
  });

  return [
    "| Method | Path | Description |",
    "|---|---|---|",
    ...rows,
    "",
    `_${endpoints.length} endpoint${endpoints.length === 1 ? "" : "s"} across ${new Set(endpoints.map((e) => e.file)).size} route file${new Set(endpoints.map((e) => e.file)).size === 1 ? "" : "s"}._`,
    "",
    "_Auto-generated by `npm run sync:readme`. Don't edit by hand._",
  ].join("\n");
}

/** Read README.md, replace the block between ENDPOINTS_START and ENDPOINTS_END. */
function updateReadme(readmePath: string, newTable: string): boolean {
  const content = fs.readFileSync(readmePath, "utf-8");
  const startMarker = "<!-- ENDPOINTS_START -->";
  const endMarker = "<!-- ENDPOINTS_END -->";

  const startIdx = content.indexOf(startMarker);
  const endIdx = content.indexOf(endMarker);
  if (startIdx === -1 || endIdx === -1) {
    console.error(`❌ Markers not found in ${readmePath}. Add:`);
    console.error(`   ${startMarker}`);
    console.error(`   ${endMarker}`);
    process.exit(1);
  }

  const before = content.slice(0, startIdx + startMarker.length);
  const after = content.slice(endIdx);
  const newContent = `${before}\n\n${newTable}\n${after}`;

  if (newContent === content) return false;
  fs.writeFileSync(readmePath, newContent);
  return true;
}

// ============================================================================
// Main
// ============================================================================
function main() {
  const args = process.argv.slice(2);
  const check = args.includes("--check");
  const updateIdx = args.indexOf("--update");
  const updatePath = updateIdx !== -1 ? args[updateIdx + 1] : null;

  // Collect all route files
  if (!fs.existsSync(ROUTES_DIR)) {
    console.error(`❌ Routes directory not found: ${ROUTES_DIR}`);
    process.exit(1);
  }
  const files = fs
    .readdirSync(ROUTES_DIR)
    .filter((f) => f.endsWith(".ts") && !f.endsWith(".test.ts"))
    .map((f) => path.join(ROUTES_DIR, f));

  // Parse all routes
  const allEndpoints: Endpoint[] = [];
  for (const file of files) {
    allEndpoints.push(...parseRoutesFile(file));
  }

  // Get mount info
  const mountInfo = getMountInfo();

  // Generate table
  const table = toMarkdown(allEndpoints, mountInfo);

  if (updatePath) {
    const changed = updateReadme(updatePath, table);
    if (changed) {
      console.log(`✅ Updated ${updatePath} with ${allEndpoints.length} endpoints`);
    } else {
      console.log(`✓  ${updatePath} is already in sync (${allEndpoints.length} endpoints)`);
    }
    return;
  }

  if (check) {
    const readmePath = path.join(REPO_ROOT, "README.md");
    const currentContent = fs.readFileSync(readmePath, "utf-8");
    const startMarker = "<!-- ENDPOINTS_START -->";
    const endMarker = "<!-- ENDPOINTS_END -->";
    const startIdx = currentContent.indexOf(startMarker);
    const endIdx = currentContent.indexOf(endMarker);
    if (startIdx === -1 || endIdx === -1) {
      console.error(`❌ Markers not found in README.md`);
      process.exit(1);
    }
    const currentBlock = currentContent.slice(startIdx, endIdx + endMarker.length);
    const expectedBlock = `${startMarker}\n\n${table}\n${endMarker}`;
    if (currentBlock.trim() !== expectedBlock.trim()) {
      console.error(`❌ README.md is out of sync with src/routes/`);
      console.error(`   Run: npm run sync:readme`);
      process.exit(1);
    }
    console.log(`✓  README.md is in sync (${allEndpoints.length} endpoints)`);
    return;
  }

  // Default: print to stdout
  console.log(table);
}

main();
