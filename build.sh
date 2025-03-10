#!/bin/bash
# build.sh - Android Kernel Build Script to k5.x
# Make sure clang is added to your path before using this script
# Semi-automatic script suitable for use in Ubuntu, Debian, Kali and NetHunter
# Author Madara273
# ----------------------------------------------------------------------------

# ---- Define colors (real ESC via $'...') ----
GREEN=$'\033[0;32m'
RED=$'\033[0;31m'
YELLOW=$'\033[1;33m'
PURPLE=$'\033[0;35m'
MAGENTA=$'\033[1;35m'
LGREEN=$'\033[92m'
PINK=$'\033[38;5;206m'
CYAN=$'\033[0;36m'
BLUE=$'\033[0;34m'
GREY=$'\033[38;5;250m'   # light grey (256-color)
NC=$'\033[0m'            # reset

# ---- Get the absolute path of the current directory ----
CURRENT_DIR="$(pwd)"

# ---- Set Eastern Time timezone ----
export TZ=Europe/Kiev # Enter your time zone

# ---- random_color - generates a random color for output to the terminal ----
random_color() {
	local colors=($GREEN $RED $YELLOW $PURPLE $BLUE)	# Array of colors
	local random_index=$((RANDOM % ${#colors[@]}))		# Random index
	echo -e "${colors[$random_index]}"			# For color interpretation
}

# ---- Get information about the distribution and its version ----
. /etc/os-release 2>/dev/null || { OS=$(uname -s); VERSION_ID=$(uname -r); }

# ---- Output information to the terminal -----
echo -e "\n$(random_color)━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "    - OS: $NAME $VERSION_ID"
echo -e "    - Kernel: $(uname -r)"
echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"

# ----  ASCII Art Logo with random colors ----
ascii_art_logo() {
	echo -e "
$(random_color)********************************NEUTRINO********************************${NC}
$(random_color) ______ ______ _______ _______ _______ _______ ___ ___ ______ _______ ${NC}
$(random_color)|   __ \   __ \       |_     _|       |_     _|   |   |   __ \    ___|${NC}
$(random_color)|    __/      <   -   | |   | |   -   | |   |  \     /|    __/    ___|${NC}
$(random_color)|___|  |___|__|_______| |___| |_______| |___|   |___| |___|  |_______|${NC}
"
}

# ---- Prompt user for input ----
echo -e "${PURPLE}Enter KBUILD_USER:${NC}"
read -t 5 -rp "KBUILD_USER: " KBUILD_USER
KBUILD_USER="${KBUILD_USER:-Madara273}"	# If user doesn't enter a value, use "Madara273"
echo "$KBUILD_USER"	# Output the value of KBUILD_USER

echo -e "${PURPLE}Enter KBUILD_HOST:${NC}"
read -t 5 -rp "KBUILD_HOST: " KBUILD_HOST
KBUILD_HOST="${KBUILD_HOST:-Kali_GNU/Linux-2026.1}"	# If user doesn't enter a value, use "Kali_GNU/Linux-2026.1"
echo "$KBUILD_HOST"	# Output the value of KBUILD_HOST

# ----  Set environment variables ----
export CLANG_TRIPLE="aarch64-linux-gnu-"
export CROSS_COMPILE="aarch64-linux-gnu-"
export CROSS_COMPILE_ARM32="arm-linux-gnueabi-"

THREAD="${1:-$(nproc --all)}"
CC_ADDITIONAL_FLAGS="LLVM_IAS=1 LLVM=1 -Wno-error=unused-function"

# ---- Target Variables ----
TARGET_ARCH="arm64"
TARGET_SUBARCH="arm64"
TARGET_CC="clang"
TARGET_HOSTLD="ld.lld"
TARGET_CLANG_TRIPLE="aarch64-linux-gnu-"
TARGET_CROSS_COMPILE="aarch64-linux-gnu-"
TARGET_CROSS_COMPILE_COMPAT="arm-linux-gnueabi-"
TARGET_BUILD_USER="$KBUILD_USER"
TARGET_BUILD_HOST="$KBUILD_HOST"
TARGET_DEVICE="spes-perf"
TARGET_PRODUCT="$TARGET_DEVICE"
TARGET_OUT="$(pwd)/../NEUTRINO_OUT"
TARGET_DTC_FLAGS="-q"

TARGET_COMPILER_STRING="$COMPILER_STRING"
TARGET_LD_VERSION="$LD_VERSION"
TARGET_CC_VERSION="$CC_VERSION"

# ---- Kernel target parameters ----
TARGET_KERNEL_FILE="$TARGET_OUT/arch/arm64/boot/Image.gz"
TARGET_KERNEL_DTBO_IMG="$TARGET_OUT/arch/arm64/boot/dtbo.img"
TARGET_KERNEL_NAME="Kernel"
get_kernel_version(){
	TARGET_KERNEL_MOD_VERSION="$(make kernelversion O=$TARGET_OUT ARCH=arm64)"
}

# ---- Final kernel build parameters ----
FINAL_KERNEL_BUILD_PARA="ARCH=$TARGET_ARCH \
				SUBARCH=$TARGET_SUBARCH \
				HOSTLD=$TARGET_HOSTLD \
				CC=$TARGET_CC \
				CROSS_COMPILE=$TARGET_CROSS_COMPILE \
				CROSS_COMPILE_COMPAT=$TARGET_CROSS_COMPILE_COMPAT \
				CLANG_TRIPLE=$TARGET_CLANG_TRIPLE \
				$CC_ADDITIONAL_FLAGS \
				DTC_FLAGS=$TARGET_DTC_FLAGS \
				O=$TARGET_OUT \
				CC_VERSION=$TARGET_CC_VERSION \
				LD_VERSION=$TARGET_LD_VERSION \
				TARGET_PRODUCT=$TARGET_DEVICE \
				KBUILD_COMPILER_STRING=$TARGET_COMPILER_STRING \
				KBUILD_BUILD_USER=$TARGET_BUILD_USER \
				KBUILD_BUILD_HOST=$TARGET_BUILD_HOST \
				-j$THREAD"

# ----  Defconfig parameters ----
DEFCONFIG_PATH=arch/arm64/configs
DEFCONFIG_NAME="spes-perf_defconfig"

# ---- Time parameters ----
START_SEC=$(date +%s)
CURRENT_TIME=$(date '+%Y%m%d-%H%M')

# ---- Setup secure keystore paths ----
HOME="${HOME:-/tmp}"
[ "$HOME" = "/" ] && HOME="/tmp"
SIGNER_DIR="$HOME/.neutrino"

KEYSTORE="$SIGNER_DIR/keystore.p12"
PASSFILE="$SIGNER_DIR/.store_pass"
ALIASFILE="$SIGNER_DIR/.alias"
ROOTCA_KEY="$SIGNER_DIR/rootCA.key"
ROOTCA_CERT="$SIGNER_DIR/rootCA.pem"
TENZO_KEY="$SIGNER_DIR/tenzo.key"
TENZO_CERT="$SIGNER_DIR/tenzo.crt"
P12_FILE="$SIGNER_DIR/tenzo.p12"
CSR_FILE="$SIGNER_DIR/tenzo.csr"

# ---- Logging / Output ----
AK3_PATH="$TARGET_OUT/AnyKernel3"
LOG_FILE="$AK3_PATH/build.log"
WARNING_PATTERN="warning"
ERROR_PATTERN="error"
NORMAL_PATTERN="normal"

# ---- Getting information about git remote, branch and commit ----
remote=$(git remote -v 2>&1 | grep push | head -n1 | cut -f2 | sed "s/(push)//" | cut -f4 -d "/")
domain=$(git remote -v 2>&1 | grep push | head -n1 | cut -f2 | sed "s/(push)//" | cut -f5 -d "/" | xargs)
branch=$(git status 2>&1 | grep "On branch" | sed -e 's/On branch //g')
commit=$(git rev-parse --short=8 HEAD)

# ----  Kernel DIR ----
KERNEL_DIR=$(pwd)
echo -e "${GREEN}$KERNEL_DIR${NC}"

# Function to display build information
display_build_info(){

    echo -e "${PURPLE}***************Neutrino-Kernel**************${NC}"
    echo -e "PRODUCT: $TARGET_DEVICE"
    echo -e "USER: $KBUILD_USER"
    echo -e "HOST: $KBUILD_HOST"
    echo -e "SUBLEVEL: $(grep -E '^SUBLEVEL =' Makefile | awk '{print $3}')"
    echo -e "${PURPLE}***************Device-Builder**************${NC}"
    echo -e "BUILD_DEVICE: $(lsb_release -a)"
    echo -e "Compiler: $(clang --version | head -n 1)"
    echo -e "Core count: $(nproc)"
    echo -e "Build Date: $(date +"%Y-%m-%d %H:%M")"
    echo -e "${PURPLE}*************last commit details***********${NC}"
    echo -e "Last commit (name): $(git log -1 --pretty=format:%s)"
    echo -e "Last commit (hash): $(git log -1 --pretty=format:%H)"
    echo -e "${PURPLE}*******************************************${NC}"
}

# Function for interactive action selection with timeout
choose_action(){
    while true; do
        echo -e "Choose an action:"
        echo -e "${GREEN}1.👉 Install necessary packages${NC}"
        echo -e "${GREEN}2.👉 Start kernel compilation${NC}"
        echo -e "${GREEN}3.👉 Exit program${NC}"

        # Set timeout for user input (5 seconds)
        read -t 5 -p "Enter the action number (1/2/3): " choice

        # If no input is provided within 5 seconds, default to action 1 and then 2
        [ -z "$choice" ] && echo -e "${YELLOW}No input detected. Automatically selecting action 1.${NC}" && install_packages && echo -e "${YELLOW}Proceeding to action 2 automatically.${NC}" && compile_kernel && break

        case $choice in
            1 ) install_packages;;
            2 ) compile_kernel;;
            3 ) exit;;
            * ) echo -e "${RED}Invalid choice. Please enter 1, 2, or 3.${NC}";;
        esac
    done
}

