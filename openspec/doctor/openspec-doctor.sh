#!/bin/bash
# OpenSpec Doctor - Diagnostic and repair tool for cross-repository OpenSpec setup
# Can be run from any repository to validate and fix OpenSpec configuration

set -e

VERSION="1.0.0"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONTEXT_REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Tracking
ISSUES_FOUND=0
ISSUES_FIXED=0
AUTO_FIX=false
VERBOSE=false

# Usage information
usage() {
    cat << EOF
OpenSpec Doctor v${VERSION}

Diagnose and repair OpenSpec setup across repositories.

USAGE:
    ./openspec-doctor.sh [OPTIONS]

OPTIONS:
    -f, --fix           Auto-fix issues (otherwise just report)
    -v, --verbose       Verbose output
    -h, --help          Show this help message

EXAMPLES:
    # Diagnose issues only
    ./openspec-doctor.sh

    # Diagnose and auto-fix
    ./openspec-doctor.sh --fix

    # Run from any repo (via symlink or direct call)
    cd /path/to/any-repo
    ../ae-infinity-context/openspec/doctor/openspec-doctor.sh --fix

EOF
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -f|--fix)
            AUTO_FIX=true
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
        *)
            echo "Unknown option: $1"
            usage
            exit 1
            ;;
    esac
done

# Logging functions
log_info() {
    echo -e "${BLUE}ℹ${NC}  $1"
}

log_success() {
    echo -e "${GREEN}✓${NC}  $1"
}

log_warning() {
    echo -e "${YELLOW}⚠${NC}  $1"
    ((ISSUES_FOUND++))
}

log_error() {
    echo -e "${RED}✗${NC}  $1"
    ((ISSUES_FOUND++))
}

log_fixed() {
    echo -e "${GREEN}✓${NC}  $1 ${GREEN}[FIXED]${NC}"
    ((ISSUES_FIXED++))
}

log_verbose() {
    if [ "$VERBOSE" = true ]; then
        echo -e "   ${BLUE}→${NC} $1"
    fi
}

