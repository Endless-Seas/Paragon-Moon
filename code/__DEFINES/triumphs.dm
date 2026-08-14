//This could afford to go elsewhere, but it's fine for now.
//Just shove more stuff in here as we adjust triumphs.
#define TRIUMPH_CAP 250
//The buffer for triumph loss on death. You don't lose triumphs at or below this number.
#define TRIUMPH_BUFFER 3//Three, because you can lose 2 from the adds, with an additional 1 min.
//Increments of 50. Increases loss of triumphs by 1, on death, for each gate passed.
//Anything above these is assumed to go up to the cap and taking a penalty of 5.
//We'll also be using these for purchases, mind. Which is why they're defines.
#define TRIUMPH_NIL_THREAT 49
#define TRIUMPH_LOW_THREAT 99
#define TRIUMPH_MILD_THREAT 149
#define TRIUMPH_WILD_THREAT 199
