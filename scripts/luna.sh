# Shared by the repository build scripts. The caller sets ROOT first.
find_luna() {
    local candidate
    if [[ -n ${LUNA:-} ]]; then
        if command -v -- "$LUNA"; then return 0; fi
        printf 'Cannot execute LUNA=%s\n' "$LUNA" >&2
        return 1
    fi
    for candidate in "$ROOT/tools/Luna/luna" "$ROOT/../Luna/luna" luna; do
        if command -v -- "$candidate"; then return 0; fi
    done
    printf 'Luna is missing. See the setup in README.md or set LUNA to an executable.\n' >&2
    return 1
}