# Function for "smart" installation
pkg_install() {
	if [ -f /etc/arch-release ]; then
		[ -n "$1" ] && sudo pacman -S --needed --noconfirm "$1"
	else
		[ -n "$2" ] && sudo apt-get install -y "$2"
	fi
}

# Install packages
install_packages(){
	echo -e "${YELLOW}Starting package installation...${NC}"

	# pkg_install "Name Arch" "Name Debian"
	pkg_install "bc" "bc"
	pkg_install "bison" "bison"
	pkg_install "base-devel" "build-essential"
	pkg_install "zstd" "zstd"
	pkg_install "clang" "clang"
	pkg_install "lld" "lld"
	pkg_install "flex" "flex"
	pkg_install "gnupg" "gnupg"
	pkg_install "gperf" "gperf"
	pkg_install "ccache" "ccache"
	pkg_install "lz4" "liblz4-tool"
	pkg_install "sdl12-compat" "libsdl1.2-dev"
	pkg_install "libxml2" "libxml2"
	pkg_install "" "libxml2-utils"
	pkg_install "libpng" "pngcrush"
	pkg_install "schedtool" "schedtool"
	pkg_install "squashfs-tools" "squashfs-tools"
	pkg_install "libxslt" "xsltproc"
	pkg_install "zlib" "zlib1g-dev"
	pkg_install "ncurses" "libncurses5-dev"
	pkg_install "bzip2" "bzip2"
	pkg_install "git" "git"
	pkg_install "gcc" "gcc"
	pkg_install "gcc" "g++"
	pkg_install "openssl" "libssl-dev"
	pkg_install "openssl" "openssl"
	pkg_install "aarch64-linux-gnu-gcc" "gcc-aarch64-linux-gnu"
	pkg_install "llvm" "llvm"
	pkg_install "python-pip" "python3-pip"
	pkg_install "cpio" "cpio"
	pkg_install "binutils" "binutils"
	pkg_install "zip" "zip"
	pkg_install "dtc" "device-tree-compiler"
	pkg_install "jdk21-openjdk" "default-jre"
	pkg_install "jdk21-openjdk" "openjdk-21-jdk"

	echo -e "${GREEN}Necessary packages successfully installed.${NC}"
}
# Clone Anykernel3
clone_anykernel3(){
    while true; do
        echo -e "${YELLOW}Select branch to clone or skip:${NC}"
        echo -e "${BLUE}1.👉 Neutrino${NC}"
        echo -e "${BLUE}2.👉 Custom git clone command${NC}"
        echo -e "${BLUE}3.👉 Skip${NC}"

        # Set timeout for user input (5 seconds)
        read -t 5 -rp "Enter your choice (1, 2, or 3): " choice

        # If no input is provided within 5 seconds, default to action 1 (Neutrino)
        [ -z "$choice" ] && echo -e "${YELLOW}No input detected. Automatically selecting Neutrino.${NC}" && choice=1

        case $choice in
            1)
                branch="spes"
                git clone --depth=1 https://github.com/Madara273/AnyKernel3.git -b "$branch" "$AK3_PATH" && { echo -e "${GREEN}Clone successful.${NC}"; break; } || echo -e "${RED}Clone failed.${NC}"
                ;;
            2)
                while true; do
                    read -rp "Enter the full git clone command (e.g., git clone https://github.com/username/repository.git -b branch_name): " clone_command
                    # Execute the custom command and check its success
                    eval "$clone_command" && { echo -e "${GREEN}Clone successful.${NC}"; break; } || echo -e "${RED}Clone failed. Please try again.${NC}"
                done
                return 0
                ;;
            3)
                echo -e "${YELLOW}Skipping AnyKernel3 cloning.${NC}"
                return 0
                ;;
            *)
                echo -e "${RED}Invalid choice. Please try again.${NC}"
                ;;
        esac
    done
}

