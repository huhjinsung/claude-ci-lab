export function charge(amount) {
  if (typeof amount !== "number" || !Number.isFinite(amount) || amount <= 0) {
    return { ok: false, error: "invalid amount" };
  }
  return { ok: true, amount, currency: "KRW" };
}
