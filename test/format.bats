#!/usr/bin/env bats

@test "Default header" {
	run ./bin/gfpsgo
	[ "${status:-}" -eq 0 ]
	[[ ${lines[0]:?} =~ "USER" ]]
	[[ ${lines[0]:?} =~ "PID" ]]
	[[ ${lines[0]:?} =~ "PPID" ]]
	[[ ${lines[0]:?} =~ "%CPU" ]]
	[[ ${lines[0]:?} =~ "ELAPSED" ]]
	[[ ${lines[0]:?} =~ "TTY" ]]
	[[ ${lines[0]:?} =~ "TIME" ]]
	[[ ${lines[0]:?} =~ "COMMAND" ]]
}

@test "%CPU header" {
	run ./bin/gfpsgo -format "%C"
	[ "${status:-}" -eq 0 ]
	[[ ${lines[0]:?} =~ "%CPU" ]]

	run ./bin/gfpsgo -format "pcpu"
	[ "${status:-}" -eq 0 ]
	[[ ${lines[0]:?} =~ "%CPU" ]]
}

@test "GROUP header" {
	run ./bin/gfpsgo -format "%G"
	[ "${status:-}" -eq 0 ]
	[[ ${lines[0]:?} =~ "GROUP" ]]

	run ./bin/gfpsgo -format "group"
	[ "${status:-}" -eq 0 ]
	[[ ${lines[0]:?} =~ "GROUP" ]]
}

@test "PPID header" {
	run ./bin/gfpsgo -format "%P"
	[ "${status:-}" -eq 0 ]
	[[ ${lines[0]:?} =~ "PPID" ]]

	run ./bin/gfpsgo -format "ppid"
	[ "${status:-}" -eq 0 ]
	[[ ${lines[0]:?} =~ "PPID" ]]
}

@test "USER header" {
	run ./bin/gfpsgo -format "%U"
	[ "${status:-}" -eq 0 ]
	[[ ${lines[0]:?} =~ "USER" ]]

	run ./bin/gfpsgo -format "user"
	[ "${status:-}" -eq 0 ]
	[[ ${lines[0]:?} =~ "USER" ]]
}

@test "COMMAND (args) header" {
	run ./bin/gfpsgo -format "%a"
	[ "${status:-}" -eq 0 ]
	[[ ${lines[0]:?} =~ "COMMAND" ]]

	run ./bin/gfpsgo -format "args"
	[ "${status:-}" -eq 0 ]
	[[ ${lines[0]:?} =~ "COMMAND" ]]
}

@test "COMMAND (comm) header" {
	run ./bin/gfpsgo -format "%c"
	[ "${status:-}" -eq 0 ]
	[[ ${lines[0]:?} =~ "COMMAND" ]]

	run ./bin/gfpsgo -format "comm"
	[ "${status:-}" -eq 0 ]
	[[ ${lines[0]:?} =~ "COMMAND" ]]
}

@test "RGROUP header" {
	run ./bin/gfpsgo -format "%g"
	[ "${status:-}" -eq 0 ]
	[[ ${lines[0]:?} =~ "RGROUP" ]]

	run ./bin/gfpsgo -format "rgroup"
	[ "${status:-}" -eq 0 ]
	[[ ${lines[0]:?} =~ "RGROUP" ]]
}

@test "NI" {
	run ./bin/gfpsgo -format "%n"
	[ "${status:-}" -eq 0 ]
	[[ ${lines[0]:?} =~ "NI" ]]

	run ./bin/gfpsgo -format "nice"
	[ "${status:-}" -eq 0 ]
	[[ ${lines[0]:?} =~ "NI" ]]
}

@test "PID header" {
	run ./bin/gfpsgo -format "%p"
	[ "${status:-}" -eq 0 ]
	[[ ${lines[0]:?} =~ "PID" ]]

	run ./bin/gfpsgo -format "pid"
	[ "${status:-}" -eq 0 ]
	[[ ${lines[0]:?} =~ "PID" ]]
}

@test "ELAPSED header" {
	run ./bin/gfpsgo -format "%t"
	[ "${status:-}" -eq 0 ]
	[[ ${lines[0]:?} =~ "ELAPSED" ]]

	run ./bin/gfpsgo -format "etime"
	[ "${status:-}" -eq 0 ]
	[[ ${lines[0]:?} =~ "ELAPSED" ]]
}

@test "RUSER header" {
	run ./bin/gfpsgo -format "%u"
	[ "${status:-}" -eq 0 ]
	[[ ${lines[0]:?} =~ "RUSER" ]]

	run ./bin/gfpsgo -format "ruser"
	[ "${status:-}" -eq 0 ]
	[[ ${lines[0]:?} =~ "RUSER" ]]
}

@test "TIME header" {
	run ./bin/gfpsgo -format "%x"
	[ "${status:-}" -eq 0 ]
	[[ ${lines[0]:?} =~ "TIME" ]]

	run ./bin/gfpsgo -format "time"
	[ "${status:-}" -eq 0 ]
	[[ ${lines[0]:?} =~ "TIME" ]]
}

@test "TTY header" {
	run ./bin/gfpsgo -format "%y"
	[ "${status:-}" -eq 0 ]
	[[ ${lines[0]:?} =~ "TTY" ]]

	run ./bin/gfpsgo -format "tty"
	[ "${status:-}" -eq 0 ]
	[[ ${lines[0]:?} =~ "TTY" ]]
}

@test "VSZ header" {
	run ./bin/gfpsgo -format "%z"
	[ "${status:-}" -eq 0 ]
	[[ ${lines[0]:?} =~ "VSZ" ]]

	run ./bin/gfpsgo -format "vsz"
	[ "${status:-}" -eq 0 ]
	[[ ${lines[0]:?} =~ "VSZ" ]]
}

