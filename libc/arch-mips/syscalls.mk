# auto-generated by gensyscalls.py, do not touch
syscall_src := 
syscall_src += arch-mips/syscalls/_exit.S
syscall_src += arch-mips/syscalls/_exit_thread.S
syscall_src += arch-mips/syscalls/__fork.S
syscall_src += arch-mips/syscalls/_waitpid.S
syscall_src += arch-mips/syscalls/__waitid.S
syscall_src += arch-mips/syscalls/__sys_clone.S
syscall_src += arch-mips/syscalls/execve.S
syscall_src += arch-mips/syscalls/__setuid.S
syscall_src += arch-mips/syscalls/getuid.S
syscall_src += arch-mips/syscalls/getgid.S
syscall_src += arch-mips/syscalls/geteuid.S
syscall_src += arch-mips/syscalls/getegid.S
syscall_src += arch-mips/syscalls/getresuid.S
syscall_src += arch-mips/syscalls/getresgid.S
syscall_src += arch-mips/syscalls/gettid.S
syscall_src += arch-mips/syscalls/getgroups.S
syscall_src += arch-mips/syscalls/getpgid.S
syscall_src += arch-mips/syscalls/getppid.S
syscall_src += arch-mips/syscalls/setsid.S
syscall_src += arch-mips/syscalls/setgid.S
syscall_src += arch-mips/syscalls/__setreuid.S
syscall_src += arch-mips/syscalls/__setresuid.S
syscall_src += arch-mips/syscalls/setresgid.S
syscall_src += arch-mips/syscalls/__brk.S
syscall_src += arch-mips/syscalls/kill.S
syscall_src += arch-mips/syscalls/tkill.S
syscall_src += arch-mips/syscalls/__ptrace.S
syscall_src += arch-mips/syscalls/__set_thread_area.S
syscall_src += arch-mips/syscalls/__getpriority.S
syscall_src += arch-mips/syscalls/setpriority.S
syscall_src += arch-mips/syscalls/setrlimit.S
syscall_src += arch-mips/syscalls/getrlimit.S
syscall_src += arch-mips/syscalls/getrusage.S
syscall_src += arch-mips/syscalls/setgroups.S
syscall_src += arch-mips/syscalls/setpgid.S
syscall_src += arch-mips/syscalls/setregid.S
syscall_src += arch-mips/syscalls/chroot.S
syscall_src += arch-mips/syscalls/prctl.S
syscall_src += arch-mips/syscalls/capget.S
syscall_src += arch-mips/syscalls/capset.S
syscall_src += arch-mips/syscalls/sigaltstack.S
syscall_src += arch-mips/syscalls/acct.S
syscall_src += arch-mips/syscalls/read.S
syscall_src += arch-mips/syscalls/write.S
syscall_src += arch-mips/syscalls/pread64.S
syscall_src += arch-mips/syscalls/pwrite64.S
syscall_src += arch-mips/syscalls/__open.S
syscall_src += arch-mips/syscalls/__openat.S
syscall_src += arch-mips/syscalls/close.S
syscall_src += arch-mips/syscalls/lseek.S
syscall_src += arch-mips/syscalls/__llseek.S
syscall_src += arch-mips/syscalls/getpid.S
syscall_src += arch-mips/syscalls/__mmap2.S
syscall_src += arch-mips/syscalls/munmap.S
syscall_src += arch-mips/syscalls/mremap.S
syscall_src += arch-mips/syscalls/msync.S
syscall_src += arch-mips/syscalls/mprotect.S
syscall_src += arch-mips/syscalls/madvise.S
syscall_src += arch-mips/syscalls/mlock.S
syscall_src += arch-mips/syscalls/munlock.S
syscall_src += arch-mips/syscalls/mincore.S
syscall_src += arch-mips/syscalls/__ioctl.S
syscall_src += arch-mips/syscalls/readv.S
syscall_src += arch-mips/syscalls/writev.S
syscall_src += arch-mips/syscalls/__fcntl.S
syscall_src += arch-mips/syscalls/flock.S
syscall_src += arch-mips/syscalls/fchmod.S
syscall_src += arch-mips/syscalls/dup.S
syscall_src += arch-mips/syscalls/pipe2.S
syscall_src += arch-mips/syscalls/dup2.S
syscall_src += arch-mips/syscalls/select.S
syscall_src += arch-mips/syscalls/ftruncate.S
syscall_src += arch-mips/syscalls/ftruncate64.S
syscall_src += arch-mips/syscalls/getdents.S
syscall_src += arch-mips/syscalls/fsync.S
syscall_src += arch-mips/syscalls/fdatasync.S
syscall_src += arch-mips/syscalls/fchown.S
syscall_src += arch-mips/syscalls/sync.S
syscall_src += arch-mips/syscalls/__fcntl64.S
syscall_src += arch-mips/syscalls/__fstatfs64.S
syscall_src += arch-mips/syscalls/sendfile.S
syscall_src += arch-mips/syscalls/fstatat.S
syscall_src += arch-mips/syscalls/mkdirat.S
syscall_src += arch-mips/syscalls/fchownat.S
syscall_src += arch-mips/syscalls/fchmodat.S
syscall_src += arch-mips/syscalls/renameat.S
syscall_src += arch-mips/syscalls/link.S
syscall_src += arch-mips/syscalls/unlink.S
syscall_src += arch-mips/syscalls/unlinkat.S
syscall_src += arch-mips/syscalls/chdir.S
syscall_src += arch-mips/syscalls/mknod.S
syscall_src += arch-mips/syscalls/chmod.S
syscall_src += arch-mips/syscalls/chown.S
syscall_src += arch-mips/syscalls/lchown.S
syscall_src += arch-mips/syscalls/mount.S
syscall_src += arch-mips/syscalls/umount2.S
syscall_src += arch-mips/syscalls/fstat.S
syscall_src += arch-mips/syscalls/stat.S
syscall_src += arch-mips/syscalls/lstat.S
syscall_src += arch-mips/syscalls/mkdir.S
syscall_src += arch-mips/syscalls/readlink.S
syscall_src += arch-mips/syscalls/rmdir.S
syscall_src += arch-mips/syscalls/rename.S
syscall_src += arch-mips/syscalls/__getcwd.S
syscall_src += arch-mips/syscalls/access.S
syscall_src += arch-mips/syscalls/symlink.S
syscall_src += arch-mips/syscalls/fchdir.S
syscall_src += arch-mips/syscalls/truncate.S
syscall_src += arch-mips/syscalls/__statfs64.S
syscall_src += arch-mips/syscalls/pause.S
syscall_src += arch-mips/syscalls/gettimeofday.S
syscall_src += arch-mips/syscalls/settimeofday.S
syscall_src += arch-mips/syscalls/times.S
syscall_src += arch-mips/syscalls/nanosleep.S
syscall_src += arch-mips/syscalls/clock_gettime.S
syscall_src += arch-mips/syscalls/clock_settime.S
syscall_src += arch-mips/syscalls/clock_getres.S
syscall_src += arch-mips/syscalls/clock_nanosleep.S
syscall_src += arch-mips/syscalls/getitimer.S
syscall_src += arch-mips/syscalls/setitimer.S
syscall_src += arch-mips/syscalls/__timer_create.S
syscall_src += arch-mips/syscalls/__timer_settime.S
syscall_src += arch-mips/syscalls/__timer_gettime.S
syscall_src += arch-mips/syscalls/__timer_getoverrun.S
syscall_src += arch-mips/syscalls/__timer_delete.S
syscall_src += arch-mips/syscalls/utimes.S
syscall_src += arch-mips/syscalls/utimensat.S
syscall_src += arch-mips/syscalls/sigaction.S
syscall_src += arch-mips/syscalls/sigprocmask.S
syscall_src += arch-mips/syscalls/__sigsuspend.S
syscall_src += arch-mips/syscalls/__rt_sigaction.S
syscall_src += arch-mips/syscalls/__rt_sigprocmask.S
syscall_src += arch-mips/syscalls/__rt_sigtimedwait.S
syscall_src += arch-mips/syscalls/sigpending.S
syscall_src += arch-mips/syscalls/socket.S
syscall_src += arch-mips/syscalls/socketpair.S
syscall_src += arch-mips/syscalls/bind.S
syscall_src += arch-mips/syscalls/connect.S
syscall_src += arch-mips/syscalls/listen.S
syscall_src += arch-mips/syscalls/accept.S
syscall_src += arch-mips/syscalls/getsockname.S
syscall_src += arch-mips/syscalls/getpeername.S
syscall_src += arch-mips/syscalls/sendto.S
syscall_src += arch-mips/syscalls/recvfrom.S
syscall_src += arch-mips/syscalls/shutdown.S
syscall_src += arch-mips/syscalls/setsockopt.S
syscall_src += arch-mips/syscalls/getsockopt.S
syscall_src += arch-mips/syscalls/sendmsg.S
syscall_src += arch-mips/syscalls/recvmsg.S
syscall_src += arch-mips/syscalls/sched_setscheduler.S
syscall_src += arch-mips/syscalls/sched_getscheduler.S
syscall_src += arch-mips/syscalls/sched_yield.S
syscall_src += arch-mips/syscalls/sched_setparam.S
syscall_src += arch-mips/syscalls/sched_getparam.S
syscall_src += arch-mips/syscalls/sched_get_priority_max.S
syscall_src += arch-mips/syscalls/sched_get_priority_min.S
syscall_src += arch-mips/syscalls/sched_rr_get_interval.S
syscall_src += arch-mips/syscalls/sched_setaffinity.S
syscall_src += arch-mips/syscalls/__sched_getaffinity.S
syscall_src += arch-mips/syscalls/__getcpu.S
syscall_src += arch-mips/syscalls/ioprio_set.S
syscall_src += arch-mips/syscalls/ioprio_get.S
syscall_src += arch-mips/syscalls/uname.S
syscall_src += arch-mips/syscalls/__wait4.S
syscall_src += arch-mips/syscalls/umask.S
syscall_src += arch-mips/syscalls/__reboot.S
syscall_src += arch-mips/syscalls/__syslog.S
syscall_src += arch-mips/syscalls/init_module.S
syscall_src += arch-mips/syscalls/delete_module.S
syscall_src += arch-mips/syscalls/klogctl.S
syscall_src += arch-mips/syscalls/sysinfo.S
syscall_src += arch-mips/syscalls/personality.S
syscall_src += arch-mips/syscalls/futex.S
syscall_src += arch-mips/syscalls/epoll_create.S
syscall_src += arch-mips/syscalls/epoll_ctl.S
syscall_src += arch-mips/syscalls/epoll_wait.S
syscall_src += arch-mips/syscalls/inotify_init.S
syscall_src += arch-mips/syscalls/inotify_add_watch.S
syscall_src += arch-mips/syscalls/inotify_rm_watch.S
syscall_src += arch-mips/syscalls/poll.S
syscall_src += arch-mips/syscalls/eventfd.S
syscall_src += arch-mips/syscalls/_flush_cache.S
