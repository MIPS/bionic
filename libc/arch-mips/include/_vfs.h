#ifndef __VFS_H_
#define __VFS_H_

/* note: this corresponds to the kernel's statfs64 type */
struct statfs {
    uint32_t        f_type;
    uint32_t        f_bsize;
    uint32_t        f_frsize;
    uint32_t        __pad;
    uint64_t        f_blocks;
    uint64_t        f_bfree;
    uint64_t        f_files;
    uint64_t        f_ffree;
    uint64_t        f_bavail;
    __kernel_fsid_t f_fsid;
    uint32_t        f_namelen;
    uint32_t        f_spare[6];
};

#endif /* __VFS_H_ */