@test "CAPAMB header" {
	run ./bin/gfpsgo -format "capamb"
	[ "${status:-}" -eq 0 ]
	[[ ${lines[0]:?} =~ "AMBIENT CAPS" ]]
}

@test "CAPINH header" {
	run ./bin/gfpsgo -format "capinh"
	[ "${status:-}" -eq 0 ]
	[[ ${lines[0]:?} =~ "INHERITED CAPS" ]]
}

@test "CAPPRM header" {
	run ./bin/gfpsgo -format "capprm"
	[ "${status:-}" -eq 0 ]
	[[ ${lines[0]:?} =~ "PERMITTED CAPS" ]]
}

@test "CAPEFF header" {
	run ./bin/gfpsgo -format "capeff"
	[ "${status:-}" -eq 0 ]
	[[ ${lines[0]:?} =~ "EFFECTIVE CAPS" ]]
}

@test "CAPBND header" {
	run ./bin/gfpsgo -format "capbnd"
	[ "${status:-}" -eq 0 ]
	[[ ${lines[0]:?} =~ "BOUNDING CAPS" ]]
}

@test "SECCOMP header" {
	run ./bin/gfpsgo -format "seccomp"
	[ "${status:-}" -eq 0 ]
	[[ ${lines[0]:?} =~ "SECCOMP" ]]
}

@test "HPID header" {
	run ./bin/gfpsgo -format "hpid"
	[ "${status:-}" -eq 0 ]
	[[ ${lines[0]:?} =~ "HPID" ]]
	# host PIDs are only extracted with `-pid`
	[[ ${lines[1]:?} =~ "?" ]]
}

@test "HUSER header" {
	run ./bin/gfpsgo -format "huser"
	[ "${status:-}" -eq 0 ]
	[[ ${lines[0]:?} =~ "HUSER" ]]
	# (host users are only extracted with `-pid`)
	[[ ${lines[1]:?} =~ "?" ]]
}

@test "HGROUP header" {
	run ./bin/gfpsgo -format "hgroup"
	[ "${status:-}" -eq 0 ]
	[[ ${lines[0]:?} =~ "HGROUP" ]]
	# (host groups are only extracted with `-pid`)
	[[ ${lines[1]:?} =~ "?" ]]
}

# TODO(jhj): Use getenforcing, make test more robust.
function is_labeling_enabled()
{
	if [ -e "/usr/sbin/selinuxenabled" ] && "/usr/sbin/selinuxenabled"; then
		printf %s\\n 1
		return
	fi
	printf %s\\n 0
}

@test "LABEL header" {
	enabled=$(is_labeling_enabled)
	if [[ ${enabled:-} -eq 0 ]]; then
		skip "Labeling not enabled."
	fi
	run ./bin/gfpsgo -format "label"
	[ "${status:-}" -eq 0 ]
	[[ ${lines[0]:?} =~ "LABEL" ]]
}

@test "RSS header" {
	run ./bin/gfpsgo -format "rss"
	[ "${status:-}" -eq 0 ]
	[[ ${lines[0]:?} =~ "RSS" ]]
}

@test "STATE header" {
	run ./bin/gfpsgo -format "state"
	[ "${status:-}" -eq 0 ]
	[[ ${lines[0]:?} =~ "STATE" ]]
}

@test "STIME header" {
	run ./bin/gfpsgo -format "stime"
	[ "${status:-}" -eq 0 ]
	[[ ${lines[0]:?} =~ "STIME" ]]
}

@test "ALL header" {
	run ./bin/gfpsgo -format "pcpu, group, ppid, user, args, comm, rgroup, nice, pid, pgid, etime, ruser, time, tty, vsz, capamb, capinh, capprm, capeff, capbnd, seccomp, hpid, huser, hgroup, rss, state"
	[ "${status}" -eq 0 ]

	[[ ${lines[0]:?} =~ "%CPU" ]]
	[[ ${lines[0]:?} =~ "GROUP" ]]
	[[ ${lines[0]:?} =~ "PPID" ]]
	[[ ${lines[0]:?} =~ "USER" ]]
	[[ ${lines[0]:?} =~ "COMMAND" ]]
	[[ ${lines[0]:?} =~ "COMMAND" ]]
	[[ ${lines[0]:?} =~ "RGROUP" ]]
	[[ ${lines[0]:?} =~ "NI" ]]
	[[ ${lines[0]:?} =~ "PID" ]]
	[[ ${lines[0]:?} =~ "ELAPSED" ]]
	[[ ${lines[0]:?} =~ "RUSER" ]]
	[[ ${lines[0]:?} =~ "TIME" ]]
	[[ ${lines[0]:?} =~ "TTY" ]]
	[[ ${lines[0]:?} =~ "VSZ" ]]
	[[ ${lines[0]:?} =~ "AMBIENT CAPS" ]]
	[[ ${lines[0]:?} =~ "INHERITED CAPS" ]]
	[[ ${lines[0]:?} =~ "PERMITTED CAPS" ]]
	[[ ${lines[0]:?} =~ "EFFECTIVE CAPS" ]]
	[[ ${lines[0]:?} =~ "BOUNDING CAPS" ]]
	[[ ${lines[0]:?} =~ "SECCOMP" ]]
	[[ ${lines[0]:?} =~ "HPID" ]]
	[[ ${lines[0]:?} =~ "HUSER" ]]
	[[ ${lines[0]:?} =~ "HGROUP" ]]
	[[ ${lines[0]:?} =~ "RSS" ]]
	[[ ${lines[0]:?} =~ "STATE" ]]
}
