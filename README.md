
<p align="center">
 <img width="150px" src="https://res.cloudinary.com/b5bxmqds/image/upload/v1790548062/paragon_moon2_xmsdwg.png" align="center" alt="Paragon Stats" />
 <h1 align="center">Paragon Moon</h1>
 <h2 align="center">Howling past the Moon.</h2>
</p>

<p align="center">
    <a href="https://github.com/Endless-Seas/Paragon-Moon/graphs/contributors">
      <img alt="GitHub Contributors" src="https://img.shields.io/github/contributors/Endless-Seas/Paragon-Moon" />
    </a>
    <a href="https://github.com/Endless-Seas/Paragon-Moon/issues">
      <img alt="Issues" src="https://img.shields.io/github/issues/Endless-Seas/Paragon-Moon" />
    </a>
    <a href="https://github.com/Endless-Seas/Paragon-Moon/pulls">
      <img alt="GitHub pull requests" src="https://img.shields.io/github/issues-pr/Endless-Seas/Paragon-Moon?color=0088ff" />
    </a>
</p>

<div align="center">

| Website                   | Link                                           |
|---------------------------|------------------------------------------------|
| Discord          | https://discord.gg/Aphelion |
| Wiki                      | PLACEHOLDER |

</div>

<h1>
	<a href="https://github.com/Endless-Seas/Paragon-Moon/blob/master/CONTRIBUTING.md">
		Contribution Guidelines
	</a>
</h1>

## Building and testing on Windows

Use BYOND **516.1688** with the 32-bit Microsoft WebView2 runtime. The client
minimum applies to administrators too. Engine, Bun and native release pins live
in `dependencies.sh`; `BUILD.cmd` bootstraps the pinned Bun version and builds
the TGUI bundles before compiling `roguetown.dme`.

For the same compiler download, native hash checks and artifact checks used by
Windows CI, run `pwsh -File tools/ci/build.ps1`. Run frontend checks with
`tools\build\build.bat --ci tgui-tsc tgui-eslint tgui-test`. For an ordinary
development build, use `BUILD.cmd`; `tools\build\build.bat tgui-dev` starts the
UI development server.

Test the complete checkout with Windows Dream Daemon before deploying through
TGS. Use a disposable data/config directory, and retain the matching engine,
native DLL, compiled game, UI assets and configuration for rollback. Real-client
checks must include normal-player permissions, pooled-window reuse, large text,
chat reconnect, all five local themes and legacy browser screens.

A fresh checkout needs local startup resources: the historical default map
points to the absent Dun Manor map. For an isolated smoke test, copy
`_maps/roguetest_nootherz.json` to `data/next_map.json` and provide a supported
sound file in `config/title_music/sounds/` (for example the supplied
`sound/music/paragontitle.ogg`). Select the intended game map and configuration
separately for gameplay testing.

TGS operators must select the pinned BYOND version in their instance settings
and stage the updated `tools/tgs_scripts/PreCompile` hook with the game directory
as its argument. Windows verifies the tracked rust-g DLL; Linux downloads the
hash-verified release. Linux/TGS runtime qualification remains a separate
operator gate. The tracked historical Linux library is not the pinned release;
run `bash tools/ci/install_rust_g.sh` before a Linux trial.

The obsolete Dockerfile has been retired. The legacy TGS3 packaging,
`tools/tgs4_scripts/PostCompile.sh`, `tools/deploy.sh`, Travis and AppVeyor
definitions are not supported deployment or qualification paths. Use the full
checkout and current TGS precompile hook; do not use the old packaging scripts.
Changing repository pins does not update a running TGS instance.

## LICENSE
Original Fork Originates from [commit c28b351807bad950d2b323ada048190844bbda32](https://github.com/tgstation/tgstation/commit/c28b351807bad950d2b323ada048190844bbda32).

All code after [commit 333c566b88108de218d882840e61928a9b759d8f on 2014/31/12 at 4:38 PM PST](https://github.com/tgstation/tgstation/commit/333c566b88108de218d882840e61928a9b759d8f) is licensed under [GNU AGPL v3](https://www.gnu.org/licenses/agpl-3.0.html).

All code before [commit 333c566b88108de218d882840e61928a9b759d8f on 2014/31/12 at 4:38 PM PST](https://github.com/tgstation/tgstation/commit/333c566b88108de218d882840e61928a9b759d8f) is licensed under [GNU GPL v3](https://www.gnu.org/licenses/gpl-3.0.html).
(Including tools unless their readme specifies otherwise.)

See LICENSE for more details.

The TGS DMAPI is licensed as a subproject under the MIT license.

See the footer of [code/__DEFINES/tgs.dm](./code/__DEFINES/tgs.dm) and [code/modules/tgs/LICENSE](./code/modules/tgs/LICENSE) for the MIT license.

All assets including icons and sound are under a [Creative Commons 3.0 BY-SA license](https://creativecommons.org/licenses/by-sa/3.0/) unless otherwise indicated.

### Digitigrade sprites

The digitigrade leg art (`l_leg_digi`, `r_leg_digi` and their `_above` states in `icons/roguetown/mob/bodies/`) is adapted from the digitigrade legs by the [tgstation](https://github.com/tgstation/tgstation) contributors (`icons/mob/human/species/lizard/bodyparts.dmi`), as carried by [NovaSector](https://github.com/NovaSector/NovaSector) and [Meridian-Rift](https://github.com/Aphelion-Moon/Meridian-Rift), licensed [CC BY-SA 3.0](https://creativecommons.org/licenses/by-sa/3.0/). The art was recoloured to Roguetown's body palettes and refitted to female and dwarf bodies.
The `_digi` states of legwear and footwear are Roguetown clothing reshaped onto that tgstation digitigrade silhouette with [tools/digi_sprites](./tools/digi_sprites), and are likewise CC BY-SA 3.0.
