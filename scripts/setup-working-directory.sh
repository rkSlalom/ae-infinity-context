#!/bin/bash
# AE Infinity - Working Directory Setup Script
# 
# Purpose: Clone all three repositories into a clean working directory
#          for agentic development with proper configuration
#
# Usage:
#   ./setup-working-directory.sh [target-directory]
#
# Example:
#   ./setup-working-directory.sh ~/ae-infinity-workspace
#   ./setup-working-directory.sh  # defaults to current directory

set -e

VERSION="1.0.0"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# Repository URLs
CONTEXT_REPO="https://github.com/rkSlalom/ae-infinity-context.git"
API_REPO="https://github.com/rkSlalom/ae-infinity-api.git"
UI_REPO="https://github.com/dallen4/ae-infinity-ui.git"

# Configuration
TARGET_DIR="${1:-.}"
SKIP_DEPS=false
SKIP_HEALTH_CHECK=false
BRANCH="main"
VERBOSE=false

# Tracking
REPOS_CLONED=0
DEPS_INSTALLED=0
HEALTH_PASSED=0

# Usage information
usage() {
    cat << EOF
${CYAN}AE Infinity - Working Directory Setup v${VERSION}${NC}

Sets up a clean working directory with all three repositories configured
for agentic development.

${BLUE}USAGE:${NC}
    ./setup-working-directory.sh [OPTIONS] [TARGET_DIRECTORY]

${BLUE}ARGUMENTS:${NC}
    TARGET_DIRECTORY    Directory to clone repos into (default: current directory)

${BLUE}OPTIONS:${NC}
    -b, --branch BRANCH       Branch to checkout (default: main)
    -s, --skip-deps           Skip dependency installation
    -n, --no-health-check     Skip health checks
    -v, --verbose             Verbose output
    -h, --help                Show this help message

${BLUE}EXAMPLES:${NC}
    # Create workspace in home directory
    ./setup-working-directory.sh ~/ae-infinity-workspace

    # Create workspace in current directory
    ./setup-working-directory.sh

    # Create workspace without installing dependencies
    ./setup-working-directory.sh --skip-deps ~/workspace

    # Create workspace and checkout develop branch
    ./setup-working-directory.sh --branch develop ~/workspace

${BLUE}WHAT THIS SCRIPT DOES:${NC}
    1. Creates target directory structure
    2. Clones all three repositories:
       - ae-infinity-context (specs & docs)
       - ae-infinity-api (.NET backend)
       - ae-infinity-ui (React frontend)
    3. Installs dependencies (npm, dotnet restore)
    4. Sets up configurations
    5. Runs health checks
    6. Generates workspace summary

${BLUE}REPOSITORIES:${NC}
    Context: ${CONTEXT_REPO}
    API:     ${API_REPO}
    UI:      ${UI_REPO}

EOF
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -b|--branch)
            BRANCH="$2"
            shift 2
            ;;
        -s|--skip-deps)
            SKIP_DEPS=true
            shift
            ;;
        -n|--no-health-check)
            SKIP_HEALTH_CHECK=true
            shift
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        -*)
            echo -e "${RED}Unknown option: $1${NC}"
            usage
            exit 1
            ;;
        *)
            TARGET_DIR="$1"
            shift
            ;;
    esac
done

# Logging functions
log_header() {
    echo ""
    echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}$1${NC}"
    echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

log_step() {
    echo -e "${BLUE}▶${NC}  $1"
}

log_info() {
    echo -e "${CYAN}ℹ${NC}  $1"
}

log_success() {
    echo -e "${GREEN}✓${NC}  $1"
}

log_warning() {
    echo -e "${YELLOW}⚠${NC}  $1"
}

log_error() {
    echo -e "${RED}✗${NC}  $1"
}

log_verbose() {
    if [ "$VERBOSE" = true ]; then
        echo -e "   ${BLUE}→${NC} $1"
    fi
}

