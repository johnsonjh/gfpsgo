# gfpsgo for Linux

[![Codacy Badge](https://api.codacy.com/project/badge/Grade/70e5cccdcc1a418cb7e8c2302f818220)](https://app.codacy.com/gh/gridfinity/gfpsgo?utm_source=github.com&utm_medium=referral&utm_content=gridfinity/gfpsgo&utm_campaign=Badge_Grade)

## Availability

### Go Modules

- [go.gridfinity.dev](https://go.gridfinity.dev/gfpsgo)
- [go.gridfinity.com](https://go.gridfinity.com)

### Source Code

- [Gridfinity GitLab](https://gitlab.gridfinity.com/go/gfpsgo)
- [SourceHut](https://sr.ht/~trn/gfpsgo)
- [GitHub](https://github.com/gridfinity/gfpsgo)

### Issue Tracking

- [Gridfinity GitLab Issues](https://gitlab.gridfinity.com/go/gfpsgo/-/issues)

## Code of Conduct

- While we "inherit" the
  [_Containers Community Code of Conduct_](https://github.com/containers/common/blob/master/CODE-OF-CONDUCT.md)
  from the upstream `psgo` project, Gridfinity will **_NOT_** enforce this Code
  of Conduct. We furthermore recommend that any users of the this version of the
  software have **no interaction** with the greater "_Containers Community_". If
  you decide to ignore this advice, you must expect that community to exercise
  their authority as they see fit per the Code of Conduct, and in any way they
  deem appropriate. Gridfinity will _NOT_ intervene or offer any assistance or
  intervene in any upstream disputes.

## Security Policy

- We **do not** follow the _Containers Community Security Policy_ in any way.
  Please review our Gridfinity-specific
  [Security Policy and Vulnerability Reporting](https://gitlab.gridfinity.com/go/gfpsgo/-/blob/master/SECURITY.md)
  document for all details. **DO NOT** bother the upstream maintainers, or their
  community, for matters regarding this version of the software.

## Overview

`gfpsgo` is a `ps`(`1`) (AIX-format compatible) Go library and tool, extended
with various descriptors useful for displaying container-related data.

The idea behind the library is to provide an easy to use way of extracting
process-related data, just as `ps`(`1`) tool does. The problem with using
`ps`(`1`) is that the `ps` output is formatted strings split into columns by
whitespace, which makes the output extremely impossible to automatically parse.
It also adds some jitter as we have to fork and execute `ps`, either in the
container, or filter the output afterwards, which further limits usability.

This tool and library is intended to make things more comfortable, especially
for container runtimes. An API allows joining the mount namespace of a given
process, and will parse `/proc` and `/dev/` filesystems automatically.

The API consists of the following functions:

- `gfpsgo.ProcessInfo(descriptors []string) ([][]string, error)`

  - ProcessInfo returns the process information of all processes in the
    currently mount namespace. The input descriptors must be a slice of
    supported AIX format descriptors in the normal form or in the code form, if
    supported. If the input descriptor slice is empty, the
    `gfpsgo.DefaultDescriptors` are used. The return value contain string slices
    of process data, one per process.

- `gfpsgo.ProcessInfoByPids(pids []string, descriptors []string) ([][]string, error)`

  - ProcessInfoByPids is similar to `psgo.ProcessInfo`, but limits the return
    value to a list of specified PIDs. The PIDs input must be a slice of PIDs
    for which process information should be returned. If the input descriptor
    slice is empty, only the format descriptor headers are returned.

- `psgo.JoinNamespaceAndProcessInfo(pid string, descriptors []string) ([][]string, error)`

  - JoinNamespaceAndProcessInfo has the same semantics as ProcessInfo but joins
    the mount namespace of the specified pid before extracting data from /proc.
    This way, we can extract the `/proc` data from a container without executing
    any command inside the container.

- `psgo.JoinNamespaceAndProcessInfoByPids(pids []string, descriptors []string) ([][]string, error)`

  - JoinNamespaceAndProcessInfoByPids is similar to
    `gfpsgo.JoinNamespaceAndProcessInfo` but takes a slice of PIDs as an
    argument. To avoid duplicate entries, such as when two or more containers
    share the same PID namespace, a given PID namespace will be joined only
    once.

- `psgo.ListDescriptors() []string`
  - ListDescriptors returns a sorted string slice of all supported AIX-formatted
    descriptors in their normal form (for example, "args, comm, user", etc.) It
    can be useful in the context of shell completion, help messages, etc.

## Listing all processes

We can use the `gfpsgo` tool included with the project to test the core
components of the library. First, build `gfpsgo` via `make build`. The binary is
now located under `./bin/gfpsgo`. By default `gfpsgo` displays data about all
running processes in the currently mount namespace, similar to the output of
`ps -ef`.

```shell
$ ./bin/psgo | head -n 5
USER         PID     PPID    %CPU     ELAPSED              TTY      TIME        COMMAND
root         1       0       0.064    6h3m27.677997443s    ?        13.98s      systemd
root         2       0       0.000    6h3m27.678380128s    ?        20ms        [kthreadd]
root         4       2       0.000    6h3m27.678701852s    ?        0s          [kworker/0:0H]
root         6       2       0.000    6h3m27.678999508s    ?        0s          [mm_percpu_wq]
```

## Listing specific processes

You can use the `--pids` flag to restrict `gfpsgo` output to a subset of
processes. This option accepts a list of comma separate process IDs and returns
exactly the same kind of information, only per process, as the default output.

```shell
$ ./bin/psgo --pids 1,$(pgrep bash | tr '\n' ',')
USER   PID     PPID    %CPU    ELAPSED                TTY     TIME   COMMAND
root   1       0       0.009   128h52m44.193475932s   ?       40s    systemd
root   20830   20827   0.000   105h2m44.19579679s     pts/5   0s     bash
root   25843   25840   0.000   102h56m4.196072027s    pts/6   0s     bash
```

## Listing processes within a container

Let's have a look at how we can use this tool and library in the context of
containers. As a simple show case, we'll start a Docker container, extract the
process ID via `docker-inspect` and run the `gfpsgo` binary to extract the data
of running processes within that container.

```shell
$ docker run -d alpine sleep 100
473c9a05d4223b88ef7f5a9ac11e3d21e9914e012338425cc1cef853fc6c32a2

$ docker inspect --format '{{.State.Pid}}' 473c9
5572

$ sudo ./bin/psgo -pids 5572 -join
USER   PID   PPID   %CPU    ELAPSED         TTY   TIME   COMMAND
root   1     0      0.000   17.249905587s   ?     0s     sleep
```

## Format descriptors

The `gfpsgo` library is compatible with all AIX-formatted descriptors provided
by the IBM AIX `ps`(`1`) command-line utility. (On any AIX system, execute
`man 1 ps` for more details.) It also supports additional descriptors that can
be useful when seeking specific process-related information.

- **capamb**

  - Set of ambient capabilities. See capabilities(7) for more information.

- **capbnd**

  - Set of bounding capabilities. See capabilities(7) for more information.

- **capeff**

  - Set of effective capabilities. See capabilities(7) for more information.

- **capinh**

  - Set of inheritable capabilities. See capabilities(7) for more information.

- **capprm**

  - Set of permitted capabilities. See capabilities(7) for more information.

- **hgroup**

  - The corresponding effective group of a container process on the host.

- **hpid**

  - The corresponding host PID of a container process.

- **huser**

  - The corresponding effective user of a container process on the host.

- **label**

  - Current security attributes of the process.

- **seccomp**

  - Seccomp mode of the process (disabled, strict, filter).
    - See `seccomp`(`2`) for more information.

- **state**

  - Process state codes (**R** for _running_, **S** for _sleeping_).
    - See `proc`(`5`) for more information.

- **stime**
  - Process start time (such as _"2019-12-09 10:50:36 +0100 CET"_).

We can try out different format descriptors with the `gfpsgo` tool:

```shell
$ ./bin/gfpsgo -format "pid, user, group, seccomp" | head -n 5
PID     USER         GROUP        SECCOMP
1       root         root         disabled
2       root         root         disabled
4       root         root         disabled
6       root         root         disabled
```

## License

- This software is provided under
  [The Apache 2.0 Software License](https://gitlab.gridfinity.com/go/gfpsgo/-/blob/master/LICENSE).
