#!/bin/bash
# AE Infinity - Working Directory Setup Script
# Purpose: Clone all repositories into a clean working directory for agentic development
# Version: 1.0
# Last Updated: November 5, 2025

set -e

# ============================================================================
# CONFIGURATION
# ============================================================================

# Repository URLs
API_REPO="https://github.com/rkSlalom/ae-infinity-api"
UI_REPO="https://github.com/dallen4/ae-infinity-ui.git"
CONTEXT_REPO="https://github.com/rkSlalom/ae-infinity-context.git"

# Default working directory (can be overridden with first argument)
DEFAULT_WORK_DIR="work"
WORK_DIR="${1:-$DEFAULT_WORK_DIR}"

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# ============================================================================
# HELPER FUNCTIONS
# ============================================================================

# Print colored output
print_header() {
    echo -e "\n${CYAN}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC} ${MAGENTA}$1${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════════╝${NC}\n"
}

print_step() {
    echo -e "${BLUE}▶${NC} $1"
}

print_success() {
    echo -e "${GREEN}✔${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✖${NC} $1"
}

print_info() {
    echo -e "${CYAN}ℹ${NC} $1"
}

# Check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check prerequisites
check_prerequisites() {
    print_header "Checking Prerequisites"
    
    local missing_deps=()
    
    # Check Git
    if ! command_exists git; then
        missing_deps+=("git")
    else
        print_success "Git: $(git --version)"
    fi
    
    # Check .NET SDK
    if ! command_exists dotnet; then
        missing_deps+=("dotnet")
    else
        local dotnet_version=$(dotnet --version)
        print_success ".NET SDK: $dotnet_version"
        
        # Check if .NET 9.0 is available
        if ! dotnet --list-sdks | grep -q "9.0"; then
            print_warning ".NET 9.0 SDK not found (required for API)"
        fi
    fi
    
    # Check Node.js
    if ! command_exists node; then
        missing_deps+=("node")
    else
        print_success "Node.js: $(node --version)"
    fi
    
    # Check npm
    if ! command_exists npm; then
        missing_deps+=("npm")
    else
        print_success "npm: $(npm --version)"
    fi
    
    # Report missing dependencies
    if [ ${#missing_deps[@]} -ne 0 ]; then
        print_error "Missing required dependencies: ${missing_deps[*]}"
        echo ""
        print_info "Please install the missing dependencies:"
        for dep in "${missing_deps[@]}"; do
            case $dep in
                git)
                    echo "  - Git: https://git-scm.com/downloads"
                    ;;
                dotnet)
                    echo "  - .NET 9.0 SDK: https://dotnet.microsoft.com/download/dotnet/9.0"
                    ;;
                node|npm)
                    echo "  - Node.js (includes npm): https://nodejs.org/"
                    ;;
            esac
        done
        exit 1
    fi
    
    echo ""
    print_success "All prerequisites satisfied!"
}

# ============================================================================
# MAIN SETUP FUNCTIONS
# ============================================================================

