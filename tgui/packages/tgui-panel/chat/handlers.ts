import { MAX_PERSISTED_MESSAGES } from './constants';
import { chatRenderer } from './renderer';

const MAX_SEQUENCE_HISTORY = MAX_PERSISTED_MESSAGES;
// DM retains five batches, including the newest batch that revealed the gap.
const MAX_RESEND_REQUESTS = 4;
const RESEND_INTERVAL = 1000;

const seenSequences = new Set<number>();
const sequenceOrder: number[] = [];
const requestedSequences = new Set<number>();
const requestedOrder: number[] = [];
let highestSequence: number | null = null;
let resendQueue: number[] = [];
let resendTimer: ReturnType<typeof setTimeout> | undefined;

function sendNextResend(): void {
  resendTimer = undefined;
  const sequence = resendQueue.shift();
  if (sequence === undefined) return;
  if (requestedSequences.has(sequence)) {
    Byond.sendMessage('chat/resend', sequence);
  }
  // Keep a cooldown even when this request emptied the queue.
  resendTimer = setTimeout(sendNextResend, RESEND_INTERVAL);
}

type ChatMessage = {
  sequence: number;
  content: any;
};

function rememberSequence(sequence: number): void {
  seenSequences.add(sequence);
  sequenceOrder.push(sequence);
  while (sequenceOrder.length > MAX_SEQUENCE_HISTORY) {
    const expired = sequenceOrder.shift();
    if (expired !== undefined) {
      seenSequences.delete(expired);
    }
  }
}

function requestMissingSequences(from: number, to: number): void {
  let requested = 0;
  for (
    let sequence = Math.max(from, to - MAX_RESEND_REQUESTS);
    sequence < to && requested < MAX_RESEND_REQUESTS;
    sequence++
  ) {
    if (seenSequences.has(sequence) || requestedSequences.has(sequence)) {
      continue;
    }
    requestedSequences.add(sequence);
    requestedOrder.push(sequence);
    while (requestedOrder.length > MAX_RESEND_REQUESTS) {
      const expired = requestedOrder.shift();
      if (expired !== undefined) {
        requestedSequences.delete(expired);
      }
    }
    requested++;
    resendQueue = resendQueue.filter((queued) =>
      requestedSequences.has(queued),
    );
    resendQueue.push(sequence);
  }
  if (!resendTimer) sendNextResend();
}

function parseChatMessage(payload: unknown): ChatMessage | null {
  if (typeof payload !== 'string') {
    return null;
  }

  try {
    const parsed = JSON.parse(payload);
    if (
      !parsed ||
      !Number.isSafeInteger(parsed.sequence) ||
      parsed.sequence < 0 ||
      !('content' in parsed)
    ) {
      return null;
    }
    return parsed as ChatMessage;
  } catch {
    return null;
  }
}

/** Handles ordered chat batches while keeping deduplication bounded. */
export function chatMessage(payload: unknown): void {
  const message = parseChatMessage(payload);
  if (!message || seenSequences.has(message.sequence)) {
    return;
  }

  const requested = requestedSequences.delete(message.sequence);
  if (requested) {
    const requestedIndex = requestedOrder.indexOf(message.sequence);
    if (requestedIndex !== -1) requestedOrder.splice(requestedIndex, 1);
  }
  if (
    highestSequence !== null &&
    message.sequence < highestSequence &&
    !requested
  ) {
    // An old message that was not requested is stale; do not duplicate it.
    return;
  }

  if (highestSequence !== null && message.sequence > highestSequence + 1) {
    requestMissingSequences(highestSequence + 1, message.sequence);
  }

  highestSequence =
    highestSequence === null
      ? message.sequence
      : Math.max(highestSequence, message.sequence);
  rememberSequence(message.sequence);
  chatRenderer.processBatch([message.content]);
}

/** Used by focused tests and by a full panel reload after a round reset. */
export function resetChatReliability(): void {
  clearTimeout(resendTimer);
  resendTimer = undefined;
  resendQueue = [];
  seenSequences.clear();
  sequenceOrder.length = 0;
  requestedSequences.clear();
  requestedOrder.length = 0;
  highestSequence = null;
}

export const chatReliabilityLimits = {
  maxSequenceHistory: MAX_SEQUENCE_HISTORY,
  maxResendRequests: MAX_RESEND_REQUESTS,
};
