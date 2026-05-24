.PHONY: iso installer dots packages prep clean download-repo repo

ARCHISO_WORKDIR ?= $(CURDIR)/work
ARCHISO_OUTDIR  ?= $(CURDIR)/out
INSTALLER_DIR   ?= $(CURDIR)/../linux_insatller
DOTS_DIR        ?= $(CURDIR)/../dots-hyprland

AIROOTFS        ?= $(CURDIR)/airootfs
INSTALLER_BIN   ?= $(AIROOTFS)/usr/local/bin/baklava-installer
BAKLAVA_SHARE   ?= $(AIROOTFS)/usr/share/baklava
DOTS_SHARE      ?= $(AIROOTFS)/usr/share/dots-hyprland

BAKLAVA_REPO_SRC ?= $(CURDIR)/../baklava-repo
BAKLAVA_REPO_DEST ?= $(AIROOTFS)/opt/baklava-repo
GRUB_THEMES_SRC  ?= $(CURDIR)/grub/themes
GRUB_THEMES_DEST ?= $(AIROOTFS)/usr/share/grub/themes

GITHUB_REPO     ?= sonusid1325/baklava-arch
REPO_TAG        ?= baklava-repo

prep:
	mkdir -p $(AIROOTFS)/usr/local/bin $(BAKLAVA_SHARE) $(DOTS_SHARE) $(BAKLAVA_REPO_DEST) $(GRUB_THEMES_DEST)

installer: prep
	cd $(INSTALLER_DIR) && go build -buildvcs=false -o $(INSTALLER_BIN) .

packages: prep
	cp $(CURDIR)/packages.x86_64 $(BAKLAVA_SHARE)/packages.x86_64

dots: prep
	rm -rf $(DOTS_SHARE)
	mkdir -p $(DOTS_SHARE)
	cp -a $(DOTS_DIR)/. $(DOTS_SHARE)/

# Download prebuilt packages from GitHub Releases (for CI or fresh clones)
download-repo:
	@echo "==> Downloading baklava-repo from GitHub Releases..."
	@mkdir -p $(BAKLAVA_REPO_SRC)
	@if command -v gh >/dev/null 2>&1; then \
		gh release download $(REPO_TAG) --dir $(BAKLAVA_REPO_SRC) --repo $(GITHUB_REPO) --clobber \
			&& echo "==> Downloaded packages to $(BAKLAVA_REPO_SRC)" \
			|| echo "==> WARNING: Could not download (release may not exist yet)"; \
	else \
		echo "==> WARNING: gh CLI not found, skipping download"; \
	fi

# Copy local repo to airootfs; download first if local copy doesn't exist
repo: prep
	@if [ ! -d "$(BAKLAVA_REPO_SRC)" ] || [ -z "$$(ls -A $(BAKLAVA_REPO_SRC) 2>/dev/null)" ]; then \
		echo "==> Local baklava-repo not found, attempting download..."; \
		$(MAKE) download-repo; \
	fi
	rm -rf $(BAKLAVA_REPO_DEST)
	mkdir -p $(BAKLAVA_REPO_DEST)
	cp -a $(BAKLAVA_REPO_SRC)/. $(BAKLAVA_REPO_DEST)/

themes: prep
	rm -rf $(GRUB_THEMES_DEST)
	mkdir -p $(GRUB_THEMES_DEST)
	cp -a $(GRUB_THEMES_SRC)/. $(GRUB_THEMES_DEST)/

iso: installer packages dots repo themes
	mkarchiso -v -w $(ARCHISO_WORKDIR) -o $(ARCHISO_OUTDIR) $(CURDIR)

clean:
	rm -rf $(ARCHISO_WORKDIR) $(ARCHISO_OUTDIR)


