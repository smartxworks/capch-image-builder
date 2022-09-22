IMAGE_REPOSITORY ?= smartxworks
KERNEL_VERSION ?= 5.15.12
CAPCH_KERNEL_IMAGE ?= $(IMAGE_REPOSITORY)/capch-kernel-$(KERNEL_VERSION)
KUBERNETES_VERSION ?= 1.24.0
CAPCH_ROOTFS_IMAGE ?= $(IMAGE_REPOSITORY)/capch-rootfs-$(KUBERNETES_VERSION)
CAPCH_ROOTFS_CDI_IMAGE ?= $(IMAGE_REPOSITORY)/capch-rootfs-cdi-$(KUBERNETES_VERSION)

all: push-kernel push-rootfs

.PHONY: push-kernel
push-kernel:
	docker buildx build --platform linux/amd64,linux/arm64 --build-arg KERNEL_VERSION=$(KERNEL_VERSION) -t $(CAPCH_KERNEL_IMAGE) -f kernel/Dockerfile --push .

.PHONY: push-rootfs
push-rootfs:
	docker buildx build --platform linux/amd64,linux/arm64 --build-arg KUBERNETES_VERSION=$(KUBERNETES_VERSION) -f rootfs/Dockerfile --push -t $(CAPCH_ROOTFS_IMAGE) --target virtink-container-rootfs .
	docker buildx build --platform linux/amd64,linux/arm64 --build-arg KUBERNETES_VERSION=$(KUBERNETES_VERSION) -f rootfs/Dockerfile --push -t $(CAPCH_ROOTFS_CDI_IMAGE) .
