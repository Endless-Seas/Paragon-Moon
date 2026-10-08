//Container window (code/modules/mob/living/carbon/human/paperdoll.dm).
//The opened container is on the left, everything carried on the right; bags inside bags fold open in place.

import { type MouseEvent, useState } from 'react';
import { Input } from 'tgui-core/components';
import { classes } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import {
  type Capacity,
  capacityText,
  iconSrc,
  type Item,
  ItemName,
  refocusMap,
} from './Paperdoll';

type Node = Item & {
  category: string;
  size: string;
  reachable: boolean;
  children?: Node[];
  sheathed?: boolean;
  where?: string;
  held?: boolean;
};

type Crumb = { name: string; ref: string };

type Data = {
  title: string;
  viewer_name: string;
  capacity: Capacity | null;
  contents: Node[];
  carried: Node[];
  path: Crumb[];
  hands_free: number;
};

//List order: categories alphabetically, Miscellaneous last
const categoryOrder = (a: string, b: string) =>
  Number(a === 'Miscellaneous') - Number(b === 'Miscellaneous') ||
  a.localeCompare(b);

const matches = (node: Node, needle: string): boolean =>
  !needle ||
  node.name.toLowerCase().includes(needle) ||
  !!node.children?.some((child) => matches(child, needle));

type RowProps = {
  node: Node;
  depth: number;
  needle: string;
  collapsed: Record<string, boolean>;
  toggle: (ref: string) => void;
  onPick: (node: Node, e: MouseEvent) => void;
  onOpen?: (node: Node) => void;
  side: 'left' | 'right';
};

//One item, and if it is a bag, everything inside it indented below
const Row = (props: RowProps) => {
  const { node, depth, needle, collapsed, toggle, onPick, onOpen, side } =
    props;
  if (!matches(node, needle)) {
    return null;
  }
  const hasChildren = !!node.children?.length;
  const open = hasChildren && (!!needle || !collapsed[node.ref]);
  //Worn gear cannot be dropped straight into the container; it has to come off first
  const inert =
    !node.reachable || (side === 'right' && !!node.where && !node.held);
  return (
    <>
      <div
        className={classes([
          'Container__row',
          inert && 'Container__row--inert',
          !!node.sheathed && 'Container__row--sheathed',
        ])}
        style={{ paddingLeft: `${depth * 18 + 4}px` }}
        onClick={(e) => onPick(node, e)}
      >
        <span
          className="Container__fold"
          onClick={(e) => {
            e.stopPropagation();
            if (hasChildren) {
              toggle(node.ref);
            }
          }}
        >
          {hasChildren ? (open ? '[-]' : '[+]') : node.capacity ? '[ ]' : ''}
        </span>
        {node.icon ? (
          <img className="Container__img" src={iconSrc(node.icon)} />
        ) : (
          <span className="Container__img" />
        )}
        <span className="Container__name">
          <ItemName item={node} />
          {!!node.sheathed && (
            <span className="Container__dim"> (sheathed)</span>
          )}
          {!!node.condition && (
            <span className="Container__condition"> [{node.condition}]</span>
          )}
          {!!node.capacity && (
            <span className="Container__dim">
              {' '}
              [{capacityText(node.capacity)}]
            </span>
          )}
        </span>
        <span className="Container__tag">
          {node.where ? `[${node.where}]` : node.size}
          {!!onOpen && !!node.capacity && (
            <span
              className="Container__open"
              onClick={(e) => {
                e.stopPropagation();
                onOpen(node);
              }}
            >
              {' '}
              [look in]
            </span>
          )}
        </span>
      </div>
      {open &&
        node.children!.map((child) => (
          <Row key={child.ref} {...props} node={child} depth={depth + 1} />
        ))}
    </>
  );
};

