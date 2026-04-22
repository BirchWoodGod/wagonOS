# wagonOS — Ubuntu 24.04-based, gaming-focused, DWM + ly
.PHONY: help iso iso-amd64 iso-arm64 clean purge show-config check-host prep prep-clean

LB_DIR    := live-build
INCLUDES  := $(LB_DIR)/config/includes.chroot
VERSION   := 24.04

help:
	@echo "wagonOS build targets:"
	@echo "  make check-host    Verify host has live-build and required tools"
	@echo "  make prep          Sync branding + suckless source into live-build includes"
	@echo "  make iso-amd64     Build x86_64 ISO (runs prep + check-host first)"
	@echo "  make iso-arm64     Build arm64 ISO (runs prep + check-host first)"
	@echo "  make iso           Build both architectures"
	@echo "  make clean         Run lb clean (preserves cached debs — fast rebuild)"
	@echo "  make purge         Full clean including downloaded package cache"
	@echo "  make prep-clean    Remove prep-managed files from includes tree"
	@echo "  make show-config   Show resolved lb config files"

check-host:
	@command -v lb >/dev/null 2>&1 || { echo "ERROR: live-build not installed. Run: sudo apt install live-build"; exit 1; }
	@command -v debootstrap >/dev/null 2>&1 || { echo "ERROR: debootstrap not installed. Run: sudo apt install debootstrap"; exit 1; }
	@command -v xorriso >/dev/null 2>&1 || { echo "ERROR: xorriso not installed. Run: sudo apt install xorriso"; exit 1; }
	@command -v rsync >/dev/null 2>&1 || { echo "ERROR: rsync not installed. Run: sudo apt install rsync"; exit 1; }
	@command -v isohybrid >/dev/null 2>&1 || { echo "ERROR: isohybrid not installed. Run: sudo apt install syslinux-utils"; exit 1; }
	@command -v mksquashfs >/dev/null 2>&1 || { echo "ERROR: mksquashfs not installed. Run: sudo apt install squashfs-tools"; exit 1; }
	@echo "Host OK. live-build: $$(lb --version 2>&1 | head -1)"

prep:
	@echo "[prep] Syncing branding + suckless source into $(INCLUDES)/"
	@install -d $(INCLUDES)/usr/share/wagonos/ascii
	@install -d $(INCLUDES)/usr/share/wagonos/sl
	@install -d $(INCLUDES)/etc
	@cp -f branding/ascii/wheel-40.txt branding/ascii/wheel-new.txt $(INCLUDES)/usr/share/wagonos/ascii/
	@cp -f branding/os-release $(INCLUDES)/etc/os-release
	@rsync -a --delete \
		--exclude='.git' --exclude='*.o' \
		--exclude='/dwm/dwm' --exclude='/dmenu/dmenu' \
		--exclude='/st/st' --exclude='/slstatus/slstatus' \
		suckless-source/ $(INCLUDES)/usr/share/wagonos/sl/
	@echo "[prep] Done."

prep-clean:
	rm -rf $(INCLUDES)/usr/share/wagonos
	rm -f $(INCLUDES)/etc/os-release

iso: iso-amd64 iso-arm64

iso-amd64: check-host prep
	cd $(LB_DIR) && sudo ARCH=amd64 lb config && sudo lb build

iso-arm64: check-host prep
	cd $(LB_DIR) && sudo ARCH=arm64 lb config && sudo lb build

clean:
	cd $(LB_DIR) && sudo lb clean

purge:
	cd $(LB_DIR) && sudo lb clean --purge

show-config:
	@cd $(LB_DIR) && for f in config/*; do [ -f "$$f" ] && { echo "===> $$f"; cat "$$f"; echo; }; done
