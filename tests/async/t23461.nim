discard """
  targets: "c cpp"
  disabled: "windows"
"""

import std/[asyncdispatch, asyncfile, posix]

proc testPipe() {.async.} =
  var fds: array[2, cint]
  doAssert pipe(fds) == 0
  defer: discard posix.close(fds[1])

  let reader = newAsyncFile(AsyncFD(fds[0]))
  defer: reader.close()

  # Fail rather than hanging in read if the descriptor is still blocking.
  let flags = fcntl(fds[0], F_GETFL)
  doAssert flags != -1 and (flags and O_NONBLOCK) != 0

  let pending = reader.read(1)
  doAssert not pending.finished
  await sleepAsync(1)
  doAssert not pending.finished
  doAssert posix.write(fds[1], "x".cstring, 1) == 1
  doAssert await pending.withTimeout(2_000)
  doAssert pending.read() == "x"

waitFor testPipe()
