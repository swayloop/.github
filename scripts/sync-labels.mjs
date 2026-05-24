#!/usr/bin/env node

const args = parseArgs(process.argv.slice(2));
const repo = args.repo || process.env.GITHUB_REPOSITORY;
const labelsPath = args.labels || '.github/labels.yml';
const token = process.env.GITHUB_TOKEN || process.env.GH_TOKEN;

if (!repo || !repo.includes('/')) {
  fail('Missing repo. Pass --repo owner/name or set GITHUB_REPOSITORY.');
}

if (!token) {
  fail('Missing token. Set GITHUB_TOKEN or GH_TOKEN.');
}

const labels = parseLabels(await readText(labelsPath));

if (labels.length === 0) {
  fail(`No labels found in ${labelsPath}.`);
}

const existing = await listExistingLabels(repo);
const existingByName = new Map(existing.map((label) => [label.name, label]));

for (const label of labels) {
  const current = existingByName.get(label.name);
  if (!current) {
    await createLabel(repo, label);
    console.log(`created: ${label.name}`);
    continue;
  }

  if (
    normalizeColor(current.color) !== normalizeColor(label.color) ||
    (current.description || '') !== (label.description || '')
  ) {
    await updateLabel(repo, label);
    console.log(`updated: ${label.name}`);
  } else {
    console.log(`ok: ${label.name}`);
  }
}

function parseArgs(values) {
  const parsed = {};
  for (let index = 0; index < values.length; index += 1) {
    const value = values[index];
    if (value === '--repo') {
      parsed.repo = values[++index];
    } else if (value === '--labels') {
      parsed.labels = values[++index];
    }
  }
  return parsed;
}

async function readText(filePath) {
  const fs = await import('node:fs/promises');
  return fs.readFile(filePath, 'utf8');
}

function parseLabels(source) {
  const labels = [];
  let current = null;

  for (const rawLine of source.split(/\r?\n/)) {
    const line = rawLine.trim();
    if (!line || line.startsWith('#')) continue;

    const itemMatch = line.match(/^-\s+name:\s+["']?(.+?)["']?$/);
    if (itemMatch) {
      current = { name: itemMatch[1] };
      labels.push(current);
      continue;
    }

    if (!current) continue;

    const fieldMatch = line.match(/^(color|description):\s+["']?(.*?)["']?$/);
    if (fieldMatch) {
      current[fieldMatch[1]] = fieldMatch[2];
    }
  }

  return labels.map((label) => ({
    name: label.name,
    color: normalizeColor(label.color || 'ededed'),
    description: label.description || '',
  }));
}

async function listExistingLabels(targetRepo) {
  const labels = [];
  let page = 1;

  while (true) {
    const batch = await request(`/repos/${targetRepo}/labels?per_page=100&page=${page}`);
    labels.push(...batch);
    if (batch.length < 100) return labels;
    page += 1;
  }
}

async function createLabel(targetRepo, label) {
  await request(`/repos/${targetRepo}/labels`, {
    method: 'POST',
    body: JSON.stringify(label),
  });
}

async function updateLabel(targetRepo, label) {
  await request(`/repos/${targetRepo}/labels/${encodeURIComponent(label.name)}`, {
    method: 'PATCH',
    body: JSON.stringify({
      new_name: label.name,
      color: label.color,
      description: label.description,
    }),
  });
}

async function request(path, options = {}) {
  const response = await fetch(`https://api.github.com${path}`, {
    ...options,
    headers: {
      Accept: 'application/vnd.github+json',
      Authorization: `Bearer ${token}`,
      'Content-Type': 'application/json',
      'X-GitHub-Api-Version': '2022-11-28',
      ...(options.headers || {}),
    },
  });

  if (!response.ok) {
    const text = await response.text();
    fail(`${options.method || 'GET'} ${path} failed: ${response.status} ${text}`);
  }

  if (response.status === 204) return null;
  return response.json();
}

function normalizeColor(value) {
  return value.replace(/^#/, '').toLowerCase();
}

function fail(message) {
  console.error(message);
  process.exit(1);
}
