/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

export const SETTINGS_TABS = [
  {
    id: 'general',
    name: 'General',
  },

  {
    id: 'textHighlight',
    name: 'Text Highlights',
  },
  {
    id: 'chatPage',
    name: 'Chat Tabs',
  },
  // {
  //   id: 'statPanel',
  //   name: 'Stat Panel',
  // },
];

export const FONTS_DISABLED = 'Default';

export const FONTS = [
  FONTS_DISABLED,
  // The previous default, kept as an option.
  'Pterra',
  'Verdana',
  'Arial',
  'Arial Black',
  'Comic Sans MS',
  'Impact',
  'Lucida Sans Unicode',
  'Tahoma',
  'Trebuchet MS',
  'Courier New',
  'Lucida Console',
];

/** Language and accent classes that keep their own font under a custom font. */
export const FONT_OVERRIDE_EXEMPT = [
  'sans',
  'papyrus',
  'robot',
  'clown',
  'his_grace',
  'human',
  'elf',
  'dwarf',
  'sandspeak',
  'delf',
  'hellspeak',
  'undead',
  'orc',
  'beast',
  'reptile',
  'grenzelhoftian',
  'kazengunese',
  'otavan',
  'posh',
  'etruscan',
  'gronnic',
  'aavnic',
  'abyssal',
  'canilunzt',
  'merar',
];

export const WARN_AFTER_HIGHLIGHT_AMT = 10;
