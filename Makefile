.PHONY: iso installer dots packages prep clean

ARCHISO_WORKDIR ?= $(CURDIR)/work
ARCHISO_OUTDIR  ?= $(CURDIR)/out
INSTALLER_DIR   ?= $(CURDIR)/../linux_insatller
DOTS_DIR        ?= $(CURDIR)/../dots-hyprland

AIROOTFS        ?= $(CURDIR)/airootfs
INSTALLER_BIN   ?= $(AIROOTFS)/usr/local/bin/baklava-installer
BAKLAVA_SHARE   ?= $(AIROOTFS)/usr/share/baklava
DOTS_SHARE      ?= $(AIROOTFS)/usr/share/dots-hyprland

prep:
	mkdir -p $(AIROOTFS)/usr/local/bin $(BAKLAVA_SHARE) $(DOTS_SHARE)

installer: prep
	cd $(INSTALLER_DIR) && go build -o $(INSTALLER_BIN) .

packages: prep
	cp $(CURDIR)/packages.x86_64 $(BAKLAVA_SHARE)/packages.x86_64

dots: prep
	rm -rf $(DOTS_SHARE)
	mkdir -p $(DOTS_SHARE)
	cp -a $(DOTS_DIR)/. $(DOTS_SHARE)/

iso: installer packages dots
	mkarchiso -v -w $(ARCHISO_WORKDIR) -o $(ARCHISO_OUTDIR) $(CURDIR)

clean:
	rm -rf $(ARCHISO_WORKDIR) $(ARCHISO_OUTDIR)
