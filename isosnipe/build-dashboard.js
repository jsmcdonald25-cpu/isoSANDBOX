/**
 * Bakes snipe-latest.json directly into dashboard HTML
 * so it works as a standalone file (no server needed)
 */
const fs = require('fs');
const path = require('path');

const dataPath = path.join(__dirname, 'results', 'snipe-latest.json');
const templatePath = path.join(__dirname, 'dashboard.html');
const outPath = path.join(__dirname, 'isosnipe-live.html');

const data = JSON.parse(fs.readFileSync(dataPath, 'utf-8'));
const html = fs.readFileSync(templatePath, 'utf-8');

// Replace the fetch() call with inline data
const patched = html.replace(
  /fetch\('results\/snipe-latest\.json'\)\.then\(r=>r\.json\(\)\)/,
  `Promise.resolve(${JSON.stringify(data)})`
);

fs.writeFileSync(outPath, patched);
console.log(`Built: ${outPath} (${(fs.statSync(outPath).size / 1024).toFixed(0)}KB)`);
