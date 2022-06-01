FROM fedora:35 AS builder

RUN yum install -y git gcc flex bison diffutils elfutils-libelf-devel bc

WORKDIR /workspace

RUN git clone --depth 1 https://github.com/cloud-hypervisor/linux.git -b ch-5.15.12 linux-cloud-hypervisor
COPY kernel/linux-config-x86_64 /workspace/linux-cloud-hypervisor/.config
RUN cd linux-cloud-hypervisor && KCFLAGS="-Wa,-mx86-used-note=no" make bzImage -j `nproc`

FROM smartxworks/kubrid-kernel-base

COPY --from=builder /workspace/linux-cloud-hypervisor/arch/x86/boot/compressed/vmlinux.bin /vmlinux