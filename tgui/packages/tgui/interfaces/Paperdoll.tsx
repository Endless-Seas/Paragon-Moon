//Equipment and Inventory popups (code/modules/mob/living/carbon/human/paperdoll.dm).
//Replaces the HUD equipment slots and the strip menu.

import { type MouseEvent, useState } from 'react';
import { Box, Button, Input } from 'tgui-core/components';
import { classes } from 'tgui-core/react';

import { useBackend } from '../backend';
import { focusMap } from '../focus';
import { Window } from '../layouts';
import { sanitizeText } from '../sanitize';

export type Item = {
  ref: string;
  name: string;
  icon: string | null;
  condition?: 'damaged' | 'broken';
  capacity?: Capacity;
  stats?: string[];
  segments?: NameSegment[];
  desc?: string | null;
};

//One word of an item name, coloured by its aspect (paperdoll.dm); null keeps the default colour
export type NameSegment = { text: string; color: string | null };

export type Capacity = { used: number; total: number; unit: string };

type Container = Capacity & { name: string };

type SlotState = {
  id: number;
  item?: Item;
  obscured?: boolean;
  blocked?: boolean;
};

type SlotInfo = {
  id: number;
  key: string;
  name: string;
  glyph: string | null;
};

type Hand = {
  index: number;
  name: string;
  active: boolean;
  item: Item | null;
};

type InventoryItem = Item & {
  where: string;
  equipped: boolean;
  category: string;
  container: boolean;
  reachable: boolean;
  held?: boolean;
};

type Data = {
  tab: TabName;
  stripping: boolean;
  owner_name: string;
  slot_info: SlotInfo[];
  slots: Record<string, SlotState>;
  hands: Hand[];
  inventory?: InventoryItem[];
  handcuffed?: boolean;
  legcuffed?: boolean;
  underwear?: string;
  legwear?: string;
  extras?: boolean;
  containers?: Container[];
  quickbar?: string[];
  skills?: Skill[];
  attributes?: Attributes;
  crafting_recipes?: Recipe[];
  crafting?: CraftingState;
  compendium?: CompendiumEntry[];
};

type Recipe = {
  name: string;
  path: string;
  category: string;
  icon: string | null;
  req_text: string;
  tool_text: string;
  catalyst_text: string;
  craftingdifficulty: string;
  sellprice: number;
};

type CraftingState = {
  available: boolean;
  can_craft_here?: boolean;
  busy?: boolean;
  showonlycraftable?: boolean;
  craftability?: Record<string, number>;
};

type CompendiumEntry = {
  title: string;
  subtitle?: string;
  body: string;
  group?: string;
};

type Skill = {
  name: string;
  desc: string;
  category: string;
  level: number;
  level_name: string;
  color: string | null;
  percent?: number;
  capped?: boolean;
  legendary?: boolean;
  stars?: number;
};

type Stat = {
  key: string;
  name: string;
  value: number | string;
  desc?: string;
};

type Described = { name: string; desc: string };

type Attributes = {
  name: string;
  species: string | null;
  job: string | null;
  age: string | null;
  patron: string | null;
  stats: Stat[];
  secondary: Stat[];
  traits: Described[];
  vices: Described[];
};

type TabName =
  | 'equipment'
  | 'inventory'
  | 'skills'
  | 'attributes'
  | 'crafting'
  | 'compendium';

//Doll layout: [column, row] on a 5 x 6 grid. "hand1" / "hand2" are the held-item slots.
const LAYOUT: Record<string, [number, number]> = {
  mask: [1, 0],
  head: [2, 0],
  mouth: [3, 0],
  backl: [0, 1],
  cloak: [1, 1],
  neck: [2, 1],
  wrists: [3, 1],
  backr: [4, 1],
  hand1: [0, 2],
  ring: [1, 2],
  armor: [2, 2],
  gloves: [3, 2],
  hand2: [4, 2],
  shirt: [1, 3],
  beltl: [0, 4],
  belt: [2, 4],
  beltr: [4, 4],
  pants: [2, 5],
  shoes: [3, 5],
};
const TALL = new Set(['armor']);

//Grid metrics, kept in sync with Paperdoll.scss
const COL_W = 92;
const COL_GAP = 10;
const ROW_H = 100;
const BOX = 64;
const TALL_BOX = 164;

