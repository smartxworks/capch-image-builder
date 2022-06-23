FROM ubuntu:jammy AS rootfs

RUN apt-get update -y && \
    apt-get install -y --no-install-recommends systemd-sysv udev lsb-release cloud-init sudo curl gnupg && \
    rm -rf /var/lib/apt/lists/*

RUN echo "net.bridge.bridge-nf-call-iptables  = 1 \n\
net.bridge.bridge-nf-call-ip6tables = 1 \n\
net.ipv4.ip_forward                 = 1" >> /etc/sysctl.d/k8s.conf

RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu jammy stable" | tee /etc/apt/sources.list.d/docker.list
RUN apt-get update -y && \
    apt-get install -y --no-install-recommends containerd.io && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /etc/containerd && containerd config default | sed 's/SystemdCgroup = false/SystemdCgroup = true/' > /etc/containerd/config.toml
RUN systemctl enable containerd

RUN curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | tee /etc/apt/sources.list.d/kubernetes.list
RUN apt-get update -y && \
    apt-get install -y --no-install-recommends kubelet=1.24.0-00 kubeadm=1.24.0-00 kubectl=1.24.0-00 && \
    rm -rf /var/lib/apt/lists/* && \
    apt-mark hold kubelet kubeadm kubectl

RUN systemctl enable kubelet

FROM smartxworks/virtink-container-rootfs-base

COPY --from=rootfs / /rootfs
RUN ln -sf ../run/systemd/resolve/stub-resolv.conf /rootfs/etc/resolv.conf