export const Container = () => {
  const { act, data } = useBackend<Data>();
  const { title, viewer_name, capacity, contents, carried, path, hands_free } =
    data;
  const [collapsed, setCollapsed] = useState<Record<string, boolean>>({});
  const [groupsClosed, setGroupsClosed] = useState<Record<string, boolean>>({});
  const [byClass, setByClass] = useState(true);
  const [search, setSearch] = useState('');
  const needle = search.toLowerCase();

  const toggle = (ref: string) =>
    setCollapsed({ ...collapsed, [ref]: !collapsed[ref] });
  const allBags = [...contents, ...carried].filter(
    (node) => node.children?.length,
  );
  const anyOpen = allBags.some((node) => !collapsed[node.ref]);
  const toggleAll = () => {
    const next: Record<string, boolean> = {};
    for (const node of allBags) {
      next[node.ref] = anyOpen;
    }
    setCollapsed(next);
  };

  const pick = (action: 'take' | 'put') => (node: Node, e: MouseEvent) => {
    act(e.shiftKey ? 'examine' : action, { ref: node.ref });
  };

  const rowProps = { needle, collapsed, toggle };
  const sorted = [...contents].sort((a, b) => a.name.localeCompare(b.name));
  const categories = Array.from(
    new Set(sorted.map((node) => node.category)),
  ).sort(categoryOrder);

  return (
    <Window title={title} width={980} height={620}>
      <Window.Content>
        <div className="Container" onMouseUp={refocusMap}>
          <div className="Container__header">
            <span className="Container__title">
              {path.map((crumb, i) => (
                <span key={crumb.ref}>
                  {i > 0 && <span className="Container__dim"> › </span>}
                  <span
                    className={classes([
                      'Container__crumb',
                      i === path.length - 1 && 'Container__crumb--here',
                    ])}
                    onClick={() => act('open', { ref: crumb.ref })}
                  >
                    {crumb.name}
                  </span>
                </span>
              ))}
            </span>
            <span className="Container__rule" />
            <span className="Container__title">
              {viewer_name} <span className="Container__cyan">[carrying]</span>
            </span>
          </div>

          <div className="Container__body">
            <div className="Container__pane">
              {contents.length === 0 && (
                <div className="Container__empty">It is empty.</div>
              )}
              {byClass
                ? categories.map((category) => {
                    const group = sorted.filter(
                      (node) =>
                        node.category === category && matches(node, needle),
                    );
                    if (!group.length) {
                      return null;
                    }
                    const open = !groupsClosed[category];
                    return (
                      <div key={category}>
                        <div
                          className="Container__group"
                          onClick={() =>
                            setGroupsClosed({
                              ...groupsClosed,
                              [category]: open,
                            })
                          }
                        >
                          <span className="Container__fold">
                            [{open ? '-' : '+'}]
                          </span>
                          <span className="Container__groupName">
                            {category}
                          </span>
                          <span className="Container__groupRule" />
                        </div>
                        {open &&
                          group.map((node) => (
                            <Row
                              key={node.ref}
                              {...rowProps}
                              node={node}
                              depth={1}
                              side="left"
                              onPick={pick('take')}
                              onOpen={(bag) => act('open', { ref: bag.ref })}
                            />
                          ))}
                      </div>
                    );
                  })
                : sorted.map((node) => (
                    <Row
                      key={node.ref}
                      {...rowProps}
                      node={node}
                      depth={0}
                      side="left"
                      onPick={pick('take')}
                      onOpen={(bag) => act('open', { ref: bag.ref })}
                    />
                  ))}
            </div>

            <div className="Container__divider">
              <span>⇄</span>
            </div>

            <div className="Container__pane">
              {carried.length === 0 && (
                <div className="Container__empty">I carry nothing.</div>
              )}
              {carried.map((node) => (
                <Row
                  key={node.ref}
                  {...rowProps}
                  node={node}
                  depth={0}
                  side="right"
                  onPick={pick('put')}
                />
              ))}
            </div>
          </div>

          <div className="Container__totals">
            <span className="Container__totalsRule" />
            <span className="Container__cyan">
              {capacity ? capacityText(capacity) : 'no limit'} →
            </span>
            <span className="Container__transfer">TRANSFER</span>
            <span className="Container__cyan">
              ← {hands_free} {hands_free === 1 ? 'hand' : 'hands'} free
            </span>
            <span className="Container__totalsRule" />
          </div>

          <div className="Container__footer">
            <Input
              className="Container__search"
              placeholder="<search>"
              value={search}
              onChange={setSearch}
            />
            <span className="Container__keys">
              <span className="Container__key">[Click]</span> take / put{'  '}
              <span className="Container__key">[Shift+Click]</span> examine{' '}
              <span
                className="Container__key Container__clickable"
                onClick={() => setByClass(!byClass)}
              >
                sort:{' '}
                <span className={byClass ? '' : 'Container__gold'}>a-z</span>/
                <span className={byClass ? 'Container__gold' : ''}>
                  by class
                </span>
              </span>{' '}
              <span
                className="Container__key Container__clickable"
                onClick={toggleAll}
              >
                [{anyOpen ? 'fold' : 'unfold'} all]
              </span>
            </span>
          </div>
        </div>
      </Window.Content>
    </Window>
  );
};
