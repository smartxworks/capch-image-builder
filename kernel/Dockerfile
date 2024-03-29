FROM fedora:35 AS builder

ARG KERNEL_VERSION

RUN yum install -y git gcc flex bison diffutils elfutils-libelf-devel bc && \
    yum clean all

WORKDIR /workspace

RUN git clone --depth 1 https://github.com/cloud-hypervisor/linux.git -b ch-$KERNEL_VERSION linux-cloud-hypervisor
COPY kernel/linux-config-* linux-cloud-hypervisor/
RUN set -eux; \
    cd linux-cloud-hypervisor; \
    case "$(uname -m)" in \
        'x86_64') \
            cp linux-config-x86_64 .config; \
            KCFLAGS="-Wa,-mx86-used-note=no" make bzImage -j `nproc`; \
            cp arch/x86/boot/compressed/vmlinux.bin /workspace/vmlinux; \
            ;; \
        'aarch64') \
            cp linux-config-aarch64 .config; \
            make -j `nproc`; \
            cp arch/arm64/boot/Image /workspace/vmlinux; \
            ;; \
        *) echo >&2 "error: unsupported architecture '$(uname -m)'"; exit 1 ;; \
    esac

FROM smartxworks/virtink-kernel-base

COPY --from=builder /workspace/vmlinux /vmlinux