# Function to check for necessary tools
check_tools(){
    echo -e "${YELLOW}Checking for necessary tools...${NC}"
    command -v clang > /dev/null 2>&1 || { echo -e "${RED}clang is not installed.${NC}"; exit 1; }
    command -v make > /dev/null 2>&1 || { echo -e "${RED}make is not installed.${NC}"; exit 1; }
    command -v mke2fs > /dev/null 2>&1 || { echo -e "${RED}mke2fs is not installed.${NC}"; exit 1; }
    echo -e "${GREEN}All necessary tools are installed.${NC}"
}

# Function to create default kernel configuration
make_defconfig(){
    echo -e "${YELLOW}------------------------------${NC}"
    echo -e "${YELLOW} Generating kernel configuration...${NC}"
    make $FINAL_KERNEL_BUILD_PARA $DEFCONFIG_NAME || { echo -e "${RED}Failed to create default kernel configuration.${NC}"; exit 1; }
    echo -e "${GREEN}Default kernel configuration created successfully.${NC}"
    echo -e "${YELLOW}------------------------------${NC}"
}

# Function for building a kernel with color output and countdown
build_kernel() {

	echo -e "${YELLOW}---------------------------------------${NC}"
	echo -e "${YELLOW} Building the kernel...${NC}"
	echo -e "${YELLOW}---------------------------------------${NC}"

	set -e  # Exit on error

	# ---- Colored logger (stdout + log file) ----
	log_echo() {
		local color="$1"
		shift
		local message="$*"

		echo -e "${color}${message}${NC}"
		echo -e "${color}${message}${NC}" >> "$LOG_FILE"
	}

	# ---- Time tracking ----
	START_SEC=$(date +%s)

	TIME_COLOR="$BLUE"

	declare -A COLORS=(
		[normal]="$GREEN"
		[warning]="$PURPLE"
		[error]="$RED"
	)

	# ---- Kernel build with realtime log parsing ----
	make $FINAL_KERNEL_BUILD_PARA 2>&1 | while IFS= read -r line; do

		CURRENT_SEC=$(date +%s)
		ELAPSED_SEC=$(( CURRENT_SEC - START_SEC ))

		TIME_FMT=$(printf "%02d:%02d" $(( ELAPSED_SEC / 60 )) $(( ELAPSED_SEC % 60 )))

		level="normal"
		[[ $line =~ $WARNING_PATTERN ]] && level="warning"
		[[ $line =~ $ERROR_PATTERN   ]] && level="error"

		log_echo "${TIME_COLOR}${TIME_FMT} ${COLORS[$level]}" "$line"

	done

	# ---- Module installation ----
	MODULES_DIR="$TARGET_OUT/modules_inst"
	mkdir -p "$MODULES_DIR"

	GREP_Y=$(grep -rn '^CONFIG_MODULES=y$' "$AK3_PATH/defconfig") && {
		echo -e "${GREEN}${GREP_Y}${NC}"
		echo -e "${YELLOW}---------------------------------------${NC}"
		echo -e "${YELLOW} Installing kernel modules...${NC}"
		echo -e "${YELLOW}---------------------------------------${NC}"

		make $FINAL_KERNEL_BUILD_PARA INSTALL_MOD_PATH="$MODULES_DIR" INSTALL_MOD_STRIP=1 modules_install

		echo -e "${GREEN}Kernel modules ready (external .ko files available)${NC}"
		} || {
		GREP_NOT_SET=$(grep -rn '^# CONFIG_MODULES is not set$' "$AK3_PATH/defconfig") && {
			echo -e "${PURPLE}${GREP_NOT_SET}${NC}"
			echo -e "${PURPLE}# CONFIG_MODULES is not set — all features built-in to kernel${NC}"
			} || {
			echo -e "${RED}Unexpected CONFIG_MODULES value — check $AK3_PATH/defconfig!${NC}"
		}
	}

	# ---- Total build time ----
	END_SEC=$(date +%s)
	TOTAL_SEC=$(( END_SEC - START_SEC ))

	echo -e "${GREEN}Kernel build took $(( TOTAL_SEC / 60 ))m $(( TOTAL_SEC % 60 ))s${NC}" \
		| tee -a "$LOG_FILE"
}

