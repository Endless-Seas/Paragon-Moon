import { createStore } from 'jotai';

/** The chat panel owns this store; it is never shared with a TGUI window. */
export const store = createStore();
