import type { Register } from 'claude-code'

const REPRINT = '/Users/egresh/.local/bin/reprint'

export const register: Register = on => {
  on('session.start', async ($, e, next) => {
    await $.command.register({
      name: 'reprint',
      description: '/reprint: search past replies in an fzf tmux popup; /reprint N shows reply N (1 = latest); /reprint list lists recent ones',
    })
    return next(e)
  })

  on('command.run', { command: 'reprint' }, async ($, e) => {
    const arg = (e.args ?? '').trim()
    if (arg !== '' && arg !== 'list' && !/^\d+$/.test(arg)) return { text: 'usage: /reprint [N | list]' }
    const sid = await $.session.id()
    const env = { COLUMNS: String(e.presentation?.columns ?? 80) }
    const run = (...a: string[]) => $.process.run([REPRINT, '-s', sid, ...a], { env, timeoutMs: 600000 })
    const show = async (...a: string[]) => {
      const out = await run(...a)
      return { text: out.exitCode === 0 ? out.stdout.trimEnd() : `reprint failed: ${out.stderr.trim()}` }
    }

    if (arg === 'list') return show('--list')
    if (arg !== '') return show(arg)

    // ponytail: fzf opens its own tmux popup (--tmux); outside tmux it fails and we show the plain list
    const pick = await run('--pick')
    const num = pick.stdout.trim()
    if (pick.exitCode === 0 && /^\d+$/.test(num)) return show(num)
    return /fzf exited (1|130)\b/.test(pick.stderr) ? { text: 'reprint: nothing selected' } : show('--list')
  })
}