# ---- Generate a secure keystore with a trusted cert for ZIP/APK signing ----
generate_secure_keystore() {
	[[ -f "$KEYSTORE" ]] && echo -e "${GREEN}✔ Keystore already exists: $KEYSTORE${NC}" && return

	echo -e "${YELLOW}Creating new keystore and full trust chain...${NC}"

	rm -rf "$SIGNER_DIR"
	mkdir -p "$SIGNER_DIR" && chmod 700 "$SIGNER_DIR"

	PASS=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 18)
	UNIQUE_ID=$(date +%Y%m%d_%H%M%S)
	KEYALIAS="tenzoKey_${UNIQUE_ID}"

	echo "$PASS" > "$PASSFILE"
	echo "$KEYALIAS" > "$ALIASFILE"
	chmod 600 "$PASSFILE" "$ALIASFILE"

	echo -e "${CYAN}Generating root CA...${NC}" &&
	openssl genrsa -out "$ROOTCA_KEY" 4096 &&
	openssl req -x509 -new -nodes -key "$ROOTCA_KEY" -sha256 -days 9125 \
		-out "$ROOTCA_CERT" -subj "/CN=Tenzo Root CA/O=Madara273/C=UA" ||
	{ echo -e "${RED}✘ Root CA generation failed${NC}"; return 1; }

	echo -e "${CYAN}Generating Tenzo keypair and CSR...${NC}" &&
	openssl genrsa -out "$TENZO_KEY" 4096 &&
	openssl req -new -key "$TENZO_KEY" -out "$CSR_FILE" \
		-subj "/CN=Tenzo, OU=Root, O=Madara273, L=UA, ST=Ukraine, C=UA" ||
	{ echo -e "${RED}✘ Keypair or CSR failed${NC}"; return 1; }

	openssl x509 -req -in "$CSR_FILE" -CA "$ROOTCA_CERT" -CAkey "$ROOTCA_KEY" \
		-CAcreateserial -out "$TENZO_CERT" -sha256 -days 365 || \
	{ echo -e "${RED}✘ Signing failed${NC}"; return 1; }

	echo -e "${CYAN}Exporting to PKCS#12...${NC}" &&
	openssl pkcs12 -export \
		-inkey "$TENZO_KEY" \
		-in "$TENZO_CERT" \
		-certfile "$ROOTCA_CERT" \
		-out "$P12_FILE" \
		-password pass:"$PASS" \
		-name "$KEYALIAS" ||
	{ echo -e "${RED}✘ PKCS#12 export failed${NC}"; return 1; }

	keytool -importkeystore \
		-srckeystore "$P12_FILE" -srcstoretype PKCS12 -srcstorepass "$PASS" \
		-destkeystore "$KEYSTORE" -deststoretype PKCS12 -deststorepass "$PASS" \
		-alias "$KEYALIAS" -noprompt || \
	{ echo -e "${RED}✘ PKCS12 import failed${NC}"; return 1; }

	keytool -importcert -trustcacerts -alias "rootCA_${UNIQUE_ID}" -file "$ROOTCA_CERT" \
		-keystore "$KEYSTORE" -storepass "$PASS" -noprompt ||
	{ echo -e "${RED}✘ Failed to add rootCA to keystore${NC}"; return 1; }

	# Java truststore
	echo -e "${CYAN}Adding Root CA to Java truststore...${NC}"

	sudo keytool -list -cacerts -storepass changeit -alias "tenzoRoot" >/dev/null 2>&1 && \
	sudo keytool -delete -cacerts -storepass changeit -alias "tenzoRoot" -noprompt

	sudo keytool -importcert -alias "tenzoRoot" -file "$ROOTCA_CERT" \
		-cacerts -storepass changeit -noprompt && \
		echo -e "${GREEN}✔ Added to Java truststore (cacerts)${NC}" || \
		echo -e "${RED}✘ Failed to add to Java truststore${NC}"

	echo -e "${GREEN}✔ Keystore created: $KEYSTORE${NC}"
	show_fingerprint
}

