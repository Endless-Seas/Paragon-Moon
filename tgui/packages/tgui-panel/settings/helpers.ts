import { setClientTheme } from '../themes';
import { FONT_OVERRIDE_EXEMPT, FONTS_DISABLED } from './constants';
import type { SettingsState } from './types';

let statFontTimer: ReturnType<typeof setTimeout> | undefined;
let statTabsTimer: ReturnType<typeof setTimeout> | undefined;
let overrideRule: HTMLStyleElement | undefined;
let overrideFontFamily: string | undefined;
let overrideFontSize = '19px';

const overrideExclusions = [
  '.Icon',
  ...FONT_OVERRIDE_EXEMPT.flatMap((name) => [`.${name}`, `.${name} *`]),
].join(', ');

function updateGlobalOverrideRule(): void {
  const fontFamily =
    overrideFontFamily === undefined
      ? ''
      : `font-family: ${overrideFontFamily} !important;`;
  const rule = `body * :not(${overrideExclusions}) { ${fontFamily} }`;

  if (!overrideRule) {
    overrideRule = document.createElement('style');
    document.querySelector('head')?.append(overrideRule);
  }
  if (overrideRule) {
    overrideRule.innerText = rule;
  }
  document.body.style.setProperty('font-size', overrideFontSize);
}

function setGlobalFontSize(
  fontSize: number,
  statFontSize: number,
  statLinked: boolean,
): void {
  overrideFontSize = `${fontSize}px`;
  if (statFontTimer) clearTimeout(statFontTimer);
  const value = statLinked ? fontSize : statFontSize;
  Byond.command(`.output statbrowser:set_font_size ${value}px`);
  statFontTimer = setTimeout(() => {
    Byond.command(`.output statbrowser:set_font_size ${value}px`);
  }, 1500);
}

function setGlobalFontFamily(fontFamily: string): void {
  overrideFontFamily = fontFamily === FONTS_DISABLED ? undefined : fontFamily;
}

function setStatTabsStyle(style: string): void {
  if (statTabsTimer) clearTimeout(statTabsTimer);
  Byond.command(`.output statbrowser:set_tabs_style ${style}`);
  statTabsTimer = setTimeout(() => {
    Byond.command(`.output statbrowser:set_tabs_style ${style}`);
  }, 1500);
}

export function generalSettingsHandler(update: SettingsState): void {
  if (update.theme) {
    setClientTheme(update.theme);
  }
  setStatTabsStyle(update.statTabsStyle);
  setGlobalFontSize(update.fontSize, update.statFontSize, update.statLinked);
  setGlobalFontFamily(update.fontFamily);
  updateGlobalOverrideRule();
}
