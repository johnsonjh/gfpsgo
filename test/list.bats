#!/usr/bin/env bats

@test "List descriptors" {
	run ./bin/gfpsgo -list
	[ "${status:-}" -eq 0 ]
	[[ ${lines[0]:?} =~ "args, capamb, capbnd, capeff, capinh, capprm, comm, etime, group, hgroup, hpid, huser, label, nice, pcpu, pgid, pid, ppid, rgroup, rss, ruser, seccomp, state, stime, time, tty, user, vsz" ]]
}