//Wires between slots, as [from, to] pairs of LAYOUT keys
const WIRES: [string, string][] = [
  ['mask', 'head'],
  ['head', 'mouth'],
  ['head', 'neck'],
  ['backl', 'cloak'],
  ['cloak', 'neck'],
  ['neck', 'wrists'],
  ['wrists', 'backr'],
  ['wrists', 'gloves'],
  ['neck', 'armor'],
  ['hand1', 'ring'],
  ['ring', 'armor'],
  ['armor', 'gloves'],
  ['gloves', 'hand2'],
  ['armor', 'belt'],
  ['beltl', 'belt'],
  ['belt', 'beltr'],
  ['belt', 'pants'],
  ['pants', 'shoes'],
];

const CATEGORY_ORDER = [
  'Weapons',
  'Ammunition',
  'Clothing',
  'Containers',
  'Provisions',
  'Drinks & Potions',
  'Books & Notes',
  'Valuables',
  'Keys',
  'Materials',
  'Miscellaneous',
];

//Item name with each aspect word (quality, material, blessing...) in its colour
export const ItemName = (props: { item: Item }) => {
  const { item } = props;
  if (!item.segments?.length) {
    return <span>{item.name}</span>;
  }
  return (
    <>
      {item.segments.map((segment, i) => (
        <span
          key={i}
          style={segment.color ? { color: segment.color } : undefined}
        >
          {segment.text}
        </span>
      ))}
    </>
  );
};

export const capacityText = (capacity: Capacity) =>
  capacity.total
    ? `${capacity.total - capacity.used} of ${capacity.total} ${capacity.unit} free`
    : `${capacity.used} ${capacity.unit}`;

//Item pictures are png assets the server sends once and the client caches; the data carries their URL
export const iconSrc = (icon: string | null) => icon || undefined;

//After a click anywhere but a text box, hand keyboard focus back to the map so movement keys work at once
export const refocusMap = (e: MouseEvent) => {
  const target = e.target as HTMLElement;
  if (target.closest('input, textarea')) {
    return;
  }
  setTimeout(focusMap);
};

//Mouse info for the DM side, so item Click() sees the same modifiers as a HUD click
const clickInfo = (e: MouseEvent, button: string) => ({
  button,
  shift: e.shiftKey ? 1 : 0,
  ctrl: e.ctrlKey ? 1 : 0,
  alt: e.altKey ? 1 : 0,
});

const boxRect = (key: string) => {
  const [col, row] = LAYOUT[key];
  const height = TALL.has(key) ? TALL_BOX : BOX;
  const left = col * (COL_W + COL_GAP) + (COL_W - BOX) / 2;
  const top = row * ROW_H;
  return { left, top, right: left + BOX, bottom: top + height };
};

const Wire = (props: { from: string; to: string }) => {
  const a = boxRect(props.from);
  const b = boxRect(props.to);
  const sameColumn = a.left === b.left;
  if (sameColumn) {
    const [upper, lower] = a.top < b.top ? [a, b] : [b, a];
    return (
      <div
        className="Paperdoll__wire"
        style={{
          left: `${upper.left + BOX / 2}px`,
          top: `${upper.bottom}px`,
          width: '1px',
          height: `${lower.top - upper.bottom}px`,
        }}
      />
    );
  }
  const [leftBox, rightBox] = a.left < b.left ? [a, b] : [b, a];
  //Horizontal wires run through the middle of the shorter (non-tall) box
  const y = Math.min(leftBox.top, rightBox.top) + BOX / 2;
  return (
    <div
      className="Paperdoll__wire"
      style={{
        top: `${y}px`,
        left: `${leftBox.right}px`,
        height: '1px',
        width: `${rightBox.left - leftBox.right}px`,
      }}
    />
  );
};

type SlotProps = {
  layoutKey: string;
  label: string;
  item?: Item | null;
  glyph?: string | null;
  active?: boolean;
  covered?: string;
  onUse: (e: MouseEvent, button: string) => void;
  onHover: (item: Item | null | undefined) => void;
};

