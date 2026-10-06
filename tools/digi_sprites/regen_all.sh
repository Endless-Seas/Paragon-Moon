#!/bin/sh
# Regenerates every digitigrade state in the repo. Usage: regen_all.sh <path to Meridian-Rift checkout>
# Needs dmi.exe (build.bat). Paths are passed Windows-style to dmi.exe.
set -e
cd "$(dirname "$0")"
REPO=$(cd ../.. && pwd -W)
TG="$1/icons/mob/human/species/lizard/bodyparts.dmi"
I="$REPO/icons"; R="$I/roguetown"; O="$R/clothing/onmob"; SP="$R/clothing/special/onmob"

body() { f=$1; shift; ./dmi.exe digiapply "$R/mob/bodies/$f.dmi" l_leg r_leg "$@" >/dev/null; ./dmi.exe tgbody "$R/mob/bodies/$f.dmi" "$TG" "$@" >/dev/null; }
for f in m/ma m/mcom m/met m/mm m/mem m/mo m/mt m/mt_muscular m/mta; do body $f; done
for f in f/fa f/fcom f/fm f/fma f/ft f/ft_muscular; do body $f female; done
body m/md top=27; body m/mgn top=27; body f/fd female top=27

SKIRTS="skip=loincloth,plate_skirt,chain_skirt,skirt,chainkilt,achainkilt,ichainkilt,zizocloth"
./dmi.exe digiapply "$O/pants.dmi" all $SKIRTS
./dmi.exe digiapply "$O/helpers/sleeves_pants.dmi" all $SKIRTS
./dmi.exe digiapply "$O/feet.dmi" all
./dmi.exe digiapply "$SP/blkknight.dmi" bkboots bplateboots bklegs bplatelegs
./dmi.exe digiapply "$SP/race_armor.dmi" dwarfshoe welfshoes
./dmi.exe digiapply "$SP/gronn.dmi" gronnplateboots gronnplatepants gronnchainpants gronnleatherpants
./dmi.exe digiapply "$SP/captain.dmi" capplateleg
./dmi.exe digiapply "$R/clothing/special/overseer/onmob/overseer.dmi" overseerpants
./dmi.exe digiapply "$SP/baotha.dmi" baotha_legs
./dmi.exe digiapply "$SP/martyr.dmi" silverlegs
./dmi.exe digiapply "$R/maniac/clothing_mob.dmi" pants
./dmi.exe digiapply "$O/helpers/stonekeep_merc.dmi" grenzelboots

CLAWS="claws=$R/mob/bodies/m/mta.dmi,$R/mob/bodies/f/fma.dmi"
for f in plain_markings sock_markings spotted_markings tiger_markings tips_markings gradient_markings construct_plating; do
	bases=$(./dmi.exe list "$I/mob/body_markings/$f.dmi" _leg | awk 'NR>1 && $1 !~ /_digi/ {print $1}') bothlegs
	./dmi.exe digiapply "$I/mob/body_markings/$f.dmi" $bases "$CLAWS"
done

#Damage, bandage and wound overlays for the legs (dna.species.dam_icon / dam_icon_f)
D="$R/mob/bodies/dam"
./dmi.exe digiapply "$D/dam_male.dmi" $(./dmi.exe list "$D/dam_male.dmi" _leg | awk 'NR>1 && $1 !~ /_digi/ {print $1}') bothlegs
./dmi.exe digiapply "$D/dam_female.dmi" $(./dmi.exe list "$D/dam_female.dmi" _leg | awk 'NR>1 && $1 !~ /_digi/ {print $1}') female bothlegs

#Dismemberment masks: cut a missing digi leg out of digi clothing
./dmi.exe maskdigi "$O/helpers/dismemberment.dmi" r_leg l_leg r_leg_f l_leg_f r_leg_dwarf l_leg_dwarf r_leg_f_dwarf l_leg_f_dwarf
