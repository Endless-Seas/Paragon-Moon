import { resetChatReliability } from '../../chat/handlers';
import { saveChatToStorage } from '../../chat/helpers';
import { roundRestartedAtAtom } from '../../game/atoms';
import { store } from '../store';

export function handleRoundRestart(): void {
  resetChatReliability();
  store.set(roundRestartedAtAtom, Date.now());
  saveChatToStorage();
}
