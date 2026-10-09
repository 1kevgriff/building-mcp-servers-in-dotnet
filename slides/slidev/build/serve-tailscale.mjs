// Serve the deck on the tailnet, and nowhere else.
//
//   node build/serve-tailscale.mjs
//
// Slidev binds loopback by default, so a tailnet address cannot reach it. `--remote`
// fixes that but defaults to 0.0.0.0, which on a conference laptop also publishes the
// deck to the venue wifi. This resolves the Tailscale address and binds only to it.
//
// `--remote` also enables REMOTE CONTROL, including presenter mode, so it takes a
// password. Set SLIDEV_REMOTE_PASSWORD to choose your own; otherwise one is generated
// and printed here. Nothing is written to disk, so no secret lands in the repo.

import { spawn, execFileSync } from 'node:child_process'
import { existsSync } from 'node:fs'
import { randomBytes } from 'node:crypto'
import path from 'node:path'
import process from 'node:process'
import { fileURLToPath } from 'node:url'

const PROJECT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..')
const PORT = process.env.SLIDEV_REMOTE_PORT || '3031'

/** `tailscale` is often not on PATH on Windows even when it is installed. */
function tailscaleExe() {
  const candidates = [
    'tailscale',
    'C:\\Program Files\\Tailscale\\tailscale.exe',
    'C:\\Program Files (x86)\\Tailscale\\tailscale.exe',
    '/usr/bin/tailscale',
    '/usr/local/bin/tailscale',
    '/Applications/Tailscale.app/Contents/MacOS/Tailscale',
  ]
  for (const c of candidates) {
    try {
      if (c !== 'tailscale' && !existsSync(c)) continue
      execFileSync(c, ['version'], { stdio: 'ignore' })
      return c
    } catch { /* try the next one */ }
  }
  return null
}

const exe = tailscaleExe()
if (!exe) {
  console.error(`
  Tailscale not found. Install it, or serve locally with:  npm run dev
`)
  process.exit(1)
}

let ip = ''
try {
  ip = execFileSync(exe, ['ip', '-4'], { encoding: 'utf8' }).trim().split(/\s+/)[0]
} catch {
  console.error(`
  Could not read a Tailscale address. Is Tailscale connected?  ${exe} status
`)
  process.exit(1)
}

if (!/^100\.\d+\.\d+\.\d+$/.test(ip)) {
  console.error(`
  "${ip}" is not a tailnet address (expected 100.x.y.z). Refusing to bind, because
  binding the wrong interface would publish the deck to whatever network you are on.
`)
  process.exit(1)
}

let name = ''
try {
  const json = JSON.parse(execFileSync(exe, ['status', '--json'], { encoding: 'utf8' }))
  name = (json?.Self?.DNSName || '').replace(/\.$/, '')
} catch { /* MagicDNS name is a convenience, not a requirement */ }

const password = process.env.SLIDEV_REMOTE_PASSWORD || randomBytes(4).toString('hex')
const generated = !process.env.SLIDEV_REMOTE_PASSWORD

console.log(`
  Serving on the tailnet only - not on this machine's other networks.

    http://${ip}:${PORT}/
${name ? `    http://${name}:${PORT}/        (MagicDNS)\n` : ''}
  password   ${password}${generated ? '   (generated; set SLIDEV_REMOTE_PASSWORD to pin it)' : ''}

  Remote control and presenter mode are reachable by anyone on your tailnet.

  Slidev is about to print a "remote control" line for EVERY network interface on
  this machine - LAN, WSL, sometimes a public address. Ignore them. It enumerates
  interfaces for display; it does not reflect what is bound. Only ${ip} is
  listening, and the others refuse connections. Verify any time with:

    Get-NetTCPConnection -LocalPort ${PORT} -State Listen
`)

// Run the CLI entrypoint with this same node. Spawning `npx`/`npx.cmd` fails with
// EINVAL on Windows, because Node refuses to spawn .cmd without a shell - and using a
// shell would put the password through shell quoting.
const cli = path.join(PROJECT, 'node_modules', '@slidev', 'cli', 'bin', 'slidev.mjs')
if (!existsSync(cli)) {
  console.error(`
  Slidev is not installed. Run:  npm install
`)
  process.exit(1)
}

const child = spawn(
  process.execPath,
  [cli, '--remote', password, '--bind', ip, '--port', PORT],
  { cwd: PROJECT, stdio: 'inherit', shell: false },
)
child.on('exit', code => process.exit(code ?? 0))
