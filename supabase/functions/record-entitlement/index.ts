const ALLOWED_ORIGINS = new Set([
  "https://apieceofwhole.com",
  "https://www.apieceofwhole.com",
  "http://127.0.0.1:3000",
  "http://localhost:3000",
  "null",
]);

Deno.serve((req) => {
  if (req.method === "OPTIONS") {
    const headers = responseHeaders(req);
    headers.set("Access-Control-Allow-Headers", "authorization, content-type");
    headers.set("Access-Control-Allow-Methods", "POST, OPTIONS");
    return new Response(null, { status: 204, headers });
  }

  return jsonResponse(req, 410, {
    success: false,
    error: "record-entitlement is disabled. Verify StoreKit transactions through verify-purchase.",
  });
});

function jsonResponse(req: Request, status: number, body: Record<string, unknown>): Response {
  const headers = responseHeaders(req);
  headers.set("Content-Type", "application/json");
  return new Response(JSON.stringify(body), { status, headers });
}

function responseHeaders(req: Request): Headers {
  const headers = new Headers({ "Vary": "Origin" });
  const origin = req.headers.get("Origin");
  if (origin && ALLOWED_ORIGINS.has(origin)) {
    headers.set("Access-Control-Allow-Origin", origin);
  }
  return headers;
}