# Check prerequisites
check_prerequisites() {
    log_step "Checking prerequisites..."
    
    local missing=()
    
    # Check git
    if ! command -v git &> /dev/null; then
        missing+=("git")
    else
        log_success "Git installed: $(git --version | head -n1)"
    fi
    
    # Check Node.js (for UI)
    if ! command -v node &> /dev/null; then
        log_warning "Node.js not found (required for UI)"
        missing+=("node")
    else
        log_success "Node.js installed: $(node --version)"
    fi
    
    # Check npm (for UI)
    if ! command -v npm &> /dev/null; then
        log_warning "npm not found (required for UI)"
        missing+=("npm")
    else
        log_success "npm installed: $(npm --version)"
    fi
    
    # Check .NET SDK (for API)
    if ! command -v dotnet &> /dev/null; then
        log_warning ".NET SDK not found (required for API)"
        missing+=("dotnet")
    else
        local dotnet_version=$(dotnet --version)
        log_success ".NET SDK installed: $dotnet_version"
        
        # Check if .NET 9.0 is available
        if ! dotnet --list-sdks | grep -q "9.0"; then
            log_warning ".NET 9.0 SDK not found (API requires 9.0+)"
        fi
    fi
    
    if [ ${#missing[@]} -gt 0 ]; then
        echo ""
        log_error "Missing required tools: ${missing[*]}"
        log_info "Please install missing tools and try again"
        echo ""
        echo "  Git: https://git-scm.com/"
        echo "  Node.js: https://nodejs.org/"
        echo "  .NET SDK: https://dotnet.microsoft.com/download/dotnet/9.0"
        echo ""
        exit 1
    fi
    
    echo ""
}

# Create directory structure
create_directory_structure() {
    log_step "Creating directory structure..."
    
    # Resolve absolute path
    TARGET_DIR=$(cd "$TARGET_DIR" 2>/dev/null && pwd || echo "$TARGET_DIR")
    
    if [ -d "$TARGET_DIR" ]; then
        log_info "Target directory exists: $TARGET_DIR"
        
        # Check if repos already exist
        if [ -d "$TARGET_DIR/ae-infinity-context" ] || \
           [ -d "$TARGET_DIR/ae-infinity-api" ] || \
           [ -d "$TARGET_DIR/ae-infinity-ui" ]; then
            echo ""
            log_warning "One or more repositories already exist in target directory"
            echo -n "   ${YELLOW}?${NC} Continue and overwrite? [y/N] "
            read -r response
            if [[ ! "$response" =~ ^[Yy]$ ]]; then
                log_info "Aborted by user"
                exit 0
            fi
        fi
    else
        log_info "Creating target directory: $TARGET_DIR"
        mkdir -p "$TARGET_DIR"
    fi
    
    log_success "Directory ready: $TARGET_DIR"
    echo ""
}

# Clone repository
clone_repo() {
    local repo_url="$1"
    local repo_name="$2"
    local repo_path="$TARGET_DIR/$repo_name"
    
    log_step "Cloning $repo_name..."
    log_verbose "URL: $repo_url"
    log_verbose "Path: $repo_path"
    log_verbose "Branch: $BRANCH"
    
    if [ -d "$repo_path" ]; then
        log_info "Removing existing directory: $repo_name"
        rm -rf "$repo_path"
    fi
    
    if [ "$VERBOSE" = true ]; then
        git clone --branch "$BRANCH" "$repo_url" "$repo_path"
    else
        git clone --quiet --branch "$BRANCH" "$repo_url" "$repo_path" 2>&1 | grep -v "Cloning into" || true
    fi
    
    if [ $? -eq 0 ]; then
        log_success "Cloned $repo_name"
        ((REPOS_CLONED++))
    else
        log_error "Failed to clone $repo_name"
        return 1
    fi
}

# Clone all repositories
clone_repositories() {
    log_header "Cloning Repositories"
    
    clone_repo "$CONTEXT_REPO" "ae-infinity-context"
    clone_repo "$API_REPO" "ae-infinity-api"
    clone_repo "$UI_REPO" "ae-infinity-ui"
    
    echo ""
    log_success "All repositories cloned successfully"
    echo ""
}

# Install UI dependencies
install_ui_dependencies() {
    local ui_path="$TARGET_DIR/ae-infinity-ui"
    
    log_step "Installing UI dependencies (npm)..."
    log_verbose "Path: $ui_path"
    
    cd "$ui_path"
    
    if [ "$VERBOSE" = true ]; then
        npm install
    else
        npm install --silent --no-progress 2>&1 | grep -E "warn|error" || true
    fi
    
    if [ $? -eq 0 ]; then
        log_success "UI dependencies installed"
        ((DEPS_INSTALLED++))
    else
        log_error "Failed to install UI dependencies"
        return 1
    fi
}

# Install API dependencies
install_api_dependencies() {
    local api_path="$TARGET_DIR/ae-infinity-api"
    
    log_step "Installing API dependencies (dotnet restore)..."
    log_verbose "Path: $api_path"
    
    cd "$api_path"
    
    if [ "$VERBOSE" = true ]; then
        dotnet restore
    else
        dotnet restore --verbosity quiet 2>&1 | grep -E "error" || true
    fi
    
    if [ $? -eq 0 ]; then
        log_success "API dependencies installed"
        ((DEPS_INSTALLED++))
    else
        log_error "Failed to install API dependencies"
        return 1
    fi
}

# Install all dependencies
install_dependencies() {
    if [ "$SKIP_DEPS" = true ]; then
        log_info "Skipping dependency installation (--skip-deps)"
        echo ""
        return 0
    fi
    
    log_header "Installing Dependencies"
    
    install_ui_dependencies
    install_api_dependencies
    
    echo ""
    log_success "All dependencies installed successfully"
    echo ""
}

# Create environment files
create_environment_files() {
    log_header "Creating Configuration Files"
    
    # Create .env for UI
    local ui_env="$TARGET_DIR/ae-infinity-ui/.env.local"
    log_step "Creating UI environment file..."
    
    if [ ! -f "$ui_env" ]; then
        cat > "$ui_env" << 'EOF'
# AE Infinity UI - Development Environment

# API Configuration
VITE_API_BASE_URL=http://localhost:5233/api
VITE_API_TIMEOUT=30000

# Environment
VITE_ENVIRONMENT=development

# Feature Flags (for future use)
VITE_ENABLE_REALTIME=false
VITE_ENABLE_OFFLINE_MODE=false

# Debug
VITE_DEBUG=true
EOF
        log_success "Created .env.local for UI"
    else
        log_info ".env.local already exists for UI"
    fi
    
    # Note about API configuration
    log_info "API configuration in appsettings.json (no changes needed)"
    
    echo ""
}

# Run health checks
health_check() {
    if [ "$SKIP_HEALTH_CHECK" = true ]; then
        log_info "Skipping health checks (--no-health-check)"
        echo ""
        return 0
    fi
    
    log_header "Running Health Checks"
    
    # Check UI build
    log_step "Checking UI build configuration..."
    cd "$TARGET_DIR/ae-infinity-ui"
    if [ -f "package.json" ] && [ -f "vite.config.ts" ]; then
        log_success "UI configuration valid"
        ((HEALTH_PASSED++))
    else
        log_warning "UI configuration incomplete"
    fi
    
    # Check API build
    log_step "Checking API build configuration..."
    cd "$TARGET_DIR/ae-infinity-api"
    if [ -f "AeInfinity.sln" ] && [ -f "src/AeInfinity.Api/AeInfinity.Api.csproj" ]; then
        log_success "API configuration valid"
        ((HEALTH_PASSED++))
    else
        log_warning "API configuration incomplete"
    fi
    
    # Check context repo
    log_step "Checking context repository..."
    cd "$TARGET_DIR/ae-infinity-context"
    if [ -f "PROJECT_SPEC.md" ] && [ -f "API_SPEC.md" ]; then
        log_success "Context repository complete"
        ((HEALTH_PASSED++))
    else
        log_warning "Context repository incomplete"
    fi
    
    echo ""
}

# Generate workspace summary
generate_summary() {
    log_header "Workspace Summary"
    
    echo -e "${GREEN}✓ Workspace setup complete!${NC}"
    echo ""
    echo -e "${BLUE}Location:${NC} $TARGET_DIR"
    echo ""
    echo -e "${BLUE}Repositories:${NC}"
    echo "  • ae-infinity-context - Context & specifications"
    echo "  • ae-infinity-api     - .NET backend API"
    echo "  • ae-infinity-ui      - React frontend"
    echo ""
    echo -e "${BLUE}Statistics:${NC}"
    echo "  • Repositories cloned: $REPOS_CLONED/3"
    echo "  • Dependencies installed: $DEPS_INSTALLED/2"
    echo "  • Health checks passed: $HEALTH_PASSED/3"
    echo ""
    echo -e "${BLUE}Branch:${NC} $BRANCH"
    echo ""
    
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}Next Steps:${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo "1. Start the API (backend):"
    echo "   ${YELLOW}cd $TARGET_DIR/ae-infinity-api${NC}"
    echo "   ${YELLOW}cd src/AeInfinity.Api${NC}"
    echo "   ${YELLOW}dotnet run${NC}"
    echo ""
    echo "   API will be available at:"
    echo "   • http://localhost:5233"
    echo "   • https://localhost:7184"
    echo "   • Swagger: http://localhost:5233/"
    echo ""
    echo "2. Start the UI (frontend):"
    echo "   ${YELLOW}cd $TARGET_DIR/ae-infinity-ui${NC}"
    echo "   ${YELLOW}npm run dev${NC}"
    echo ""
    echo "   UI will be available at:"
    echo "   • http://localhost:5173"
    echo ""
    echo "3. Test credentials:"
    echo "   • sarah@example.com / Password123!"
    echo "   • alex@example.com / Password123!"
    echo "   • mike@example.com / Password123!"
    echo ""
    echo "4. Read the documentation:"
    echo "   ${YELLOW}cd $TARGET_DIR/ae-infinity-context${NC}"
    echo "   • PROJECT_SPEC.md - Project overview"
    echo "   • API_SPEC.md - API documentation"
    echo "   • ARCHITECTURE.md - System architecture"
    echo ""
    
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}Agentic Development:${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo "This workspace is configured for AI-assisted development:"
    echo ""
    echo "• Context-driven: All specs in ae-infinity-context/"
    echo "• Type-safe: TypeScript + C# for strong typing"
    echo "• Well-documented: Comprehensive specs and guides"
    echo "• Clean architecture: Clear separation of concerns"
    echo ""
    echo "When working with AI agents, always reference:"
    echo "  ${YELLOW}$TARGET_DIR/ae-infinity-context/${NC}"
    echo ""
    
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

# Main execution
main() {
    clear
    log_header "AE Infinity - Working Directory Setup v${VERSION}"
    
    echo -e "${BLUE}This script will set up a complete working environment${NC}"
    echo -e "${BLUE}with all three repositories configured for development.${NC}"
    echo ""
    
    # Run setup steps
    check_prerequisites
    create_directory_structure
    clone_repositories
    install_dependencies
    create_environment_files
    health_check
    
    # Generate summary
    generate_summary
    
    # Success
    echo -e "${GREEN}✓ Setup completed successfully!${NC}"
    echo ""
}

# Run main function
main

