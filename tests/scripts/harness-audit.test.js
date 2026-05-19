/**
 * Tests for scripts/harness-audit.js
 */

const assert = require('assert');
const fs = require('fs');
const os = require('os');
const path = require('path');
const { execFileSync } = require('child_process');

const SCRIPT = path.join(__dirname, '..', '..', 'scripts', 'harness-audit.js');

function createTempDir(prefix) {
  return fs.mkdtempSync(path.join(os.tmpdir(), prefix));
}

function cleanup(dirPath) {
  fs.rmSync(dirPath, { recursive: true, force: true });
}

function run(args = [], options = {}) {
  const stdout = execFileSync('node', [SCRIPT, ...args], {
    cwd: options.cwd || path.join(__dirname, '..', '..'),
    env: {
      ...process.env,
      HOME: options.homeDir || process.env.HOME,
    },
    encoding: 'utf8',
    stdio: ['pipe', 'pipe', 'pipe'],
    timeout: 10000,
  });

  return stdout;
}

function test(name, fn) {
  try {
    fn();
    console.log(`  \u2713 ${name}`);
    return true;
  } catch (error) {
    console.log(`  \u2717 ${name}`);
    console.log(`    Error: ${error.message}`);
    return false;
  }
}

function runTests() {
  console.log('\n=== Testing harness-audit.js ===\n');

  let passed = 0;
  let failed = 0;

  if (test('json output is deterministic between runs', () => {
    const first = run(['repo', '--format', 'json']);
    const second = run(['repo', '--format', 'json']);

    assert.strictEqual(first, second);
  })) passed++; else failed++;

  if (test('report includes bounded scores and fixed categories', () => {
    const parsed = JSON.parse(run(['repo', '--format', 'json']));

    assert.strictEqual(parsed.deterministic, true);
    assert.strictEqual(parsed.rubric_version, '2026-05-19');
    assert.strictEqual(parsed.target_mode, 'repo');
    assert.ok(parsed.overall_score >= 0);
    assert.ok(parsed.max_score > 0);
    assert.ok(parsed.overall_score <= parsed.max_score);

    const categoryNames = Object.keys(parsed.categories);
    assert.ok(categoryNames.includes('Tool Coverage'));
    assert.ok(categoryNames.includes('Context Efficiency'));
    assert.ok(categoryNames.includes('Quality Gates'));
    assert.ok(categoryNames.includes('Memory Persistence'));
    assert.ok(categoryNames.includes('Eval Coverage'));
    assert.ok(categoryNames.includes('Security Guardrails'));
    assert.ok(categoryNames.includes('Cost Efficiency'));
    assert.ok(categoryNames.includes('GitHub Integration'));
  })) passed++; else failed++;

  if (test('report exposes applicable_categories and category_count', () => {
    const parsed = JSON.parse(run(['repo', '--format', 'json']));

    assert.ok(Array.isArray(parsed.applicable_categories), 'applicable_categories must be an array');
    assert.ok(parsed.applicable_categories.length > 0);
    assert.strictEqual(typeof parsed.category_count, 'number');
    assert.strictEqual(parsed.category_count, parsed.applicable_categories.length);
    for (const name of parsed.applicable_categories) {
      assert.ok(parsed.categories[name].max > 0, `${name} must have max > 0 to be applicable`);
    }
  })) passed++; else failed++;

  if (test('GitHub Integration category scores against a fully-wired consumer fixture', () => {
    const homeDir = createTempDir('harness-audit-home-gh-');
    const projectRoot = createTempDir('harness-audit-project-gh-');

    try {
      fs.mkdirSync(path.join(homeDir, '.claude', 'plugins', 'everything-claude-code', '.claude-plugin'), { recursive: true });
      fs.writeFileSync(
        path.join(homeDir, '.claude', 'plugins', 'everything-claude-code', '.claude-plugin', 'plugin.json'),
        JSON.stringify({ name: 'everything-claude-code' }, null, 2)
      );

      fs.mkdirSync(path.join(projectRoot, '.github', 'workflows'), { recursive: true });
      fs.mkdirSync(path.join(projectRoot, '.github', 'ISSUE_TEMPLATE'), { recursive: true });
      fs.writeFileSync(path.join(projectRoot, '.github', 'workflows', 'ci.yml'), 'name: ci\n');
      fs.writeFileSync(path.join(projectRoot, '.github', 'PULL_REQUEST_TEMPLATE.md'), '# PR\n');
      fs.writeFileSync(path.join(projectRoot, '.github', 'ISSUE_TEMPLATE', 'bug.md'), '# Bug\n');
      fs.writeFileSync(path.join(projectRoot, '.github', 'CODEOWNERS'), '* @owner\n');
      fs.writeFileSync(path.join(projectRoot, '.github', 'dependabot.yml'), 'version: 2\n');
      fs.writeFileSync(path.join(projectRoot, 'package.json'), JSON.stringify({ name: 'gh-test' }));

      const parsed = JSON.parse(run(['repo', '--format', 'json'], { cwd: projectRoot, homeDir }));
      const github = parsed.categories['GitHub Integration'];

      assert.ok(github, 'GitHub Integration category must exist');
      assert.strictEqual(github.score, 10, `GitHub Integration should score 10/10, got ${github.score}`);
      assert.strictEqual(github.earned, github.max);
    } finally {
      cleanup(homeDir);
      cleanup(projectRoot);
    }
  })) passed++; else failed++;

  if (test('Vercel Integration category is omitted when no Vercel marker present', () => {
    const homeDir = createTempDir('harness-audit-home-novercel-');
    const projectRoot = createTempDir('harness-audit-project-novercel-');

    try {
      fs.mkdirSync(path.join(homeDir, '.claude', 'plugins', 'everything-claude-code', '.claude-plugin'), { recursive: true });
      fs.writeFileSync(
        path.join(homeDir, '.claude', 'plugins', 'everything-claude-code', '.claude-plugin', 'plugin.json'),
        JSON.stringify({ name: 'everything-claude-code' }, null, 2)
      );
      fs.writeFileSync(path.join(projectRoot, 'package.json'), JSON.stringify({ name: 'p' }));

      const parsed = JSON.parse(run(['repo', '--format', 'json'], { cwd: projectRoot, homeDir }));

      assert.ok(!parsed.applicable_categories.includes('Vercel Integration'));
      const vercel = parsed.categories['Vercel Integration'];
      assert.ok(!vercel || vercel.max === 0, 'Vercel Integration should not contribute when no marker');
    } finally {
      cleanup(homeDir);
      cleanup(projectRoot);
    }
  })) passed++; else failed++;

  if (test('Vercel Integration category scores when vercel.json present', () => {
    const homeDir = createTempDir('harness-audit-home-vercel-');
    const projectRoot = createTempDir('harness-audit-project-vercel-');

    try {
      fs.mkdirSync(path.join(homeDir, '.claude', 'plugins', 'everything-claude-code', '.claude-plugin'), { recursive: true });
      fs.writeFileSync(
        path.join(homeDir, '.claude', 'plugins', 'everything-claude-code', '.claude-plugin', 'plugin.json'),
        JSON.stringify({ name: 'everything-claude-code' }, null, 2)
      );

      fs.mkdirSync(path.join(projectRoot, '.github', 'workflows'), { recursive: true });
      fs.writeFileSync(path.join(projectRoot, 'vercel.json'), '{}\n');
      fs.writeFileSync(path.join(projectRoot, '.env.example'), 'VERCEL_TOKEN=\n');
      fs.writeFileSync(path.join(projectRoot, '.github', 'workflows', 'deploy.yml'), 'uses: amondnet/vercel-action@v25\n');
      fs.writeFileSync(
        path.join(projectRoot, 'package.json'),
        JSON.stringify({ name: 'p', scripts: { build: 'next build', deploy: 'vercel deploy' } })
      );

      const parsed = JSON.parse(run(['repo', '--format', 'json'], { cwd: projectRoot, homeDir }));
      const vercel = parsed.categories['Vercel Integration'];

      assert.ok(vercel, 'Vercel Integration category must exist when vercel.json present');
      assert.ok(vercel.max > 0);
      assert.ok(parsed.applicable_categories.includes('Vercel Integration'));
      assert.strictEqual(vercel.score, 10, `Vercel should score 10/10 with full wiring, got ${vercel.score}`);
    } finally {
      cleanup(homeDir);
      cleanup(projectRoot);
    }
  })) passed++; else failed++;

  if (test('detector map: Netlify, Cloudflare, Fly each trigger their category', () => {
    const homeDir = createTempDir('harness-audit-home-multi-');

    function probe(markerFile, markerContents, expectedCategory) {
      const root = createTempDir('harness-audit-project-multi-');
      try {
        fs.writeFileSync(path.join(root, 'package.json'), JSON.stringify({ name: 'p' }));
        fs.writeFileSync(path.join(root, markerFile), markerContents);
        const parsed = JSON.parse(run(['repo', '--format', 'json'], { cwd: root, homeDir }));
        assert.ok(parsed.applicable_categories.includes(expectedCategory),
          `${markerFile} should activate ${expectedCategory}`);
      } finally {
        cleanup(root);
      }
    }

    try {
      fs.mkdirSync(path.join(homeDir, '.claude', 'plugins', 'everything-claude-code', '.claude-plugin'), { recursive: true });
      fs.writeFileSync(
        path.join(homeDir, '.claude', 'plugins', 'everything-claude-code', '.claude-plugin', 'plugin.json'),
        JSON.stringify({ name: 'everything-claude-code' }, null, 2)
      );

      probe('netlify.toml', '[build]\n', 'Netlify Integration');
      probe('wrangler.toml', 'name = "p"\n', 'Cloudflare Integration');
      probe('fly.toml', 'app = "p"\n', 'Fly Integration');
    } finally {
      cleanup(homeDir);
    }
  })) passed++; else failed++;

  if (test('max_score reflects only applicable categories', () => {
    const homeDir = createTempDir('harness-audit-home-max-');
    const noVercel = createTempDir('harness-audit-project-max-novercel-');
    const withVercel = createTempDir('harness-audit-project-max-vercel-');

    try {
      fs.mkdirSync(path.join(homeDir, '.claude', 'plugins', 'everything-claude-code', '.claude-plugin'), { recursive: true });
      fs.writeFileSync(
        path.join(homeDir, '.claude', 'plugins', 'everything-claude-code', '.claude-plugin', 'plugin.json'),
        JSON.stringify({ name: 'everything-claude-code' }, null, 2)
      );

      fs.writeFileSync(path.join(noVercel, 'package.json'), JSON.stringify({ name: 'p' }));
      fs.writeFileSync(path.join(withVercel, 'package.json'), JSON.stringify({ name: 'p' }));
      fs.writeFileSync(path.join(withVercel, 'vercel.json'), '{}\n');

      const noVercelParsed = JSON.parse(run(['repo', '--format', 'json'], { cwd: noVercel, homeDir }));
      const withVercelParsed = JSON.parse(run(['repo', '--format', 'json'], { cwd: withVercel, homeDir }));

      assert.ok(withVercelParsed.max_score > noVercelParsed.max_score,
        `with-vercel max_score (${withVercelParsed.max_score}) should exceed no-vercel (${noVercelParsed.max_score})`);
    } finally {
      cleanup(homeDir);
      cleanup(noVercel);
      cleanup(withVercel);
    }
  })) passed++; else failed++;

  if (test('non-git directory does not crash the script', () => {
    const homeDir = createTempDir('harness-audit-home-bare-');
    const bare = createTempDir('harness-audit-project-bare-');

    try {
      fs.mkdirSync(path.join(homeDir, '.claude', 'plugins', 'everything-claude-code', '.claude-plugin'), { recursive: true });
      fs.writeFileSync(
        path.join(homeDir, '.claude', 'plugins', 'everything-claude-code', '.claude-plugin', 'plugin.json'),
        JSON.stringify({ name: 'everything-claude-code' }, null, 2)
      );
      fs.writeFileSync(path.join(bare, 'package.json'), JSON.stringify({ name: 'p' }));

      const output = run(['repo', '--format', 'json'], { cwd: bare, homeDir });
      const parsed = JSON.parse(output);
      assert.ok(parsed.overall_score >= 0);
      assert.ok(parsed.max_score > 0);
    } finally {
      cleanup(homeDir);
      cleanup(bare);
    }
  })) passed++; else failed++;

  if (test('scope filtering changes max score and check list', () => {
    const full = JSON.parse(run(['repo', '--format', 'json']));
    const scoped = JSON.parse(run(['hooks', '--format', 'json']));

    assert.strictEqual(scoped.scope, 'hooks');
    assert.ok(scoped.max_score < full.max_score);
    assert.ok(scoped.checks.length < full.checks.length);
    assert.ok(scoped.checks.every(check => check.path.includes('hooks') || check.path.includes('scripts/hooks')));
  })) passed++; else failed++;

  if (test('text format includes summary header', () => {
    const output = run(['repo']);
    assert.ok(output.includes('Harness Audit (repo, repo):'));
    assert.ok(output.includes('Top 3 Actions:') || output.includes('Checks:'));
  })) passed++; else failed++;

  if (test('audits consumer projects from cwd instead of the ECC repo root', () => {
    const homeDir = createTempDir('harness-audit-home-');
    const projectRoot = createTempDir('harness-audit-project-');

    try {
      fs.mkdirSync(path.join(homeDir, '.claude', 'plugins', 'everything-claude-code', '.claude-plugin'), { recursive: true });
      fs.writeFileSync(
        path.join(homeDir, '.claude', 'plugins', 'everything-claude-code', '.claude-plugin', 'plugin.json'),
        JSON.stringify({ name: 'everything-claude-code' }, null, 2)
      );

      fs.mkdirSync(path.join(projectRoot, '.github', 'workflows'), { recursive: true });
      fs.mkdirSync(path.join(projectRoot, 'tests'), { recursive: true });
      fs.mkdirSync(path.join(projectRoot, '.claude'), { recursive: true });
      fs.writeFileSync(path.join(projectRoot, 'AGENTS.md'), '# Project instructions\n');
      fs.writeFileSync(path.join(projectRoot, '.mcp.json'), JSON.stringify({ mcpServers: {} }, null, 2));
      fs.writeFileSync(path.join(projectRoot, '.gitignore'), 'node_modules\n.env\n');
      fs.writeFileSync(path.join(projectRoot, '.github', 'workflows', 'ci.yml'), 'name: ci\n');
      fs.writeFileSync(path.join(projectRoot, 'tests', 'app.test.js'), 'test placeholder\n');
      fs.writeFileSync(path.join(projectRoot, '.claude', 'settings.json'), JSON.stringify({ hooks: ['PreToolUse'] }, null, 2));
      fs.writeFileSync(
        path.join(projectRoot, 'package.json'),
        JSON.stringify({ name: 'consumer-project', scripts: { test: 'node tests/app.test.js' } }, null, 2)
      );

      const parsed = JSON.parse(run(['repo', '--format', 'json'], { cwd: projectRoot, homeDir }));

      assert.strictEqual(parsed.target_mode, 'consumer');
      assert.strictEqual(parsed.root_dir, fs.realpathSync(projectRoot));
      assert.ok(parsed.overall_score > 0, 'Consumer project should receive non-zero score when harness signals exist');
      assert.ok(parsed.checks.some(check => check.id === 'consumer-plugin-install' && check.pass));
      assert.ok(parsed.checks.every(check => !check.path.startsWith('agents/') && !check.path.startsWith('skills/')));
    } finally {
      cleanup(homeDir);
      cleanup(projectRoot);
    }
  })) passed++; else failed++;

  console.log(`\nResults: Passed: ${passed}, Failed: ${failed}`);
  process.exit(failed > 0 ? 1 : 0);
}

runTests();
