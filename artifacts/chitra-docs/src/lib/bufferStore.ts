// Editor-buffer overrides, scoped to this server boot.
//
// The Vite config injects `window.__CHITRA_BOOT_ID__` when the dev server starts
// (inline head script), so an edit survives refreshes and navigation ("local
// persistent") and dies exactly when the server restarts — the founder's
// requested lifetime.

const PREFIX = "chitra-buffer:";

function bootId(): string {
  return (
    ((globalThis as Record<string, unknown>).__CHITRA_BOOT_ID__ as string) ?? "adhoc"
  );
}

function key(id: string): string {
  return `${PREFIX}${bootId()}:${id}`;
}

export function loadBufferOverride(id: string): string | null {
  try {
    return localStorage.getItem(key(id));
  } catch {
    return null;
  }
}

export function saveBufferOverride(id: string, code: string): void {
  try {
    localStorage.setItem(key(id), code);
  } catch {
    /* private mode / quota — persistence is best-effort */
  }
}

export function clearBufferOverride(id: string): void {
  try {
    localStorage.removeItem(key(id));
  } catch {
    /* ignore */
  }
}

// Overrides stamped by previous server boots are dead — prune them so storage
// doesn't grow across restarts.
export function pruneStaleOverrides(): void {
  try {
    const live = `${PREFIX}${bootId()}:`;
    const dead: string[] = [];
    for (let i = 0; i < localStorage.length; i++) {
      const k = localStorage.key(i);
      if (k && k.startsWith(PREFIX) && !k.startsWith(live)) dead.push(k);
    }
    dead.forEach((k) => localStorage.removeItem(k));
  } catch {
    /* ignore */
  }
}
