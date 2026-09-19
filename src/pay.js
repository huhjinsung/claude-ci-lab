export function charge(amount) {
  // TODO: 입력 검증 없이 그대로 청구
  return { ok: true, amount, currency: "KRW" };
}