# ----  SIGN ZIP FILE ----
sign_zip() {
	ZIP="$1"
	OUT="$2"

	[[ -f "$ZIP" ]] || {
		echo -e "${RED}✘ ZIP file not found: $ZIP${NC}"
		exit 1
	}

	generate_secure_keystore

	PASS=$(cat "$PASSFILE")
	KEYALIAS=$(cat "$ALIASFILE")

	cp "$ZIP" "$OUT"

	echo -e "${CYAN}Signing ZIP with timestamp...${NC}"
	SIGNING_OUTPUT=$(jarsigner -keystore "$KEYSTORE" -storepass "$PASS" -keypass "$PASS" \
		-sigalg SHA256withRSA -digestalg SHA-256 \
		-tsa http://timestamp.digicert.com \
		"$OUT" "$KEYALIAS" 2>&1)

	echo "$SIGNING_OUTPUT" | grep -q "jar signed." &&
	{
		echo -e "${GREEN}✔ Signed successfully: $OUT${NC}"
		echo "$SIGNING_OUTPUT" | grep -q "The timestamp will expire" &&
			echo -e "${YELLOW}$(echo "$SIGNING_OUTPUT" | grep "The timestamp will expire")${NC}"
	} || {
		echo -e "${RED}❌ Signing failed!${NC}"
		echo "$SIGNING_OUTPUT"
		exit 1
	}
}

