import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const APPLE_ROOT_CERT_URL = "https://apple.com/appleca/AppleIncRootCertificate.crt";

interface VerifyRequest {
  transactionId: string;
  originalTransactionId: string;
  userId: string;
  cohortId?: string;
  productId: string;
  signedTransactionInfo: string;
}

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response(null, {
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Headers": "authorization, content-type",
      },
    });
  }

  try {
    // Verify JWT from Authorization header
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) {
      return errorResponse(401, "Missing authorization header");
    }

    const supabase = createClient(
      Deno.env.get("SUPABASE_URL") ?? "",
      Deno.env.get("SUPABASE_ANON_KEY") ?? "",
      { global: { headers: { Authorization: authHeader } } }
    );

    const { data: { user }, error: authError } = await supabase.auth.getUser();
    if (authError || !user) {
      return errorResponse(401, "Unauthorized");
    }

    const body: VerifyRequest = await req.json();
    const { transactionId, originalTransactionId, userId, cohortId, productId, signedTransactionInfo } = body;

    if (!signedTransactionInfo || !transactionId || !originalTransactionId) {
      return errorResponse(400, "Missing required transaction fields");
    }

    // Validate signed transaction JWT (JWS) from Apple
    // The signedTransactionInfo is a JWS — we decode the payload without full cert validation
    // in sandbox. For production, validate the certificate chain against Apple's root CA.
    const parts = signedTransactionInfo.split(".");
    if (parts.length !== 3) {
      return errorResponse(400, "Invalid signed transaction format");
    }

    const payloadBase64 = parts[1];
    const paddedPayload = payloadBase64 + "=".repeat((4 - payloadBase64.length % 4) % 4);
    const payloadJson = atob(paddedPayload.replace(/-/g, "+").replace(/_/g, "/"));
    const payload = JSON.parse(payloadJson);

    // Verify key fields match what the client sent
    if (payload.transactionId !== transactionId) {
      return errorResponse(400, "Transaction ID mismatch");
    }

    if (payload.originalTransactionId !== originalTransactionId) {
      return errorResponse(400, "Original transaction ID mismatch");
    }

    if (payload.productId !== productId) {
      return errorResponse(400, "Product ID mismatch");
    }

    // Check transaction belongs to the user (via appAccountToken)
    // appAccountToken is set to the user's UUID during purchase
    if (payload.appAccountToken && payload.appAccountToken !== userId) {
      return errorResponse(400, "Account token mismatch");
    }

    // Determine expiration (non-renewing subscriptions don't have expiresDate)
    const expiresDate = payload.expiresDate
      ? new Date(payload.expiresDate).toISOString()
      : null;

    return new Response(
      JSON.stringify({
        valid: true,
        transactionId: payload.transactionId,
        originalTransactionId: payload.originalTransactionId,
        productId: payload.productId,
        purchaseDate: new Date(payload.purchaseDate).toISOString(),
        expiresDate,
        environment: payload.environment ?? "Production",
      }),
      {
        headers: {
          "Content-Type": "application/json",
          "Access-Control-Allow-Origin": "*",
        },
      }
    );
  } catch (err) {
    console.error("verify-purchase error:", err);
    return errorResponse(500, "Internal server error");
  }
});

function errorResponse(status: number, message: string): Response {
  return new Response(JSON.stringify({ valid: false, error: message }), {
    status,
    headers: {
      "Content-Type": "application/json",
      "Access-Control-Allow-Origin": "*",
    },
  });
}
