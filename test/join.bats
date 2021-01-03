#!/usr/bin/env bats

function is_podman_available()
{
	if podman help >> /dev/null; then
		printf %s\\n 1
		return
	fi
	printf %s\\n 0
}

@test "Join namespace of a Docker container" {
	ID="$(docker run -d alpine sleep 100)"
	PID="$(docker inspect --format '{{.State.Pid}}' "${ID:?}")"

	printf %s\\n "(calling sudo)"
	run sudo ./bin/gfpsgo -pids "${PID:?}" -join
	[ "${status:-}" -eq 0 ]
	[[ ${lines[1]:?} =~ "sleep" ]]

	docker rm -f "${ID:?}"
}

@test "Join namespace of a Docker container and format" {
	ID="$(docker run -d alpine sleep 100)"
	PID="$(docker inspect --format '{{.State.Pid}}' "${ID}")"

	printf %s\\n "(calling sudo)"
	run sudo ./bin/gfpsgo -pids "${PID:?}" -join -format "pid, group, args"
	[ "${status:-}" -eq 0 ]
	[[ ${lines[0]:?} == "PID   GROUP   COMMAND" ]]
	[[ ${lines[1]:?} =~ "1     root    sleep 100" ]]

	docker rm -f "${ID:?}"
}

@test "Join namespace of a Docker container and check capabilities" {
	ID="$(docker run --privileged -d alpine sleep 100)"
	PID="$(docker inspect --format '{{.State.Pid}}' "${ID:?}")"

	printf %s\\n "(calling sudo)"
	run sudo ./bin/gfpsgo -pids "${PID:?}" -join -format "pid, capeff"
	[ "${status:-}" -eq 0 ]
	[[ ${lines[0]:?} == "PID   EFFECTIVE CAPS" ]]
	[[ ${lines[1]:?} =~ "1     full" ]]

	docker rm -f "${ID:?}"
}

@test "Join namespace of a Docker container and check seccomp mode" {
	# (Travis CI is broken, so run in a privileged container.)
	ID="$(docker run -d --privileged alpine sleep 100)"
	PID="$(docker inspect --format '{{.State.Pid}}' "${ID:?}")"

	printf %s\\n "(calling sudo)"
	run sudo ./bin/gfpsgo -pids "${PID:?}" --join -format "pid, seccomp"
	[ "${status:-}" -eq 0 ]
	[[ ${lines[0]:?} == "PID   SECCOMP" ]]
	[[ ${lines[1]:?} =~ "1     disabled" ]]

	docker rm -f "${ID:?}"
}

@test "Join namespace of a Docker container and extract host PID" {
	ID="$(docker run -d alpine sleep 100)"
	PID="$(docker inspect --format '{{.State.Pid}}' "${ID:?}")"

	printf %s\\n "(calling sudo)"
	run sudo ./bin/gfpsgo -pids "${PID:?}" -join -format "pid, hpid"
	[ "${status:-}" -eq 0 ]
	[[ ${lines[0]:?} == "PID   HPID" ]]
	[[ ${lines[1]:?} =~ ^1.*"${PID:?}" ]]

	docker rm -f "${ID:?}"
}

@test "Join namespace of a Docker container and extract effective host user ID" {
	ID="$(docker run -d alpine sleep 100)"
	PID="$(docker inspect --format '{{.State.Pid}}' "${ID:?}")"

	run sudo ./bin/gfpsgo -pids "${PID:?}" -join -format "pid, huser"
	[ "${status}" -eq 0 ]
	[[ ${lines[0]:?} == "PID   HUSER" ]]
	[[ ${lines[1]:?} =~ "1     root" ]]

	docker rm -f "${ID:?}"
}