# ---- SHOW FINGERPRINT ----
show_fingerprint() {
	[[ -f "$KEYSTORE" && -f "$PASSFILE" && -f "$ALIASFILE" ]] &&
	{
		PASS=$(cat "$PASSFILE")
		KEYALIAS=$(cat "$ALIASFILE")
		echo -e "${CYAN}SHA256 Fingerprint:${NC}"
		keytool -list -v -keystore "$KEYSTORE" -storepass "$PASS" -alias "$KEYALIAS" 2>/dev/null | grep "SHA256:"
	} || {
		echo -e "${RED}✘ Cannot display fingerprint. Keystore or data missing.${NC}"
	}
}

# ----  Generate flashable archive and sign it (Adapted from Neutrino logic) ----
generate_flashable() {
	echo -e "${YELLOW}------------------------------${NC}"
	echo -e "${YELLOW} Generating flashable kernel ${NC}"
	echo -e "${YELLOW}------------------------------${NC}"

	AK3_PATH="$TARGET_OUT/AnyKernel3"
	ANYKERNEL_PATH="AnyKernel3"

	echo -e "${YELLOW} Fetching AnyKernel ${NC}"
	cd "$TARGET_OUT" || return 1

	echo -e "${YELLOW} Copying kernel file ${NC}"
	cp -f "$TARGET_KERNEL_FILE" "$ANYKERNEL_PATH/" || echo -e "${RED}Failed to copy Image.gz${NC}"
	cp -f "$TARGET_KERNEL_DTBO_IMG" "$ANYKERNEL_PATH/" || echo -e "${RED}Failed to copy dtbo.img${NC}"

	echo -e "${YELLOW} Checking for modules... ${NC}"

	local MODULE_DIR="AnyKernel3/modules/system/lib/modules"
	local SRC_MODULES="./modules_inst/lib/modules/4.19.325_Neutrino"

	if [ -d "$SRC_MODULES" ]; then
		echo -e "${GREEN} Modules found, copying... ${NC}"
		mkdir -p "$MODULE_DIR"
		rm -rf "$MODULE_DIR"/*

		find "$SRC_MODULES" -type f -name "*.ko" -exec cp -f {} "$MODULE_DIR/" \;
		cp -f "$SRC_MODULES"/modules.{alias,dep,softdep,symbols} "$MODULE_DIR/" 2>/dev/null

		[ -f "$MODULE_DIR/modules.dep" ] && {
			echo -e "${YELLOW} Fixing paths in modules.dep... ${NC}"
			sed -i 's@\(^kernel/[^: ]*/\)\([^: ]*\.ko\)@/system/lib/modules/\2@g' "$MODULE_DIR/modules.dep"
		}

		[ -f "$SRC_MODULES/modules.order" ] && {
			cp "$SRC_MODULES/modules.order" "$MODULE_DIR/modules.load"
			sed -i 's/.*\///g' "$MODULE_DIR/modules.load"
			echo -e "${GREEN}  + Created modules.load ${NC}"
		}
	else
		echo -e "${CYAN} No modules found (CONFIG_MODULES off?). Skipping modules copy. ${NC}"
		# Видаляємо папку modules з AnyKernel, щоб не пакувати пусті директорії
		rm -rf AnyKernel3/modules
	fi

	echo -e "${YELLOW} Packing flashable kernel ${NC}"

	CURRENT_TIME="${CURRENT_TIME:-$(date +"%Y%m%d-%H%M")}"
	CLEAN_TIME=$(echo "$CURRENT_TIME" | sed 's/[^a-zA-Z0-9._-]//g')

	cd "$ANYKERNEL_PATH" || { echo -e "${RED}Failed to enter $ANYKERNEL_PATH directory.${NC}"; exit 1; }

	FLASHABLE_ZIP="Neutrino-$CLEAN_TIME.zip"
	SIGNED_ZIP="Neutrino-$CLEAN_TIME-signed.zip"

	zip -r -9 "$FLASHABLE_ZIP" * -x "README.md" "changelog.txt" "defconfig" "kernel-changelog.txt" "build.log" "Neutrino-*.zip" || {
		echo -e "${RED}Failed to pack flashable kernel.${NC}";
		exit 1;
	}

	command -v jarsigner > /dev/null && {
		echo -e "${YELLOW} Signing ZIP file... ${NC}"
		sign_zip "$FLASHABLE_ZIP" "$SIGNED_ZIP"
		echo -e "${GREEN}✔ Signed zip ready: $SIGNED_ZIP ${NC}"
	} || echo -e "${YELLOW} jarsigner not found, skipping signing. ${NC}"

	echo -e "${YELLOW} Target file: $TARGET_OUT/$ANYKERNEL_PATH/$FLASHABLE_ZIP ${NC}"

	cd "$KERNEL_DIR"
}