const Slot = (props: SlotProps) => {
  const { layoutKey, label, item, glyph, active, covered, onUse, onHover } =
    props;
  const [col, row] = LAYOUT[layoutKey];
  return (
    <div
      className={classes([
        'Paperdoll__slot',
        TALL.has(layoutKey) && 'Paperdoll__slot--tall',
        !!item && 'Paperdoll__slot--full',
        active && 'Paperdoll__slot--active',
        !!covered && 'Paperdoll__slot--disabled',
      ])}
      style={{
        gridColumn: col + 1,
        gridRow: TALL.has(layoutKey) ? `${row + 1} / span 2` : row + 1,
      }}
      onClick={(e) => !covered && onUse(e, 'left')}
      onContextMenu={(e) => {
        e.preventDefault();
        if (!covered) {
          onUse(e, 'right');
        }
      }}
      onMouseEnter={() => onHover(item)}
    >
      <div
        className={classes([
          'Paperdoll__box',
          item?.condition && `Paperdoll__box--${item.condition}`,
        ])}
      >
        {item
          ? !!item.icon && (
              <img className="Paperdoll__img" src={iconSrc(item.icon)} />
            )
          : !!glyph && (
              <img
                className="Paperdoll__img Paperdoll__img--empty"
                src={iconSrc(glyph)}
              />
            )}
      </div>
      <div className="Paperdoll__label">
        {label}
        {!!covered && <div className="Paperdoll__covered">[{covered}]</div>}
      </div>
    </div>
  );
};

const EquipmentTab = () => {
  const { act, data } = useBackend<Data>();
  const { slot_info = [], slots = {}, hands = [], stripping } = data;
  const [hovered, setHovered] = useState<Item | null | undefined>(null);

  const handKeys = ['hand1', 'hand2'];
  return (
    <>
      <div
        className="Paperdoll__doll"
        style={{ width: `${5 * COL_W + 4 * COL_GAP}px`, margin: '0 auto' }}
      >
        {WIRES.map(([from, to]) => (
          <Wire key={`${from}-${to}`} from={from} to={to} />
        ))}
        {slot_info.map((info) => {
          const state = slots[info.key];
          if (!LAYOUT[info.key] || !state) {
            return null;
          }
          const covered = state.blocked
            ? 'unusable'
            : state.obscured
              ? 'covered'
              : undefined;
          return (
            <Slot
              key={info.key}
              layoutKey={info.key}
              label={info.name}
              item={state.item}
              glyph={info.glyph}
              covered={covered}
              onHover={setHovered}
              onUse={(e, button) =>
                act('slot', { id: info.id, ...clickInfo(e, button) })
              }
            />
          );
        })}
        {hands.slice(0, 2).map((hand, i) => (
          <Slot
            key={handKeys[i]}
            layoutKey={handKeys[i]}
            label={hand.name}
            item={hand.item}
            active={hand.active}
            onHover={setHovered}
            onUse={(e, button) =>
              act('hand', { index: hand.index, ...clickInfo(e, button) })
            }
          />
        ))}
      </div>
      {!!stripping && (
        <div className="Paperdoll__extras">
          {!!data.handcuffed && (
            <Button color="caution" onClick={() => act('handcuffs')}>
              Remove restraints
            </Button>
          )}
          {!!data.legcuffed && (
            <Button color="caution" onClick={() => act('legcuffs')}>
              Remove leg restraints
            </Button>
          )}
          {data.underwear !== undefined && (
            <Button onClick={() => act('underwear')}>
              Underwear: {data.underwear}
            </Button>
          )}
          {data.legwear !== undefined && (
            <Button onClick={() => act('legwear')}>
              Legwear: {data.legwear}
            </Button>
          )}
          {!!data.extras && (
            <Button onClick={() => act('extras')}>More...</Button>
          )}
        </div>
      )}
      <div className="Paperdoll__detail">
        {hovered ? (
          <>
            {!!hovered.icon && (
              <img className="Paperdoll__img" src={iconSrc(hovered.icon)} />
            )}
            <div className="Paperdoll__detailBody">
              <div className="Paperdoll__name">
                <ItemName item={hovered} />
                {!!hovered.condition && (
                  <span
                    className={`Paperdoll__tag Paperdoll__tag--${hovered.condition}`}
                  >
                    [{hovered.condition}]
                  </span>
                )}
                {!!hovered.capacity && (
                  <span className="Paperdoll__tag">
                    [{capacityText(hovered.capacity)}]
                  </span>
                )}
              </div>
              {!!hovered.desc && (
                <Box
                  className="Paperdoll__desc"
                  dangerouslySetInnerHTML={{
                    __html: sanitizeText(hovered.desc),
                  }}
                />
              )}
              {!!hovered.stats?.length && (
                <div className="Paperdoll__stats">
                  {hovered.stats.map((line, i) => (
                    <Box
                      key={i}
                      dangerouslySetInnerHTML={{ __html: sanitizeText(line) }}
                    />
                  ))}
                </div>
              )}
            </div>
          </>
        ) : (
          <div className="Paperdoll__hint">
            {stripping ? (
              <>
                <b>[Click]</b> take it off them &nbsp; <b>[Click empty slot]</b>{' '}
                put on what I hold
              </>
            ) : (
              <>
                <b>[Click]</b> use, as on the old HUD slot &nbsp;{' '}
                <b>[Click empty slot]</b> wear what I hold &nbsp;{' '}
                <b>[Shift-Click]</b> examine
              </>
            )}
          </div>
        )}
      </div>
    </>
  );
};

