import { test, expect } from 'claude-code/testing'

const ok = (stdout: string, exitCode = 0, stderr = '') => ({ value: { exitCode, stdout, stderr, isStdoutTruncated: false, isStderrTruncated: false } })

test('/reprint N and /reprint list call the script', async ($, on) => {
  const calls: (readonly string[])[] = []
  on('session.id', async () => ({ value: 'sid-1' }))
  on('process.run', async (_$, e) => { calls.push(e.argv); return ok('hello\n') })
  expect((await $.command.run({ command: 'reprint', args: '3' })).text).toBe('hello')
  await $.command.run({ command: 'reprint', args: 'list' })
  expect(calls[0]).toContain('3')
  expect(calls[1]).toContain('--list')
  expect((await $.command.run({ command: 'reprint', args: 'abc' })).text).toContain('usage')
})

test('/reprint picks with fzf, then shows the chosen reply', async ($, on) => {
  const calls: (readonly string[])[] = []
  on('session.id', async () => ({ value: 'sid-1' }))
  on('process.run', async (_$, e) => { calls.push(e.argv); return ok(e.argv.includes('--pick') ? '7\n' : 'reply seven\n') })
  const out = await $.command.run({ command: 'reprint', args: '' })
  expect(calls[0]).toContain('--pick')
  expect(calls[1]).toContain('7')
  expect(out.text).toBe('reply seven')
})

test('/reprint cancelled, and fzf unavailable', async ($, on) => {
  let n = 0
  on('session.id', async () => ({ value: 'sid-1' }))
  on('process.run', async (_$, e) => {
    if (!e.argv.includes('--pick')) return ok('listing')
    return n++ === 0 ? ok('', 1, 'fzf exited 130 after 2.1s') : ok('', 2, 'fzf: no tty')
  })
  expect((await $.command.run({ command: 'reprint', args: '' })).text).toContain('nothing selected')
  expect((await $.command.run({ command: 'reprint', args: '' })).text).toBe('listing')
})
