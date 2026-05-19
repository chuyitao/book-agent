import { getToken } from "../utils/auth";

export interface ChatDTO {
  question: string;
  sessionId: string;
}

/** 与后端 `ChatEventVO` 对齐：eventType + eventData */
export interface ChatEventPayload {
  eventType: number;
  eventData?: unknown;
}

export function getChatApiBase(): string {
  return import.meta.env.DEV ? "/api" : "http://localhost:8099";
}

/**
 * 解析 SSE 中合并后的 data 段为 ChatEventVO。
 * 后端 Spring 序列化为 JSON：`{"eventType":1,"eventData":"..."}` 等。
 */
function parseChatEventPayload(merged: string): ChatEventPayload | null {
  const t = merged.trim();
  if (!t || t === "[DONE]") return null;
  if (t.startsWith("{")) {
    try {
      const o = JSON.parse(t) as { eventType?: unknown; eventData?: unknown };
      if (o.eventType !== undefined && o.eventType !== null) {
        const eventType = Number(o.eventType);
        if (!Number.isFinite(eventType)) return null;
        return { eventType, eventData: o.eventData };
      }
    } catch {
      return null;
    }
  }
  // 兼容：仅 JSON 字符串包一层引号的纯文本
  if (t.startsWith('"') && t.endsWith('"')) {
    try {
      const inner = JSON.parse(t) as string;
      if (typeof inner === "string") return { eventType: 1, eventData: inner };
    } catch {
      /* fallthrough */
    }
  }
  if (t) return { eventType: 1, eventData: t };
  return null;
}

function feedSseLines(
  buffer: string,
  carry: { rest: string },
  onEvent: (e: ChatEventPayload) => void,
): void {
  carry.rest += buffer;
  const lines = carry.rest.split(/\n/);
  carry.rest = lines.pop() ?? "";
  let dataLines: string[] = [];
  for (const line of lines) {
    const trimmed = line.trimEnd();
    if (trimmed === "") {
      if (dataLines.length) {
        const merged = dataLines.join("\n");
        const ev = parseChatEventPayload(merged);
        if (ev) onEvent(ev);
        dataLines = [];
      }
      continue;
    }
    if (trimmed.startsWith("data:")) {
      dataLines.push(trimmed.slice(5).trimStart());
    }
  }
}

/**
 * 流式对话：POST /chat/stream
 * 请求体：`{ question, sessionId }`；响应 `text/event-stream`，每条为后端 `ChatEventVO` 的 JSON。
 * - eventType 1：大模型文本片段，eventData 为 string
 * - eventType 2：工具附加数据（如天气），eventData 为 object
 * - eventType 3：结束标记，无正文
 */
export async function chatStreamApi(
  payload: ChatDTO,
  onEvent: (e: ChatEventPayload) => void,
  options?: { signal?: AbortSignal },
): Promise<void> {
  const url = `${getChatApiBase()}/chat/stream`;
  const token = getToken();
  const headers: Record<string, string> = {
    "Content-Type": "application/json",
    Accept: "text/event-stream",
  };
  if (token) headers.token = token;

  const res = await fetch(url, {
    method: "POST",
    headers,
    body: JSON.stringify(payload),
    signal: options?.signal,
  });

  if (!res.ok) {
    const errText = await res.text().catch(() => "");
    const err = new Error(errText || `HTTP ${res.status}`) as Error & { status: number };
    err.status = res.status;
    throw err;
  }

  const reader = res.body?.getReader();
  if (!reader) {
    const text = await res.text();
    const ev = parseChatEventPayload(text.trim());
    if (ev) onEvent(ev);
    return;
  }

  const decoder = new TextDecoder();
  const carry = { rest: "" };
  while (true) {
    const { done, value } = await reader.read();
    if (done) break;
    feedSseLines(decoder.decode(value, { stream: true }), carry, onEvent);
  }
  if (carry.rest.trim()) feedSseLines("\n", carry, onEvent);
}