const InventoryTab = () => {
  const { act, data } = useBackend<Data>();
  const inventory = data.inventory || [];
  const [filter, setFilter] = useState('All');
  const [binding, setBinding] = useState<string | null>(null);
  const [storing, setStoring] = useState<string | null>(null);
  const quickbar = data.quickbar || [];
  const containers = data.containers || [];
  const [search, setSearch] = useState('');

  const present = CATEGORY_ORDER.filter((category) =>
    inventory.some((item) => item.category === category),
  );
  const needle = search.toLowerCase();
  const shown = inventory.filter(
    (item) =>
      (filter === 'All' || item.category === filter) &&
      (!needle || item.name.toLowerCase().includes(needle)),
  );
  //Held items get their own group up top, so it is clear what is in hand
  const groups = [
    { category: 'In Hand', items: shown.filter((item) => item.held) },
    ...present.map((category) => ({
      category,
      items: shown.filter((item) => !item.held && item.category === category),
    })),
  ].filter((group) => group.items.length);
  const bags = inventory.filter((item) => item.container && item.reachable);

  return (
    <>
      <div className="Paperdoll__filters">
        {['All', ...present].map((category) => (
          <div
            key={category}
            className={classes([
              'Paperdoll__filter',
              filter === category && 'Paperdoll__filter--active',
            ])}
            onClick={() => setFilter(category)}
          >
            {category}
          </div>
        ))}
      </div>
      <div className="Paperdoll__list">
        {groups.length === 0 && (
          <div className="Paperdoll__empty">I carry nothing like that.</div>
        )}
        {groups.map((group) => (
          <div key={group.category}>
            <div className="Paperdoll__category">
              <span>- {group.category}</span>
              <span>{group.items.length}</span>
            </div>
            {group.items.map((item) => (
              <div
                key={item.ref}
                className={classes([
                  'Paperdoll__row',
                  !item.reachable && 'Paperdoll__row--unreachable',
                ])}
                onClick={(e) =>
                  item.held
                    ? setStoring(storing === item.ref ? null : item.ref)
                    : act('take', { ref: item.ref, ...clickInfo(e, 'left') })
                }
                onContextMenu={(e) => {
                  e.preventDefault();
                  act('examine', { ref: item.ref });
                }}
              >
                {item.icon ? (
                  <img className="Paperdoll__img" src={iconSrc(item.icon)} />
                ) : (
                  <span />
                )}
                <span>
                  <ItemName item={item} />
                  {!!item.held && (
                    <span className="Paperdoll__held"> [in hand]</span>
                  )}
                  {storing === item.ref && (
                    <span className="Paperdoll__bindPicker">
                      {bags.filter((bag) => bag.ref !== item.ref).length === 0
                        ? ' nothing to put it in'
                        : ' put in:'}
                      {bags
                        .filter((bag) => bag.ref !== item.ref)
                        .map((bag) => (
                          <span
                            key={bag.ref}
                            className="Paperdoll__open"
                            onClick={(e) => {
                              e.stopPropagation();
                              act('store', { ref: item.ref, into: bag.ref });
                              setStoring(null);
                            }}
                          >
                            [{bag.name}]
                          </span>
                        ))}
                    </span>
                  )}
                  {!!item.condition && (
                    <span
                      className={`Paperdoll__tag Paperdoll__tag--${item.condition}`}
                    >
                      [{item.condition}]
                    </span>
                  )}
                  {!item.reachable && (
                    <span className="Paperdoll__tag">[out of reach]</span>
                  )}
                  {!!item.container && (
                    <span
                      className="Paperdoll__open"
                      onClick={(e) => {
                        e.stopPropagation();
                        act('open', { ref: item.ref });
                      }}
                    >
                      [open]
                    </span>
                  )}
                  {!!item.capacity && (
                    <span className="Paperdoll__tag">
                      [{capacityText(item.capacity)}]
                    </span>
                  )}
                  {quickbar.includes(item.ref) && (
                    <span className="Paperdoll__bound">
                      [quick {quickbar.indexOf(item.ref) + 1}]
                    </span>
                  )}
                  {binding === item.ref ? (
                    <span className="Paperdoll__bindPicker">
                      {quickbar.map((_, i) => (
                        <span
                          key={i}
                          className="Paperdoll__open"
                          onClick={(e) => {
                            e.stopPropagation();
                            act('bind', { ref: item.ref, slot: i + 1 });
                            setBinding(null);
                          }}
                        >
                          [{i + 1}]
                        </span>
                      ))}
                    </span>
                  ) : (
                    <span
                      className="Paperdoll__open"
                      onClick={(e) => {
                        e.stopPropagation();
                        setBinding(item.ref);
                      }}
                    >
                      [bind]
                    </span>
                  )}
                </span>
                <span className="Paperdoll__where">{item.where}</span>
              </div>
            ))}
          </div>
        ))}
      </div>
      {containers.length > 0 && (
        <div className="Paperdoll__capacity">
          {containers.map((container, i) => (
            <div key={i} className="Paperdoll__capacityRow">
              <span className="Paperdoll__capacityName">{container.name}</span>
              <div className="Paperdoll__track">
                <div
                  className="Paperdoll__fill"
                  style={{
                    width: container.total
                      ? `${Math.min(100, (container.used / container.total) * 100)}%`
                      : '0%',
                  }}
                />
                <div className="Paperdoll__trackText">
                  {capacityText(container)}
                </div>
              </div>
            </div>
          ))}
        </div>
      )}
      <div className="Paperdoll__footer">
        <Input
          className="Paperdoll__search"
          placeholder="<search>"
          value={search}
          onChange={setSearch}
        />
        <span className="Paperdoll__hint">
          <b>[Click]</b> take, or store what is in hand &nbsp;{' '}
          <b>[Right-Click]</b> examine
        </span>
      </div>
    </>
  );
};

