KUBERNETES_VERSION ?= 1.24.0
IMAGE_REPOSITORY ?= smartxworks
CAPCH_ROOTFS_IMAGE ?= $(IMAGE_REPOSITORY)/capch-rootfs-$(KUBERNETES_VERSION)
CAPCH_ROOTFS_CDI_IMAGE ?= $(IMAGE_REPOSITORY)/capch-rootfs-cdi-$(KUBERNETES_VERSION)

all: build push

.PHONY: build
build:
	iidfile=$$(mktemp /tmp/iid-XXXXXX) && \
	imagesfile=$$(mktemp /tmp/images-XXXXXX) && \
	docker build --build-arg KUBERNETES_VERSION=$(KUBERNETES_VERSION) --target rootfs -f rootfs/Dockerfile --iidfile $$iidfile . && \
	docker run --rm $$(cat $$iidfile) kubeadm config images list --kubernetes-version $(KUBERNETES_VERSION) > $$imagesfile && \
	cat $$imagesfile | xargs -L 1 ctr image pull && \
	cat $$imagesfile | xargs ctr image export rootfs/images-$(KUBERNETES_VERSION).tar && \
	rm -rf $$iidfile $$imagesfile && \
	docker build --build-arg KUBERNETES_VERSION=$(KUBERNETES_VERSION) --target virtink-container-rootfs -t $(CAPCH_ROOTFS_IMAGE) -f rootfs/Dockerfile . && \
	docker build --build-arg KUBERNETES_VERSION=$(KUBERNETES_VERSION) -t $(CAPCH_ROOTFS_CDI_IMAGE) -f rootfs/Dockerfile . && \
	rm -rf rootfs/images-$(KUBERNETES_VERSION).tar

.PHONY: push
push:
	docker push $(CAPCH_ROOTFS_IMAGE)
	docker push $(CAPCH_ROOTFS_CDI_IMAGE)