@test "Join namespace of a Podman container and extract pid, {host,}user and group with {g,u}idmap" {
	enabled=$(is_podman_available)
	if [[ "${enabled:-}" -eq 0 ]]; then
		skip "Podman is not available."
	fi

	printf %s\\n "(calling sudo)"
	ID="$(sudo podman run -d --uidmap=0:300000:70000 --gidmap=0:100000:70000 alpine sleep 100)"
	printf %s\\n "(calling sudo)"
	PID="$(sudo podman inspect --format '{{.State.Pid}}' "${ID:?}")"

	printf %s\\n "(calling sudo)"
	run sudo ./bin/gfpsgo -pids "${PID:?}" -join -format "pid, user, huser, group, hgroup"
	[ "${status:-}" -eq 0 ]
	[[ ${lines[0]:?} == "PID   USER   HUSER    GROUP   HGROUP" ]]
	[[ ${lines[1]:?} =~ "1     root   300000   root    100000" ]]

	printf %s\\n "(calling sudo)"
	sudo podman rm -f "${ID:?}"
}

@test "Join namespace of a Docker container and extract effective host group ID" {
	ID="$(docker run -d alpine sleep 100)"
	PID="$(docker inspect --format '{{.State.Pid}}' "${ID:?}")"

	run sudo ./bin/gfpsgo -pids "${PID:?}" -join -format "pid, hgroup"
	[ "${status:-}" -eq 0 ]
	[[ ${lines[0]:?} == "PID   HGROUP" ]]
	[[ ${lines[1]:?} =~ "1     root" ]]

	docker rm -f "${ID:?}"
}

@test "Join namespace of a Docker container and check the process state" {
	ID="$(docker run -d alpine sleep 100)"
	PID="$(docker inspect --format '{{.State.Pid}}' "${ID}")"

	run sudo ./bin/gfpsgo -pids "${PID:?}" -join -format "pid, state"
	[ "${status:-}" -eq 0 ]
	[[ ${lines[0]:?} == "PID   STATE" ]]
	[[ ${lines[1]:?} =~ "1     S" ]]

	docker rm -f "${ID:?}"
}

@test "Run Podman pod and check for redundant entries" {
	enabled=$(is_podman_available)
	if [[ "${enabled:-}" -eq 0 ]]; then
		skip "Podman is not available."
	fi

	printf %s\\n "(calling sudo)"
	POD_ID="$(sudo podman pod create)"
	printf %s\\n "(calling sudo)"
	ID_1="$(sudo podman run --pod "${POD_ID:?}" -d alpine sleep 111)"
	printf %s\\n "(calling sudo)"
	PID_1="$(sudo podman inspect --format '{{.State.Pid}}' "${ID_1:?}")"
	printf %s\\n "(calling sudo)"
	ID_2="$(sudo podman run --pod "${POD_ID:?}" -d alpine sleep 222)"
	printf %s\\n "(calling sudo)"
	PID_2="$(sudo podman inspect --format '{{.State.Pid}}' "${ID_2:?}")"

	# The underlying idea is that is that we had redundant entries if
	# the detection of PID namespaces wouldn't work correctly.
	# printf %s\\n "(calling sudo)"
	run sudo ./bin/gfpsgo -pids "${PID_1:?},${PID_2:?}" -join -format "pid, args"
	[ "${status:-}" -eq 0 ]
	[[ ${lines[0]:?} == "PID   COMMAND" ]]
	[[ ${lines[1]:?} =~ "1     sleep 111" ]]
	[[ ${lines[2]:?} =~ "1     sleep 222" ]]
	[[ ${lines[3]:-} == "" ]]

	printf %s\\n "(calling sudo)"
	sudo podman rm -f "${ID_1:?}" "${ID_2:?}"
	printf %s\\n "(calling sudo)"
	sudo podman pod rm "${POD_ID:?}"
}

@test "Test fill-mappings" {
	if [[ -n ${TRAVIS:-} ]]; then
		skip "Travis CI is unsupported."
	fi

	run unshare -muinpfr --mount-proc true
	if [[ ${status:-} -ne 0 ]]; then
		skip "unshare unavailable or unsupported."
	fi

	unshare -muinpfr --mount-proc sleep 20 &

	PID=$(printf %s\\n $!)
	run nsenter --preserve-credentials -U -t "${PID:?}" ./bin/gfpsgo -pids "${PID:?}" -join -fill-mappings -format huser
	kill -9 "${PID:?}"
	[ "${status:-}" -eq 0 ]
	[[ ${lines[0]:?} != "root" ]]
}
