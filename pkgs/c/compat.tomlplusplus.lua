-- Form B inline descriptor for toml++ — a TOML config file parser and
-- serializer for C++17 (and later), exposed as the C++23 module
-- `tomlplusplus` so users can write `import tomlplusplus;` out of the box
-- (no opt-in, no `#include` needed).
--
-- Why the fork: upstream's released v3.4.0 tarball is header-only and ships
-- NO module interface unit at a release tag. Upstream HAS authored an official
-- one at `src/modules/tomlplusplus.cppm` (`export module tomlplusplus;`), but
-- it lives on the master branch only and is not in the v3.4.0 release. So this
-- package uses a fork (yspbwx2010/tomlplusplus @ v3.4.0-mcpp) that carries the
-- module unit plus mcpp packaging (mcpp.toml, tests, docs) at a reproducible tag.
--
-- The module unit (`src/modules/tomlplusplus.cppm`) does `#include
-- <toml++/toml.hpp>` in its global-module fragment then re-exports the `toml`
-- namespace, so `include_dirs` exposes `include/` for that include to resolve
-- (and `#include <toml++/toml.hpp>` remains available to users who want it).
--
-- All upstream paths are GLOBS relative to the verdir; the leading `*` absorbs
-- the GitHub archive's `tomlplusplus-<tag>/` wrap layer.
package = {
    spec        = "1",
    namespace   = "compat",
    name        = "compat.tomlplusplus",
    description = "TOML config file parser and serializer, exposed as C++23 module tomlplusplus",
    licenses    = {"MIT"},
    repo        = "https://github.com/yspbwx2010/tomlplusplus",
    type        = "package",

    xpm = {
        linux = {
            ["3.4.0"] = {
                url    = {
                    GLOBAL = "https://github.com/yspbwx2010/tomlplusplus/archive/refs/tags/v3.4.0-mcpp.tar.gz",
                    CN     = "https://github.com/yspbwx2010/tomlplusplus/archive/refs/tags/v3.4.0-mcpp.tar.gz",
                },
                sha256 = "cefd81c09ae8eade62f254ba0903e4585944cc86e84c320a92116a95cb725862",
            },
        },
        macosx = {
            ["3.4.0"] = {
                url    = {
                    GLOBAL = "https://github.com/yspbwx2010/tomlplusplus/archive/refs/tags/v3.4.0-mcpp.tar.gz",
                    CN     = "https://github.com/yspbwx2010/tomlplusplus/archive/refs/tags/v3.4.0-mcpp.tar.gz",
                },
                sha256 = "cefd81c09ae8eade62f254ba0903e4585944cc86e84c320a92116a95cb725862",
            },
        },
        windows = {
            ["3.4.0"] = {
                url    = {
                    GLOBAL = "https://github.com/yspbwx2010/tomlplusplus/archive/refs/tags/v3.4.0-mcpp.tar.gz",
                    CN     = "https://github.com/yspbwx2010/tomlplusplus/archive/refs/tags/v3.4.0-mcpp.tar.gz",
                },
                sha256 = "cefd81c09ae8eade62f254ba0903e4585944cc86e84c320a92116a95cb725862",
            },
        },
    },

    mcpp = {
        schema       = "0.1",
        language     = "c++23",
        import_std   = false,
        modules      = { "tomlplusplus" },
        -- Tarball's include/ subdirectory: the module unit's global-module
        -- fragment does `#include <toml++/toml.hpp>`, resolved from here.
        include_dirs = { "*/include" },
        -- Upstream's official module unit (fork @ src/modules/tomlplusplus.cppm).
        sources      = { "*/src/modules/tomlplusplus.cppm" },
        targets      = { ["tomlplusplus"] = { kind = "lib" } },
        features     = {},
        deps         = {},
    },
}
