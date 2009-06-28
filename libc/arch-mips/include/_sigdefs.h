/*
 * Copyright (C) 2008 The Android Open Source Project
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *  * Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 *  * Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in
 *    the documentation and/or other materials provided with the
 *    distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
 * FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
 * COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
 * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
 * BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS
 * OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED
 * AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT
 * OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 */
/* this header is used to define signal constants and names; it might be included several times */
#ifndef __BIONIC_SIGDEF
#error __BIONIC_SIGDEF not defined
#endif

__BIONIC_SIGDEF(SIGHUP,1,"Hangup")
__BIONIC_SIGDEF(SIGINT,2,"Interrupt")
__BIONIC_SIGDEF(SIGQUIT,3,"Quit")
__BIONIC_SIGDEF(SIGILL,4,"Illegal instruction")
__BIONIC_SIGDEF(SIGTRAP,5,"Trap")
__BIONIC_SIGDEF(SIGABRT,6,"Aborted")
__BIONIC_SIGDEF(SIGEMT,7,"EMT")
__BIONIC_SIGDEF(SIGFPE,8,"Floating point exception")
__BIONIC_SIGDEF(SIGKILL,9,"Killed")
__BIONIC_SIGDEF(SIGBUS,10,"Bus error")
__BIONIC_SIGDEF(SIGSEGV,11,"Segmentation fault")
__BIONIC_SIGDEF(SIGSYS,12,"Bad system call")
__BIONIC_SIGDEF(SIGPIPE,13,"Broken pipe")
__BIONIC_SIGDEF(SIGALRM,14,"Alarm clock")
__BIONIC_SIGDEF(SIGTERM,15,"Terminated")
__BIONIC_SIGDEF(SIGUSR1,16,"User signal 1")
__BIONIC_SIGDEF(SIGUSR2,17,"User signal 2")
__BIONIC_SIGDEF(SIGCHLD,18,"Child exited")
__BIONIC_SIGDEF(SIGPWR,19,"Power failure")
__BIONIC_SIGDEF(SIGWINCH,20,"Window size changed")
__BIONIC_SIGDEF(SIGURG,21,"Urgent I/O condition")
__BIONIC_SIGDEF(SIGIO,22,"I/O possible")
__BIONIC_SIGDEF(SIGSTOP,23,"Stopped (signal)")
__BIONIC_SIGDEF(SIGTSTP,24,"Stopped")
__BIONIC_SIGDEF(SIGCONT,25,"Continue")
__BIONIC_SIGDEF(SIGTTIN,26,"Stopped (tty input)")
__BIONIC_SIGDEF(SIGTTOU,27,"Stopped (tty output)")
__BIONIC_SIGDEF(SIGVTALRM,28,"Virtual timer expired")
__BIONIC_SIGDEF(SIGPROF,29,"Profiling timer expired")
__BIONIC_SIGDEF(SIGXCPU,30,"CPU time limit exceeded")
__BIONIC_SIGDEF(SIGXFSZ,31,"File size limit exceeded")

#undef __BIONIC_SIGDEF