const SKILL_CATEGORIES = [
  'Combat',
  'Magic',
  'Crafting',
  'Labour',
  'Miscellaneous',
];

//Skills tab: collapsible groups on the left, details on the right
const SkillsTab = () => {
  const { data } = useBackend<Data>();
  const skills = data.skills || [];
  const [collapsed, setCollapsed] = useState<Record<string, boolean>>({});
  const [selected, setSelected] = useState<string | null>(null);
  const [search, setSearch] = useState('');
  const needle = search.toLowerCase();
  const chosen = skills.find((skill) => skill.name === selected);

  return (
    <div className="Paperdoll__split">
      <div className="Paperdoll__splitList">
        {SKILL_CATEGORIES.map((category) => {
          const group = skills
            .filter(
              (skill) =>
                skill.category === category &&
                (!needle || skill.name.toLowerCase().includes(needle)),
            )
            .sort((a, b) => b.level - a.level || a.name.localeCompare(b.name));
          if (!group.length) {
            return null;
          }
          const learned = group.filter((skill) => skill.level > 0).length;
          const open = !collapsed[category];
          return (
            <div key={category}>
              <div
                className="Paperdoll__group"
                onClick={() => setCollapsed({ ...collapsed, [category]: open })}
              >
                <span className="Paperdoll__groupToggle">
                  [{open ? '-' : '+'}]
                </span>
                <span className="Paperdoll__groupName">{category}</span>
                <span className="Paperdoll__groupCount">
                  Learned [{learned}/{group.length}]
                </span>
              </div>
              {open &&
                group.map((skill) => (
                  <div
                    key={skill.name}
                    className={classes([
                      'Paperdoll__skill',
                      !skill.level && 'Paperdoll__skill--unlearned',
                      selected === skill.name && 'Paperdoll__skill--selected',
                    ])}
                    onClick={() => setSelected(skill.name)}
                  >
                    <span
                      style={
                        skill.level && skill.color
                          ? { color: skill.color }
                          : undefined
                      }
                    >
                      :{skill.name}
                    </span>
                    <span className="Paperdoll__skillLevel">
                      {skill.level_name}
                      {!!skill.stars && (
                        <span className="Paperdoll__star">
                          {skill.stars === 2 ? ' ★' : ' ☆'}
                        </span>
                      )}
                      {skill.level > 0 && (
                        <span className="Paperdoll__tag">
                          {skill.capped
                            ? '[capped]'
                            : skill.legendary
                              ? '[---]'
                              : `[${skill.percent}%]`}
                        </span>
                      )}
                    </span>
                  </div>
                ))}
            </div>
          );
        })}
        <div className="Paperdoll__footer">
          <Input
            className="Paperdoll__search"
            placeholder="<search>"
            value={search}
            onChange={setSearch}
          />
          <span className="Paperdoll__hint">
            <b>[☆]</b> a rank is ready to dream &nbsp; <b>[★]</b> two ranks
          </span>
        </div>
      </div>
      <div className="Paperdoll__splitDetail">
        {chosen ? (
          <>
            <div
              className="Paperdoll__bigName"
              style={chosen.color ? { color: chosen.color } : undefined}
            >
              {chosen.name}
            </div>
            <div className="Paperdoll__subName">
              [{chosen.level ? chosen.level_name : 'Unlearned'}]
            </div>
            {chosen.level > 0 && !chosen.capped && !chosen.legendary && (
              <div className="Paperdoll__track Paperdoll__track--detail">
                <div
                  className="Paperdoll__fill"
                  style={{ width: `${Math.min(100, chosen.percent || 0)}%` }}
                />
                <div className="Paperdoll__trackText">
                  {chosen.percent}% to next level
                </div>
              </div>
            )}
            <Box
              className="Paperdoll__detailText"
              dangerouslySetInnerHTML={{ __html: sanitizeText(chosen.desc) }}
            />
          </>
        ) : (
          <div className="Paperdoll__hint">
            Select a skill to read about it.
          </div>
        )}
      </div>
    </div>
  );
};