# Setup working directory structure
setup_directory() {
    print_header "Setting Up Working Directory"
    
    # Get absolute path
    if [[ "$WORK_DIR" = /* ]]; then
        WORK_DIR_ABS="$WORK_DIR"
    else
        WORK_DIR_ABS="$(pwd)/$WORK_DIR"
    fi
    
    print_step "Target directory: $WORK_DIR_ABS"
    
    # Check if directory exists
    if [ -d "$WORK_DIR" ]; then
        print_warning "Directory '$WORK_DIR' already exists"
        read -p "Do you want to remove it and start fresh? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            print_step "Removing existing directory..."
            rm -rf "$WORK_DIR"
            print_success "Removed existing directory"
        else
            print_error "Cannot proceed with existing directory. Please use a different name or remove it manually."
            exit 1
        fi
    fi
    
    # Create directory structure
    print_step "Creating directory structure..."
    mkdir -p "$WORK_DIR"
    print_success "Created: $WORK_DIR/"
}

# Clone repository with error handling
clone_repo() {
    local repo_name=$1
    local repo_url=$2
    local target_dir=$3
    
    print_step "Cloning $repo_name..."
    
    if git clone "$repo_url" "$target_dir" 2>&1; then
        print_success "Cloned $repo_name"
        
        # Get current branch and commit info
        local branch=$(git -C "$target_dir" branch --show-current)
        local commit=$(git -C "$target_dir" rev-parse --short HEAD)
        print_info "Branch: $branch | Commit: $commit"
        
        return 0
    else
        print_error "Failed to clone $repo_name from $repo_url"
        return 1
    fi
}

# Clone all repositories
clone_repositories() {
    print_header "Cloning Repositories"
    
    local failed_repos=()
    
    # Clone API repo
    if ! clone_repo "ae-infinity-api" "$API_REPO" "$WORK_DIR/ae-infinity-api"; then
        failed_repos+=("ae-infinity-api")
    fi
    echo ""
    
    # Clone UI repo
    if ! clone_repo "ae-infinity-ui" "$UI_REPO" "$WORK_DIR/ae-infinity-ui"; then
        failed_repos+=("ae-infinity-ui")
    fi
    echo ""
    
    # Clone Context repo
    if ! clone_repo "ae-infinity-context" "$CONTEXT_REPO" "$WORK_DIR/ae-infinity-context"; then
        failed_repos+=("ae-infinity-context")
    fi
    echo ""
    
    # Check for failures
    if [ ${#failed_repos[@]} -ne 0 ]; then
        print_error "Failed to clone: ${failed_repos[*]}"
        exit 1
    fi
    
    print_success "All repositories cloned successfully!"
}

# Setup API dependencies
setup_api() {
    print_header "Setting Up API (.NET)"
    
    cd "$WORK_DIR/ae-infinity-api"
    
    print_step "Restoring NuGet packages..."
    if dotnet restore 2>&1 | grep -q "Restore succeeded"; then
        print_success "NuGet packages restored"
    else
        print_warning "Restore completed with warnings (check output above)"
    fi
    
    echo ""
    print_step "Building solution..."
    if dotnet build --configuration Debug --no-restore; then
        print_success "Build completed successfully"
    else
        print_error "Build failed (see errors above)"
        cd - >/dev/null
        return 1
    fi
    
    echo ""
    print_info "API is ready to run with: cd $WORK_DIR/ae-infinity-api/src/AeInfinity.Api && dotnet run"
    print_info "API will be available at:"
    print_info "  - HTTP:  http://localhost:5233"
    print_info "  - HTTPS: https://localhost:7184"
    print_info "  - Swagger: http://localhost:5233/"
    
    cd - >/dev/null
}

# Setup UI dependencies
setup_ui() {
    print_header "Setting Up UI (React + TypeScript)"
    
    cd "$WORK_DIR/ae-infinity-ui"
    
    print_step "Installing npm packages..."
    if npm install --silent 2>&1; then
        print_success "npm packages installed"
    else
        print_error "npm install failed (see errors above)"
        cd - >/dev/null
        return 1
    fi
    
    echo ""
    print_step "Verifying build configuration..."
    if npm run build --silent 2>&1 | grep -q "built in"; then
        print_success "Build verification successful"
    else
        print_warning "Build verification completed (check output if needed)"
    fi
    
    echo ""
    print_info "UI is ready to run with: cd $WORK_DIR/ae-infinity-ui && npm run dev"
    print_info "UI will be available at: http://localhost:5173 (default Vite port)"
    
    cd - >/dev/null
}

# Setup context repository
setup_context() {
    print_header "Setting Up Context Repository"
    
    cd "$WORK_DIR/ae-infinity-context"
    
    print_info "Context repository contains documentation and specifications"
    print_info "No build steps required"
    
    # Check for key documentation files
    local key_docs=(
        "PROJECT_SPEC.md"
        "API_SPEC.md"
        "ARCHITECTURE.md"
        "COMPONENT_SPEC.md"
        "DEVELOPMENT_GUIDE.md"
    )
    
    echo ""
    print_step "Verifying documentation..."
    for doc in "${key_docs[@]}"; do
        if [ -f "$doc" ]; then
            print_success "Found: $doc"
        else
            print_warning "Missing: $doc"
        fi
    done
    
    cd - >/dev/null
}

# Generate summary report
generate_summary() {
    print_header "Setup Summary"
    
    echo -e "${GREEN}✓ Working directory created:${NC} $WORK_DIR_ABS"
    echo ""
    
    echo "📁 Repository Structure:"
    echo "  $WORK_DIR/"
    echo "  ├── ae-infinity-api/        (.NET 9.0 Web API)"
    echo "  ├── ae-infinity-ui/         (React + TypeScript + Vite)"
    echo "  └── ae-infinity-context/    (Documentation & Specs)"
    echo ""
    
    echo "🚀 Quick Start Commands:"
    echo ""
    echo "  # Start API Backend:"
    echo "  cd $WORK_DIR/ae-infinity-api/src/AeInfinity.Api"
    echo "  dotnet run"
    echo ""
    echo "  # Start UI Frontend (in another terminal):"
    echo "  cd $WORK_DIR/ae-infinity-ui"
    echo "  npm run dev"
    echo ""
    echo "  # View Documentation:"
    echo "  cd $WORK_DIR/ae-infinity-context"
    echo "  cat README.md"
    echo ""
    
    echo "🔐 Test Credentials:"
    echo "  Email: sarah@example.com    Password: Password123!"
    echo "  Email: alex@example.com     Password: Password123!"
    echo "  Email: mike@example.com     Password: Password123!"
    echo ""
    
    echo "📚 Key Documentation:"
    echo "  • Project Spec:    $WORK_DIR/ae-infinity-context/PROJECT_SPEC.md"
    echo "  • API Spec:        $WORK_DIR/ae-infinity-context/API_SPEC.md"
    echo "  • Architecture:    $WORK_DIR/ae-infinity-context/ARCHITECTURE.md"
    echo "  • Dev Guide:       $WORK_DIR/ae-infinity-context/DEVELOPMENT_GUIDE.md"
    echo ""
    
    echo "🤖 Agentic Development:"
    echo "  • All repos are clean clones from their origins"
    echo "  • Dependencies are installed and ready"
    echo "  • Context repo provides complete specifications"
    echo "  • AI agents can iterate safely in this isolated environment"
    echo ""
    
    print_success "Setup complete! Happy coding! 🎉"
}

# Cleanup on error
cleanup_on_error() {
    print_error "Setup failed. Cleaning up..."
    if [ -d "$WORK_DIR" ]; then
        rm -rf "$WORK_DIR"
        print_info "Removed incomplete working directory"
    fi
    exit 1
}

# ============================================================================
# MAIN EXECUTION
# ============================================================================

main() {
    # Set trap for cleanup on error
    trap cleanup_on_error ERR
    
    # Print banner
    echo ""
    echo -e "${MAGENTA}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${MAGENTA}║                                                                ║${NC}"
    echo -e "${MAGENTA}║${NC}              ${CYAN}AE Infinity - Working Directory Setup${NC}             ${MAGENTA}║${NC}"
    echo -e "${MAGENTA}║                                                                ║${NC}"
    echo -e "${MAGENTA}║${NC}           Encapsulated Environment for Agentic Dev         ${MAGENTA}║${NC}"
    echo -e "${MAGENTA}║                                                                ║${NC}"
    echo -e "${MAGENTA}╚════════════════════════════════════════════════════════════════╝${NC}"
    
    # Show usage if help requested
    if [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]; then
        echo ""
        echo "Usage: $0 [work-directory]"
        echo ""
        echo "Arguments:"
        echo "  work-directory    Path to create working directory (default: 'work')"
        echo ""
        echo "Examples:"
        echo "  $0                    # Creates ./work directory"
        echo "  $0 my-workspace       # Creates ./my-workspace directory"
        echo "  $0 /tmp/ae-dev        # Creates /tmp/ae-dev directory"
        echo ""
        echo "This script will:"
        echo "  1. Clone all three AE Infinity repositories"
        echo "  2. Install dependencies (NuGet packages, npm modules)"
        echo "  3. Build projects to verify setup"
        echo "  4. Create an isolated working environment"
        echo ""
        exit 0
    fi
    
    # Execute setup steps
    check_prerequisites
    setup_directory
    clone_repositories
    setup_api
    setup_ui
    setup_context
    generate_summary
}

# Run main function with all arguments
main "$@"