# Save kernel configuration with timeout
save_defconfig() {
	echo -e "${YELLOW}------------------------------${NC}"
	echo -e "${YELLOW} Saving kernel configuration...${NC}"
	echo -e "${YELLOW}------------------------------${NC}"

	[ -f "$TARGET_OUT/.config" ] && {
		cp "$TARGET_OUT/.config" "$AK3_PATH/defconfig"
		END_SEC=$(date +%s)
		COST_SEC=$((END_SEC - START_SEC))
		echo -e "${YELLOW}Completed. Kernel configuration saved to ${AK3_PATH}/defconfig${NC}"
		echo -e "${YELLOW}Kernel configuration save took ${COST_SEC} seconds.${NC}"
	} || echo -e "${RED}Error: '$TARGET_OUT/.config' not found. Cannot save configuration.${NC}"
}

# Clean
clean(){
    echo -e "${YELLOW}Cleaning source tree and build files...${NC}"
    make mrproper -j$THREAD > /dev/null 2>&1
    make clean -j$THREAD > /dev/null 2>&1
    rm -rf $TARGET_OUT
    rm -rf .config
    rm -rf output
    echo -e "${GREEN}Clean completed.${NC}"
}

# Setup colour for the script
purple='\033[0;35m'

# Function to show an informational message
msg(){
    echo -e "\e[1;32m$*\e[0m"
}

