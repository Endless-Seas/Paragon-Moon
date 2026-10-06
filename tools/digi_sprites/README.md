# Digitigrade sprite generator

Generates `<state>_digi` icon states (see `DIGITIGRADE_SUFFIX`) using the Meridian-Rift/TG digitigrade leg silhouette as the base.
Body legs: `tgbody` copies Meridian's `digitigrade_*_leg` art (icons/mob/human/species/lizard/bodyparts.dmi), rank-mapped to the body's greys.
Clothing: `digiapply` resamples each row of the item into that same silhouette, so the item keeps its own texture and colours.
Generated states are a starting point - hand-touch any that look off.

Build: `build.bat` (no installs needed). Paths passed to `dmi.exe` must be Windows-style (`C:/...`).

    dmi.exe tgbody <body.dmi> <meridian bodyparts.dmi> [female] [top=N]  # run AFTER digiapply l_leg r_leg (same options)
    dmi.exe digiapply <file.dmi> (<base_state>... | all) [skip=a,b] [female] [top=N]  # <state>_digi for base, _f, _dwarf, sleeve r_/l_ variants; overlays become <stem>_digi_detail etc.
    dmi.exe digipreview <out.png> <scale> <spec>...# each spec rendered normal + digi
    dmi.exe preview <out.png> <scale> <spec>...    # spec = file.dmi:state[@RRGGBB tint] joined with '+'
    dmi.exe list <file.dmi> [filter]
    dmi.exe strip <in.dmi> <out.dmi>               # removes all _digi states (for diffing against git HEAD)
    dmi.exe same <a.dmi> <b.dmi>

Body shapes: male top=23 (default), female (auto for "_f" states; bodies need `female`) top=24, dwarf/gnome top=27 (auto for "_dwarf" states).
Clothing is copied into the silhouette without stretching (outlines kept, interior cropped/extended from the anchored edge) so patterns survive.

Credit: the digitigrade leg art and silhouette are by the tgstation contributors (icons/mob/human/species/lizard/bodyparts.dmi, CC BY-SA 3.0), via NovaSector and Meridian-Rift. See the LICENSE section of the root README.md.

Skirt-like items (skirts, kilts, loincloths, zizocloth) are deliberately skipped: without a `_digi` state the normal sprite is drawn over the digi legs, which is what a skirt should do.
Sheets taller than 32px (e.g. race_armor.dmi, 32x64) are handled; the figure is assumed to sit in the bottom 32 rows.

Markings: run on the `_leg` states only, with `claws=<mta.dmi>,<fma.dmi>` so the black digi claws stay uncovered, e.g.
`dmi.exe digiapply .../sock_markings.dmi sock_l_leg_m sock_r_leg_m ... claws=.../m/mta.dmi,.../f/fma.dmi`.
States naming a single leg (`*_l_leg_*`, `*_r_leg_*`) only fill that leg in side views, matching TG's per-leg art.
