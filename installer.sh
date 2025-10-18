#!/usr/bin/env bash

REPO="https://github.com/NyxNoirXD/Ultroid.git"
CURRENT_DIR="$(pwd)"
ENV_FILE_PATH=".env"
DIR="/app"

# --- Argument Parsing ---
while [ $# -gt 0 ]; do
    case "$1" in
    --dir=*)
        DIR="${1#*=}" || DIR="/app/Ultroid"
        ;;
    --branch=*)
        # Default branch is set to 'alpine' if the argument is provided but empty, 
        # otherwise we respect the provided value.
        BRANCH="${1#*=}"
        if [ -z "$BRANCH" ]; then
            BRANCH="main"
        fi
        ;;
    --env-file=*)
        ENV_FILE_PATH="${1#*=}" || ENV_FILE_PATH=".env"
        ;;
    --no-root)
        NO_ROOT=true
        ;;
    *)
        echo "Unknown parameter passed: $1"
        exit 1
        ;;
    esac
    shift
done

# Set default BRANCH if not already set by arguments
if [ -z "$BRANCH" ]; then
    BRANCH="main"
fi

# --- Dependency Check and Install ---
check_dependencies() {
    echo "Checking dependencies..."
    
    # Logic to check if running without root or if dependencies are already installed
    if ! [ -x "$(command -v sudo)" ] || [ "$NO_ROOT" = true ]; then
        echo -e "Sudo or root access not available/requested. Checking if dependencies are already installed." >&2
        
        # Check basic Python requirement
        if ! command -v python3 &>/dev/null; then
            echo -e "Python3 isn't installed. Please install python3.8 or higher to run this bot." >&2
            exit 1
        fi
        
        # Check Python version (using python3 as primary)
        if [ $(python3 -c "import sys; print(sys.version_info[1])") -lt 8 ]; then
            echo -e "Python 3.8 or higher is required to run this bot." >&2
            exit 1
        fi
        
        # Check system executables
        if ! command -v ffmpeg &>/dev/null || ! command -v mediainfo &>/dev/null || ! command -v git &>/dev/null; then
            echo -e "Some critical system dependencies (ffmpeg, mediainfo, neofetch, git) aren't installed. Please install them." >&2
            exit 1
        fi
        return
    fi

    # --- Debian/Ubuntu Installation ---
    if [ -x "$(command -v apt-get)" ]; then
        echo -e "Detected Debian/Ubuntu. Installing dependencies..."
        # Install without checking previous status, as apt-get is idempotent
        sudo apt-get -qq -o=Dpkg::Use-Pty=0 update
        # Include build-essential for complex Python packages
        sudo apt-get install -qq -o=Dpkg::Use-Pty=0 python3 python3-pip python3-dev build-essential ffmpeg mediainfo neofetch git -y

    # --- Arch Linux Installation ---
    elif [ -x "$(command -v pacman)" ]; then
        echo -e "Detected Arch Linux. Installing dependencies..."
        # Install without checking previous status
        sudo pacman -Sy --noconfirm python python-pip git ffmpeg mediainfo neofetch

    # --- ALPINE LINUX INSTALLATION (New Block) ---
    elif [ -x "$(command -v apk)" ]; then
        echo -e "Detected Alpine Linux. Installing dependencies..."
        
        # CRITICAL: Install build dependencies first (build-base, python3-dev, musl-dev)
        # This is required for pip to successfully install libraries like av and psycopg2-binary on Alpine.
        apk update -q
        apk add --no-cache build-base python3-dev musl-dev
        
        # Install core system dependencies
        apk add --no-cache ffmpeg mediainfo neofetch git python3 py3-pip
        
    # --- Unknown OS ---
    else
        echo -e "Unknown OS. Please manually install: python3 (>=3.8), python3-pip, ffmpeg, mediainfo, neofetch, and git." >&2
        exit 1
    fi
}

# The existing check_python function logic is merged into check_dependencies for cleaner flow
# in the modified script. Re-implementing it to maintain the original call structure:
check_python() {
    # Check if python3 is installed and version is >= 3.8
    if ! command -v python3 &>/dev/null; then
        echo -e "Python3 isn't installed. Please install python3.8 or higher to run this bot."
        exit 1
    fi
    if [ $(python3 -c "import sys; print(sys.version_info[1])") -lt 8 ]; then
        echo -e "Python 3.8 or higher is required to run this bot."
        exit 1
    fi
}

# --- Git and Cloning Functions ---
clone_repo() {
    # check if directory exists
    if [ -d "$DIR" ] && [ -d "$DIR/.git" ]; then
        echo -e "Updating Ultroid ${BRANCH}... "
        cd "$DIR" || { echo "Failed to change directory to $DIR"; exit 1; }
        git pull
        
        currentbranch="$(git rev-parse --abbrev-ref HEAD)"
        if [ "$currentbranch" != "$BRANCH" ]; then
            echo -e "Switching to branch ${BRANCH}... "
            git checkout "$BRANCH"
        fi
        
        # Update addons if the folder exists and is a git repo
        if [ -d "addons" ] && [ -d "addons/.git" ]; then
            cd addons
            git pull
        fi
        return
    else
        # Initial cloning logic
        if [ -d "$DIR" ]; then
            # If directory exists but is not a git repo, clean it up
            echo "Directory $DIR exists but is not a Git repository. Removing and cloning fresh."
            rm -rf "$DIR"
        fi
        
        mkdir -p "$DIR"
        echo -e "Cloning Ultroid ${BRANCH}... "
        git clone -b "$BRANCH" --depth 1 "$REPO" "$DIR" || { echo "Git clone failed. Check if branch '$BRANCH' exists."; exit 1; }
    fi
}