//Attributes tab: stat boxes on the left, traits and vices on the right
const AttributesTab = () => {
  const { data } = useBackend<Data>();
  const attributes = data.attributes;
  const [selected, setSelected] = useState<string | null>(null);
  if (!attributes) {
    return null;
  }
  const subtitle = [attributes.species, attributes.job]
    .filter(Boolean)
    .join(' ');
  const stat = attributes.stats.find((entry) => entry.key === selected);
  const described = [...attributes.traits, ...attributes.vices].find(
    (entry) => entry.name === selected,
  );

  return (
    <div className="Paperdoll__split">
      <div className="Paperdoll__splitList">
        <div className="Paperdoll__who">
          <div className="Paperdoll__bigName">{attributes.name}</div>
          <div className="Paperdoll__subName">{subtitle}</div>
          <div className="Paperdoll__hint">
            Age: {attributes.age || '?'} &nbsp;»&nbsp; Patron:{' '}
            {attributes.patron || 'none'}
          </div>
        </div>
        <div className="Paperdoll__section">Main attributes</div>
        <div className="Paperdoll__statRow">
          {attributes.stats.map((entry) => {
            const value = Number(entry.value);
            return (
              <div
                key={entry.key}
                className={classes([
                  'Paperdoll__statBox',
                  selected === entry.key && 'Paperdoll__statBox--selected',
                ])}
                onClick={() => setSelected(entry.key)}
              >
                <div className="Paperdoll__statKey">{entry.key}</div>
                <div className="Paperdoll__statValue">{entry.value}</div>
                <div
                  className={classes([
                    'Paperdoll__statMod',
                    value > 10 && 'Paperdoll__statMod--up',
                    value < 10 && 'Paperdoll__statMod--down',
                  ])}
                >
                  [{value >= 10 ? '+' : ''}
                  {value - 10}]
                </div>
              </div>
            );
          })}
        </div>
        {!!stat && (
          <div className="Paperdoll__detailText">
            Your <b>{stat.name}</b>: {stat.desc}
          </div>
        )}
        <div className="Paperdoll__section">Condition</div>
        <div className="Paperdoll__statRow">
          {attributes.secondary.map((entry) => (
            <div key={entry.key} className="Paperdoll__statBox">
              <div className="Paperdoll__statKey">{entry.key}</div>
              <div className="Paperdoll__statValue">{entry.value}</div>
            </div>
          ))}
        </div>
      </div>
      <div className="Paperdoll__splitDetail Paperdoll__splitDetail--list">
        <div className="Paperdoll__section">Traits</div>
        {attributes.traits.length === 0 && (
          <div className="Paperdoll__hint">None.</div>
        )}
        {attributes.traits.map((trait) => (
          <div
            key={trait.name}
            className={classes([
              'Paperdoll__trait',
              selected === trait.name && 'Paperdoll__trait--selected',
            ])}
            onClick={() => setSelected(trait.name)}
          >
            {trait.name}
          </div>
        ))}
        {attributes.vices.length > 0 && (
          <>
            <div className="Paperdoll__section">Vices</div>
            {attributes.vices.map((vice) => (
              <div
                key={vice.name}
                className={classes([
                  'Paperdoll__trait',
                  'Paperdoll__trait--vice',
                  selected === vice.name && 'Paperdoll__trait--selected',
                ])}
                onClick={() => setSelected(vice.name)}
              >
                {vice.name}
              </div>
            ))}
          </>
        )}
        {!!described && (
          <Box
            className="Paperdoll__detailText"
            dangerouslySetInnerHTML={{ __html: sanitizeText(described.desc) }}
          />
        )}
      </div>
    </div>
  );
};

