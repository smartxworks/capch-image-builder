IMAGE_REPOSITORY ?= linkinghack
KERNEL_VERSION ?= 5.15.12
CAPCH_KERNEL_IMAGE ?= $(IMAGE_REPOSITORY)/capch-kernel-$(KERNEL_VERSION)
KUBERNETES_VERSION ?= 1.27.4
CAPCH_ROOTFS_IMAGE ?= $(IMAGE_REPOSITORY)/capch-rootfs-$(KUBERNETES_VERSION)
CAPCH_ROOTFS_CDI_IMAGE ?= $(IMAGE_REPOSITORY)/capch-rootfs-cdi-$(KUBERNETES_VERSION)
CAPCH_DISK_SUDO_PASSWORD ?= password
CAPCH_DISK_IMAGE ?= $(IMAGE_REPOSITORY)/capch-disk-$(KUBERNETES_VERSION):jammy-0802
CAPCH_DISK_CDI_IMAGE ?= $(IMAGE_REPOSITORY)/capch-disk-cdi-$(KUBERNETES_VERSION):jammy-0802

all: push-kernel push-rootfs push-disk

.PHONY: push-kernel
push-kernel:
	docker buildx build --platform linux/amd64,linux/arm64 --build-arg KERNEL_VERSION=$(KERNEL_VERSION) -t $(CAPCH_KERNEL_IMAGE) -f kernel/Dockerfile --push .

.PHONY: push-rootfs
push-rootfs:
	docker buildx build --platform linux/amd64,linux/arm64 --build-arg KUBERNETES_VERSION=$(KUBERNETES_VERSION) -f rootfs/Dockerfile --push -t $(CAPCH_ROOTFS_IMAGE) .
	docker buildx build --platform linux/amd64,linux/arm64 --build-arg KUBERNETES_VERSION=$(KUBERNETES_VERSION) -f rootfs/Dockerfile --push -t $(CAPCH_ROOTFS_CDI_IMAGE) .

.PHONY: push-disk
push-disk:
	docker buildx build --build-arg "ARCH=amd64" --build-arg PACKER_GITHUB_API_TOKEN=$(PACKER_GITHUB_API_TOKEN) --build-arg KUBERNETES_VERSION=$(KUBERNETES_VERSION) --build-arg SUDO_PASSWORD=$(CAPCH_DISK_SUDO_PASSWORD) -f disk/Dockerfile.builder -o disk/out/linux/amd64 .
	docker buildx build --build-arg "ARCH=arm64" --build-arg PACKER_GITHUB_API_TOKEN=$(PACKER_GITHUB_API_TOKEN) --build-arg KUBERNETES_VERSION=$(KUBERNETES_VERSION) --build-arg SUDO_PASSWORD=$(CAPCH_DISK_SUDO_PASSWORD) -f disk/Dockerfile.builder -o disk/out/linux/arm64 .

	docker buildx build --platform linux/amd64,linux/arm64 -f disk/Dockerfile --push -t $(CAPCH_DISK_IMAGE) .
	docker buildx build --platform linux/amd64,linux/arm64 -f disk/Dockerfile.cdi --push -t $(CAPCH_DISK_CDI_IMAGE) .