err(){
    echo -e "\e[1;41m$*\e[0m"
    exit 1
}

# ---- Function to create a changelog file with the last 400 commits and move it to $TARGET_OUT ----
create_changelog() {
	# Define the filename for the changelog
	local changelog_file="changelog.txt"

	# Use git log to get the last 400 commits and format them
	git log -n 400 --pretty=format:"%h - %s (%an)" > "$changelog_file"

	# Print the location of the changelog file
	msg "${purple}Changelog saved to $changelog_file ${white}"

	# Add a dash before each commit line for better readability
	sed -i -e "s/^/- /" "$changelog_file"

	# Move the changelog file to $TARGET_OUT
	mv "$changelog_file" "$AK3_PATH/"
}

# End Build Info
# Function to display kernel version and config information
display_kernel_version_info(){

    echo -e "${GREEN}===================END_BUILD=================${NC}"
    echo -e "${PURPLE}***************Neutrino-Kernel**************${NC}"
    echo -e "USER: $KBUILD_USER"
    echo -e "HOST: $KBUILD_HOST"
    echo -e "${PURPLE}*************last commit details************${NC}"
    echo -e "Last commit (name): $(git log -1 --pretty=format:%s)"
    echo -e "Last commit (hash): $(git log -1 --pretty=format:%H)"
    echo -e "${PURPLE}********************************************${NC}"
    echo -e "VERSION: $(grep -E '^VERSION =' Makefile | awk '{print $3}')"
    echo -e "PATCHLEVEL: $(grep -E '^PATCHLEVEL =' Makefile | awk '{print $3}')"
    echo -e "SUBLEVEL: $(grep -E '^SUBLEVEL =' Makefile | awk '{print $3}')"
    echo -e "EXTRAVERSION: $(grep -E '^EXTRAVERSION =' Makefile | awk '{print $3}')"
    echo -e "NAME: $(grep -E '^NAME =' Makefile | awk '{print $3}')"
    echo -e "${PURPLE}**********************************************${NC}"
}

# Kernel compilation function
compile_kernel(){
    random_color
    ascii_art_logo
    clean
    check_tools
    clone_anykernel3
    make_defconfig
    display_build_info
    create_changelog
    save_defconfig
    build_kernel
    generate_flashable
    display_kernel_version_info
}

# Prompt successive steps
choose_action

echo -e "${GREEN}Done.${NC}"