//Crafting tab: recipes grouped by skill on the left, the chosen recipe and its craft buttons on the right
const CraftingTab = () => {
  const { act, data } = useBackend<Data>();
  const recipes = data.crafting_recipes || [];
  const state = data.crafting;
  const [collapsed, setCollapsed] = useState<Record<string, boolean>>({});
  const [selected, setSelected] = useState<string | null>(null);
  const [search, setSearch] = useState('');

  if (!state?.available) {
    return <div className="Paperdoll__empty">I do not know how to craft.</div>;
  }
  const craftable = (recipe: Recipe) => !!state.craftability?.[recipe.name];
  const needle = search.toLowerCase();
  const shown = recipes.filter(
    (recipe) =>
      (!state.showonlycraftable || craftable(recipe)) &&
      (!needle || recipe.name.toLowerCase().includes(needle)),
  );
  const categories = Array.from(
    new Set(shown.map((recipe) => recipe.category)),
  ).sort();
  const chosen = recipes.find((recipe) => recipe.path === selected);

  return (
    <div className="Paperdoll__split">
      <div className="Paperdoll__splitList">
        {!state.can_craft_here && (
          <div className="Paperdoll__warning">I cannot craft here.</div>
        )}
        {categories.length === 0 && (
          <div className="Paperdoll__empty">
            {state.showonlycraftable
              ? 'Nothing I can make with what is to hand.'
              : 'No recipes match.'}
          </div>
        )}
        {categories.map((category) => {
          const group = shown
            .filter((recipe) => recipe.category === category)
            .sort(
              (a, b) =>
                Number(craftable(b)) - Number(craftable(a)) ||
                a.name.localeCompare(b.name),
            );
          const ready = group.filter(craftable).length;
          const open = !collapsed[category];
          return (
            <div key={category}>
              <div
                className="Paperdoll__group"
                onClick={() => setCollapsed({ ...collapsed, [category]: open })}
              >
                <span className="Paperdoll__groupToggle">
                  [{open ? '-' : '+'}]
                </span>
                <span className="Paperdoll__groupName">{category}</span>
                <span className="Paperdoll__groupCount">
                  Ready [{ready}/{group.length}]
                </span>
              </div>
              {open &&
                group.map((recipe) => (
                  <div
                    key={recipe.path}
                    className={classes([
                      'Paperdoll__recipe',
                      !craftable(recipe) && 'Paperdoll__recipe--missing',
                      selected === recipe.path && 'Paperdoll__skill--selected',
                    ])}
                    onClick={() => setSelected(recipe.path)}
                  >
                    {recipe.icon ? (
                      <img
                        className="Paperdoll__img"
                        src={iconSrc(recipe.icon)}
                      />
                    ) : (
                      <span />
                    )}
                    <span>{recipe.name}</span>
                    <span className="Paperdoll__skillLevel">
                      {recipe.craftingdifficulty}
                    </span>
                  </div>
                ))}
            </div>
          );
        })}
        <div className="Paperdoll__footer">
          <Input
            className="Paperdoll__search"
            placeholder="<search>"
            value={search}
            onChange={setSearch}
          />
          <span
            className={classes([
              'Paperdoll__filter',
              !!state.showonlycraftable && 'Paperdoll__filter--active',
            ])}
            onClick={() =>
              act('checkboxonlycraftable', { state: !state.showonlycraftable })
            }
          >
            [{state.showonlycraftable ? 'x' : ' '}] only what I can make
          </span>
        </div>
      </div>
      <div className="Paperdoll__splitDetail">
        {chosen ? (
          <>
            {!!chosen.icon && (
              <img
                className="Paperdoll__img Paperdoll__img--large"
                src={iconSrc(chosen.icon)}
              />
            )}
            <div className="Paperdoll__bigName">{chosen.name}</div>
            <div
              className={
                craftable(chosen) ? 'Paperdoll__subName' : 'Paperdoll__missing'
              }
            >
              [{craftable(chosen) ? 'Can make' : 'Missing materials'}]
            </div>
            <div className="Paperdoll__recipeFacts">
              <div>
                <b>INGREDIENTS:</b> {chosen.req_text || 'none'}
              </div>
              {!!chosen.tool_text && (
                <div>
                  <b>TOOLS:</b> {chosen.tool_text}
                </div>
              )}
              {!!chosen.catalyst_text && (
                <div>
                  <b>CATALYST:</b> {chosen.catalyst_text}
                </div>
              )}
              <div>
                <b>DIFFICULTY:</b> {chosen.craftingdifficulty}
              </div>
              <div>
                <b>SELL PRICE:</b> {chosen.sellprice}
              </div>
            </div>
            <div className="Paperdoll__craftButtons">
              {[1, 2, 3, 5].map((amount) => (
                <span
                  key={amount}
                  className="Paperdoll__open"
                  onClick={() =>
                    act('craft', { item: chosen.path, amount: amount })
                  }
                >
                  [{amount}x]
                </span>
              ))}
              <span
                className="Paperdoll__open"
                onClick={() => act('craft', { item: chosen.path, auto: true })}
              >
                [∞]
              </span>
            </div>
          </>
        ) : (
          <div className="Paperdoll__hint">
            Select a recipe. <b>[∞]</b> keeps crafting until I run out.
          </div>
        )}
      </div>
    </div>
  );
};