# Detect repos relative to context repo
detect_repos() {
    log_info "Detecting repository locations..."
    
    PARENT_DIR="$(dirname "$CONTEXT_REPO_ROOT")"
    log_verbose "Parent directory: $PARENT_DIR"
    log_verbose "Context repo: $CONTEXT_REPO_ROOT"
    
    # Find repos by looking for key markers
    API_REPO=""
    UI_REPO=""
    
    # Look for API repo (has AeInfinity.sln or similar .NET markers)
    for dir in "$PARENT_DIR"/*; do
        if [ -d "$dir" ] && [ "$dir" != "$CONTEXT_REPO_ROOT" ]; then
            if [ -f "$dir/AeInfinity.sln" ] || [ -f "$dir"/*.sln ] || [ -d "$dir/src" ]; then
                # Check if it has .NET project files
                if find "$dir" -name "*.csproj" -type f 2>/dev/null | grep -q .; then
                    API_REPO="$dir"
                    log_verbose "Found API repo: $API_REPO"
                fi
            fi
        fi
    done
    
    # Look for UI repo (has package.json with react/vite)
    for dir in "$PARENT_DIR"/*; do
        if [ -d "$dir" ] && [ "$dir" != "$CONTEXT_REPO_ROOT" ] && [ "$dir" != "$API_REPO" ]; then
            if [ -f "$dir/package.json" ]; then
                # Check if it's a React/Vite project
                if grep -q -E "(react|vite)" "$dir/package.json" 2>/dev/null; then
                    UI_REPO="$dir"
                    log_verbose "Found UI repo: $UI_REPO"
                fi
            fi
        fi
    done
    
    # Report findings
    if [ -n "$API_REPO" ]; then
        log_success "API repo detected: $(basename "$API_REPO")"
    else
        log_error "API repo not found"
    fi
    
    if [ -n "$UI_REPO" ]; then
        log_success "UI repo detected: $(basename "$UI_REPO")"
    else
        log_error "UI repo not found"
    fi
    
    echo ""
}

# Check context repo structure
check_context_repo() {
    log_info "Checking context repo structure..."
    
    local issues=0
    
    # Check for required files
    if [ ! -f "$CONTEXT_REPO_ROOT/openspec/project.md" ]; then
        log_error "Missing: openspec/project.md"
        ((issues++))
    else
        log_success "Found: openspec/project.md"
    fi
    
    if [ ! -f "$CONTEXT_REPO_ROOT/openspec/AGENTS.md" ]; then
        log_error "Missing: openspec/AGENTS.md"
        ((issues++))
    else
        log_success "Found: openspec/AGENTS.md"
    fi
    
    # Check for specs directory
    if [ ! -d "$CONTEXT_REPO_ROOT/openspec/specs" ]; then
        log_warning "Missing: openspec/specs/ directory"
        if [ "$AUTO_FIX" = true ]; then
            mkdir -p "$CONTEXT_REPO_ROOT/openspec/specs"
            log_fixed "Created openspec/specs/ directory"
        fi
    else
        log_success "Found: openspec/specs/"
    fi
    
    # Check for changes directory
    if [ ! -d "$CONTEXT_REPO_ROOT/openspec/changes" ]; then
        log_warning "Missing: openspec/changes/ directory"
        if [ "$AUTO_FIX" = true ]; then
            mkdir -p "$CONTEXT_REPO_ROOT/openspec/changes/archive"
            log_fixed "Created openspec/changes/ directory"
        fi
    else
        log_success "Found: openspec/changes/"
    fi
    
    # Check for documentation
    local docs=("CROSS_REPO_SETUP.md" "QUICK_REFERENCE.md")
    for doc in "${docs[@]}"; do
        if [ ! -f "$CONTEXT_REPO_ROOT/openspec/$doc" ]; then
            log_warning "Missing documentation: openspec/$doc"
        else
            log_verbose "Found: openspec/$doc"
        fi
    done
    
    echo ""
}

# Check symlinks in a repo
check_repo_symlinks() {
    local repo_path="$1"
    local repo_name="$2"
    
    log_info "Checking $repo_name symlinks..."
    
    if [ ! -d "$repo_path/openspec" ]; then
        log_error "$repo_name: openspec/ directory does not exist"
        if [ "$AUTO_FIX" = true ]; then
            mkdir -p "$repo_path/openspec"
            log_fixed "Created $repo_name/openspec/ directory"
        fi
        return
    fi
    
    # Calculate relative path from repo/openspec/ to context
    local rel_path=$(python3 -c "import os.path; print(os.path.relpath('$CONTEXT_REPO_ROOT', '$repo_path/openspec'))")
    log_verbose "Relative path to context: $rel_path"
    
    # Check each required symlink
    local symlinks=("project.md" "AGENTS.md" "specs")
    for link in "${symlinks[@]}"; do
        local link_path="$repo_path/openspec/$link"
        local target_path="$rel_path/openspec/$link"
        
        if [ -L "$link_path" ]; then
            # Symlink exists, check if it's correct
            local current_target=$(readlink "$link_path")
            if [ "$current_target" = "$target_path" ]; then
                log_success "$repo_name: $link → correct"
                log_verbose "Points to: $current_target"
            else
                log_warning "$repo_name: $link → incorrect target"
                log_verbose "Current: $current_target"
                log_verbose "Expected: $target_path"
                if [ "$AUTO_FIX" = true ]; then
                    rm "$link_path"
                    ln -s "$target_path" "$link_path"
                    log_fixed "$repo_name: Fixed $link symlink"
                fi
            fi
        elif [ -e "$link_path" ]; then
            # File exists but is not a symlink
            log_error "$repo_name: $link exists but is not a symlink"
            if [ "$AUTO_FIX" = true ]; then
                echo -n "   ${YELLOW}?${NC} Replace with symlink? [y/N] "
                read -r response
                if [[ "$response" =~ ^[Yy]$ ]]; then
                    rm -rf "$link_path"
                    ln -s "$target_path" "$link_path"
                    log_fixed "$repo_name: Replaced $link with symlink"
                fi
            fi
        else
            # Symlink doesn't exist
            log_warning "$repo_name: Missing symlink: $link"
            if [ "$AUTO_FIX" = true ]; then
                ln -s "$target_path" "$link_path"
                log_fixed "$repo_name: Created $link symlink"
            fi
        fi
    done
    
    # Check for local changes directory
    if [ ! -d "$repo_path/openspec/changes" ]; then
        log_warning "$repo_name: Missing local changes/ directory"
        if [ "$AUTO_FIX" = true ]; then
            mkdir -p "$repo_path/openspec/changes/archive"
            log_fixed "$repo_name: Created local changes/ directory"
        fi
    else
        log_success "$repo_name: Has local changes/ directory"
    fi
    
    echo ""
}

# Check .gitignore entries
check_gitignore() {
    local repo_path="$1"
    local repo_name="$2"
    
    log_info "Checking $repo_name .gitignore..."
    
    local gitignore="$repo_path/.gitignore"
    
    if [ ! -f "$gitignore" ]; then
        log_warning "$repo_name: No .gitignore file"
        if [ "$AUTO_FIX" = true ]; then
            touch "$gitignore"
            log_fixed "Created .gitignore"
        else
            return
        fi
    fi
    
    local entries=("openspec/project.md" "openspec/AGENTS.md" "openspec/specs")
    local missing=()
    
    for entry in "${entries[@]}"; do
        if ! grep -q "^$entry$" "$gitignore" 2>/dev/null; then
            missing+=("$entry")
        fi
    done
    
    if [ ${#missing[@]} -eq 0 ]; then
        log_success "$repo_name: .gitignore has OpenSpec entries"
    else
        log_warning "$repo_name: .gitignore missing ${#missing[@]} OpenSpec entries"
        if [ "$AUTO_FIX" = true ]; then
            echo "" >> "$gitignore"
            echo "# OpenSpec symlinks (point to context repo)" >> "$gitignore"
            for entry in "${missing[@]}"; do
                echo "$entry" >> "$gitignore"
            done
            log_fixed "$repo_name: Added OpenSpec entries to .gitignore"
        fi
    fi
    
    echo ""
}

# Check slash commands
check_slash_commands() {
    local repo_path="$1"
    local repo_name="$2"
    
    log_info "Checking $repo_name slash commands..."
    
    local commands_dir="$repo_path/.cursor/commands"
    
    if [ ! -d "$commands_dir" ]; then
        log_warning "$repo_name: No .cursor/commands/ directory"
        if [ "$AUTO_FIX" = true ]; then
            mkdir -p "$commands_dir"
            log_fixed "Created .cursor/commands/ directory"
        else
            return
        fi
    fi
    
    # Check for OpenSpec commands
    local commands=("openspec-proposal.md" "openspec-apply.md" "openspec-archive.md")
    local missing=()
    
    for cmd in "${commands[@]}"; do
        if [ ! -f "$commands_dir/$cmd" ]; then
            missing+=("$cmd")
        fi
    done
    
    if [ ${#missing[@]} -eq 0 ]; then
        log_success "$repo_name: Has all OpenSpec slash commands"
    else
        log_warning "$repo_name: Missing ${#missing[@]} slash commands"
        if [ "$AUTO_FIX" = true ]; then
            # Copy from context repo
            local source_commands="$CONTEXT_REPO_ROOT/.cursor/commands"
            if [ -d "$source_commands" ]; then
                for cmd in "${missing[@]}"; do
                    if [ -f "$source_commands/$cmd" ]; then
                        cp "$source_commands/$cmd" "$commands_dir/"
                        log_verbose "Copied $cmd"
                    fi
                done
                log_fixed "$repo_name: Copied missing slash commands"
            else
                log_warning "Cannot copy: source commands not found in context repo"
            fi
        fi
    fi
    
    echo ""
}

# Generate health report
generate_report() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo -e "${BLUE}OpenSpec Health Report${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    
    if [ $ISSUES_FOUND -eq 0 ]; then
        echo -e "${GREEN}✓ All checks passed!${NC}"
        echo "  OpenSpec is correctly configured across all repositories."
    else
        echo -e "${YELLOW}⚠ Found $ISSUES_FOUND issue(s)${NC}"
        
        if [ "$AUTO_FIX" = true ]; then
            if [ $ISSUES_FIXED -gt 0 ]; then
                echo -e "${GREEN}✓ Fixed $ISSUES_FIXED issue(s) automatically${NC}"
                
                local remaining=$((ISSUES_FOUND - ISSUES_FIXED))
                if [ $remaining -gt 0 ]; then
                    echo -e "${YELLOW}⚠ $remaining issue(s) require manual attention${NC}"
                fi
            fi
        else
            echo ""
            echo "Run with --fix flag to automatically repair issues:"
            echo "  ./openspec-doctor.sh --fix"
        fi
    fi
    
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
}

# Main execution
main() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo -e "${BLUE}OpenSpec Doctor v${VERSION}${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    
    if [ "$AUTO_FIX" = true ]; then
        log_info "Running in AUTO-FIX mode"
        echo ""
    else
        log_info "Running in DIAGNOSTIC mode (use --fix to repair)"
        echo ""
    fi
    
    # 1. Detect repositories
    detect_repos
    
    # 2. Check context repo
    check_context_repo
    
    # 3. Check API repo (if found)
    if [ -n "$API_REPO" ]; then
        check_repo_symlinks "$API_REPO" "API repo"
        check_gitignore "$API_REPO" "API repo"
        check_slash_commands "$API_REPO" "API repo"
    fi
    
    # 4. Check UI repo (if found)
    if [ -n "$UI_REPO" ]; then
        check_repo_symlinks "$UI_REPO" "UI repo"
        check_gitignore "$UI_REPO" "UI repo"
        check_slash_commands "$UI_REPO" "UI repo"
    fi
    
    # 5. Check root directory slash commands
    check_slash_commands "$PARENT_DIR" "Root directory"
    
    # 6. Generate report
    generate_report
    
    # Exit code based on remaining issues
    if [ "$AUTO_FIX" = true ]; then
        local remaining=$((ISSUES_FOUND - ISSUES_FIXED))
        exit $remaining
    else
        exit $ISSUES_FOUND
    fi
}

# Run main function
main