# --- Python Installation Functions ---
install_requirements() {
    pip3 install -q --upgrade pip
    echo -e "\n\nInstalling main requirements... "
    # Using `set +e` temporarily to allow a failure if requirements.txt doesn't exist yet (e.g., failed clone)
    set +e
    pip3 install -q --no-cache-dir -r "$DIR/requirements.txt"
    pip3 install -q --no-cache-dir -r "$DIR/resources/startup/optional-requirements.txt"
    set -e
}

# Other dependency functions remain largely the same, using pip3
railways_dep() {
    if [ "$RAILWAY_STATIC_URL" ]; then
        echo -e "Installing YouTube dependency... "
        pip3 install -q yt-dlp
    fi
}

misc_install() {
    if [ "$SETUP_PLAYWRIGHT" ]
    then
        echo -e "Installing playwright."
        pip3 install playwright
        playwright install
    fi
    if [ "$OKTETO_TOKEN" ]; then
        echo -e "Installing Okteto-CLI... "
        curl https://get.okteto.com -sSfL | sh
    elif [ "$VCBOT" ]; then
        if [ -d "$DIR/vcbot" ]; then
            cd "$DIR/vcbot"
            git pull
        else
            echo -e "Cloning VCBOT.."
            git clone https://github.com/TeamUltroid/VcBot "$DIR/vcbot"
        fi
        # CRITICAL: `av` is compiled from source on Alpine, requiring the build dependencies
        # installed in check_dependencies.
        pip3 install pytgcalls==3.0.0.dev23
        pip3 install av -q --no-binary av
    fi
}

dep_install() {
    echo -e "\n\nInstalling DB Requirement..."
    if [ "$MONGO_URI" ]; then
        echo -e "  Installing MongoDB Requirements..."
        pip3 install -q pymongo[srv]
    elif [ "$DATABASE_URL" ]; then
        echo -e "  Installing PostgreSQL Requirements..."
        # CRITICAL: psycopg2-binary requires build dependencies on Alpine/many Linux systems.
        # This is why 'build-base' and 'python3-dev' were added in check_dependencies.
        pip3 install -q psycopg2-binary
    elif [ "$REDIS_URI" ]; then
        echo -e "  Installing Redis Requirements..."
        pip3 install -q redis hiredis
    fi
}

# --- Main Execution Flow ---
main() {
    # Exit immediately if a command exits with a non-zero status
    set -e
    
    echo -e "Starting Ultroid Setup..."
    
    # Adjust DIR if script is being run from inside the repository (e.g. from pyUltroid folder)
    if [ -d "pyUltroid" ] && [ -d "resources" ] && [ -d "plugins" ]; then
        DIR=$CURRENT_DIR
    fi
    
    # Source ENV file if it exists
    if [ -f "$ENV_FILE_PATH" ]
    then
        echo "Sourcing environment variables from $ENV_FILE_PATH"
        # Use a more robust way to source environment variables while preserving export status
        set -a
        # sed is used to clean comments/empty lines and handle quoted strings for sourcing
        source <(cat "$ENV_FILE_PATH" | sed -e '/^#/d;/^\s*$/d' -e "s/'/'\\\''/g" -e "s/=\(.*\)/='\1'/g")
        set +a
        # Copy to .env for the application to potentially read
        cp "$ENV_FILE_PATH" .env
    fi

    # Run setup steps
    check_dependencies
    check_python
    railways_dep
    dep_install
    misc_install
    
    echo -e "\n\nSetup Completed."
}

# --- Initial Entry Point ---
if [ "$NO_ROOT" ]; then
    echo -e "Running with non-root mode requested."
    main
    exit 0
elif [ -t 0 ]; then
    # Interactive terminal check
    unameOut="$(uname -s)"
    case "${unameOut}" in
        Linux*)      machine=Linux;;
        Darwin*)     machine=Mac;;
        CYGWIN*)     machine=Cygwin;;
        MINGW*)      machine=MinGw;;
        *)           machine="UNKNOWN:${unameOut}"
    esac
    
    if [ "$machine" != "Linux" ]; then
        echo -e "This script is primarily tested for Linux environments."
    fi
    
    # check if sudo is installed, if not, try running main directly (assuming elevated privileges or non-root container)
    if ! command -v sudo &>/dev/null; then
        echo -e "Sudo isn't installed. Proceeding assuming sufficient permissions (e.g., running as root in a container or in $NO_ROOT mode)."
        main
    else
        sudo echo "Sudo permission granted."
        main
    fi
else
    # Non-interactive terminal (e.g., CI/CD or Docker)
    echo "Non-interactive terminal, skipping sudo checks."
    main
fi