//Compendium tab: the lore primer and the regions of the world, as a journal
const CompendiumTab = () => {
  const { data } = useBackend<Data>();
  const entries = data.compendium || [];
  const [selected, setSelected] = useState(0);
  const entry = entries[selected];
  let lastGroup: string | undefined;

  return (
    <div className="Paperdoll__split">
      <div className="Paperdoll__splitList Paperdoll__splitList--narrow">
        {entries.map((item, i) => {
          const header =
            item.group && item.group !== lastGroup ? item.group : null;
          lastGroup = item.group;
          return (
            <div key={i}>
              {!!header && <div className="Paperdoll__section">{header}</div>}
              <div
                className={classes([
                  'Paperdoll__trait',
                  selected === i && 'Paperdoll__trait--selected',
                ])}
                onClick={() => setSelected(i)}
              >
                {selected === i ? '> ' : ''}
                {item.title}
              </div>
            </div>
          );
        })}
      </div>
      <div className="Paperdoll__splitDetail Paperdoll__splitDetail--wide">
        {!!entry && (
          <>
            <div className="Paperdoll__bigName">{entry.title}</div>
            {!!entry.subtitle && (
              <div className="Paperdoll__subName">{entry.subtitle}</div>
            )}
            <Box
              className="Paperdoll__detailText Paperdoll__lore"
              dangerouslySetInnerHTML={{ __html: sanitizeText(entry.body) }}
            />
          </>
        )}
      </div>
    </div>
  );
};

const TABS: { name: TabName; label: string }[] = [
  { name: 'equipment', label: 'Equipment' },
  { name: 'inventory', label: 'Inventory' },
  { name: 'skills', label: 'Skills' },
  { name: 'attributes', label: 'Attributes' },
  { name: 'crafting', label: 'Crafting' },
  { name: 'compendium', label: 'Compendium' },
];

export const Paperdoll = () => {
  const { act, data } = useBackend<Data>();
  const { tab, stripping, owner_name } = data;
  const activeTab: TabName = stripping ? 'equipment' : tab;
  const label = TABS.find((entry) => entry.name === activeTab)?.label;

  return (
    <Window title={stripping ? owner_name : label} width={900} height={840}>
      <Window.Content scrollable>
        <div className="Paperdoll" onMouseUp={refocusMap}>
          {!stripping && (
            <div className="Paperdoll__tabs">
              {TABS.map((entry) => (
                <span
                  key={entry.name}
                  className={classes([
                    'Paperdoll__tab',
                    activeTab === entry.name && 'Paperdoll__tab--active',
                  ])}
                  onClick={() => act('tab', { tab: entry.name })}
                >
                  {entry.label}
                </span>
              ))}
            </div>
          )}
          {activeTab === 'equipment' && <EquipmentTab />}
          {activeTab === 'inventory' && <InventoryTab />}
          {activeTab === 'skills' && <SkillsTab />}
          {activeTab === 'attributes' && <AttributesTab />}
          {activeTab === 'crafting' && <CraftingTab />}
          {activeTab === 'compendium' && <CompendiumTab />}
        </div>
      </Window.Content>
    </Window>
  );
};
