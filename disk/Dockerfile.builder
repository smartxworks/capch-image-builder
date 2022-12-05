FROM ubuntu:jammy AS builder

RUN apt-get update && \
    apt-get install -y qemu-system-x86 qemu-system-arm xorriso ansible curl zip

RUN curl -fsSL https://releases.hashicorp.com/packer/1.8.4/packer_1.8.4_linux_amd64.zip | funzip > /usr/bin/packer && \
    chmod +x /usr/bin/packer

WORKDIR /workspace

COPY disk/playbook.yml /workspace/
COPY disk/ubuntu_jammy.pkr.hcl /workspace/

ARG PACKER_GITHUB_API_TOKEN
ENV PACKER_GITHUB_API_TOKEN=$PACKER_GITHUB_API_TOKEN

ARG ARCH
ENV ARCH=${ARCH:-amd64}

ARG KUBERNETES_VERSION
ENV PKR_VAR_kubernetes_version=${KUBERNETES_VERSION:-1.24.0}

ARG SUDO_PASSWORD
ENV PKR_VAR_sudo_password=${SUDO_PASSWORD:-password}

RUN set -e; \
    case "${ARCH}" in \
        'amd64') \
            arch=amd64; firmware=/usr/share/OVMF/OVMF_CODE.fd; qemu_binary=qemu-system-x86_64; machine_type=q35; cpu_type=qemu64;; \
        'arm64') \
            arch=arm64; firmware=/usr/share/AAVMF/AAVMF_CODE.fd; qemu_binary=qemu-system-aarch64; machine_type=virt; cpu_type=cortex-a57;; \
        *) echo >&2 "error: unsupported architecture '${ARCH}'"; exit 1;; \
    esac; \
    packer init ubuntu_jammy.pkr.hcl; \
    packer build -var "arch=${arch}" -var "firmware=${firmware}" -var "qemu_binary=${qemu_binary}" -var "machine_type=${machine_type}" -var "cpu_type=${cpu_type}" ubuntu_jammy.pkr.hcl


FROM scratch AS exporter

COPY --from=builder /workspace/ubuntu_jammy/disk.img /
