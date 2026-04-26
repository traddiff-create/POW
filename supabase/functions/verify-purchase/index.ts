import "https://esm.sh/reflect-metadata@0.2.2";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { decodeProtectedHeader, importX509, jwtVerify } from "https://esm.sh/jose@5.9.6";
import {
  X509Certificate,
  X509ChainBuilder,
} from "https://esm.sh/@peculiar/x509@2.0.0";

interface VerifyRequest {
  transactionId: string;
  originalTransactionId: string;
  userId: string;
  cohortId: string;
  productId: string;
  appAccountToken?: string;
  purchaseDate?: string;
  expiresDate?: string;
  signedTransactionInfo: string;
}

interface AppleTransactionPayload {
  transactionId?: string;
  originalTransactionId?: string;
  productId?: string;
  appAccountToken?: string;
  purchaseDate?: number | string;
  expiresDate?: number | string;
  revocationDate?: number | string;
  environment?: string;
  bundleId?: string;
}

interface ExistingPurchase {
  id: string;
  user_id: string;
  cohort_id: string | null;
}

const APPLE_APP_STORE_RECEIPT_SIGNING_OID = "1.2.840.113635.100.6.11.1";
const APPLE_ROOT_CA_G3_SHA256 = "63343abfb89a6a03ebb57e9b3f5fa7be7c4f5c756f3017b3a8c488c3653e9179";
const MAX_NEW_TRANSACTION_AGE_MS = 30 * 24 * 60 * 60 * 1000;
const ALLOWED_ORIGINS = new Set([
  "https://apieceofwhole.com",
  "https://www.apieceofwhole.com",
  "http://127.0.0.1:3000",
  "http://localhost:3000",
  "null",
]);

const APPLE_ROOT_CA_G3_PEM = `-----BEGIN CERTIFICATE-----
MIICQzCCAcmgAwIBAgIILcX8iNLFS5UwCgYIKoZIzj0EAwMwZzEbMBkGA1UEAwwS
QXBwbGUgUm9vdCBDQSAtIEczMSYwJAYDVQQLDB1BcHBsZSBDZXJ0aWZpY2F0aW9u
IEF1dGhvcml0eTETMBEGA1UECgwKQXBwbGUgSW5jLjELMAkGA1UEBhMCVVMwHhcN
MTQwNDMwMTgxOTA2WhcNMzkwNDMwMTgxOTA2WjBnMRswGQYDVQQDDBJBcHBsZSBS
b290IENBIC0gRzMxJjAkBgNVBAsMHUFwcGxlIENlcnRpZmljYXRpb24gQXV0aG9y
aXR5MRMwEQYDVQQKDApBcHBsZSBJbmMuMQswCQYDVQQGEwJVUzB2MBAGByqGSM49
AgEGBSuBBAAiA2IABJjpLz1AcqTtkyJygRMc3RCV8cWjTnHcFBbZDuWmBSp3ZHtf
TjjTuxxEtX/1H7YyYl3J6YRbTzBPEVoA/VhYDKX1DyxNB0cTddqXl5dvMVztK517
IDvYuVTZXpmkOlEKMaNCMEAwHQYDVR0OBBYEFLuw3qFYM4iapIqZ3r6966/ayySr
MA8GA1UdEwEB/wQFMAMBAf8wDgYDVR0PAQH/BAQDAgEGMAoGCCqGSM49BAMDA2gA
MGUCMQCD6cHEFl4aXTQY2e3v9GwOAEZLuN+yRhHFD/3meoyhpmvOwgPUnPWTxnS4
at+qIxUCMG1mihDK1A3UT82NQz60imOlM27jbdoXt2QfyFMm+YhidDkLF1vLUagM
6BgD56KyKA==
-----END CERTIFICATE-----`;

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return optionsResponse(req);
  }

  if (req.method !== "POST") {
    return errorResponse(req, 405, "Method not allowed");
  }

  try {
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) {
      return errorResponse(req, 401, "Missing authorization header");
    }

    const supabaseURL = requiredEnv("SUPABASE_URL");
    const supabaseAnonKey = requiredEnv("SUPABASE_ANON_KEY");
    const serviceRoleKey = requiredEnv("SUPABASE_SERVICE_ROLE_KEY");
    const expectedBundleID = requiredEnv("APPLE_BUNDLE_ID");

    const supabaseUser = createClient(supabaseURL, supabaseAnonKey, {
      global: { headers: { Authorization: authHeader } },
    });

    const { data: { user }, error: authError } = await supabaseUser.auth.getUser();
    if (authError || !user) {
      return errorResponse(req, 401, "Unauthorized");
    }

    const body: VerifyRequest = await req.json();
    const {
      transactionId,
      originalTransactionId,
      userId,
      cohortId,
      productId,
      signedTransactionInfo,
    } = body;

    if (!transactionId || !originalTransactionId || !userId || !cohortId || !productId || !signedTransactionInfo) {
      return errorResponse(req, 400, "Missing required transaction fields");
    }

    if (user.id !== userId) {
      return errorResponse(req, 403, "Cannot verify a purchase for another user");
    }

    const payload = await verifySignedTransaction(signedTransactionInfo);

    if (payload.transactionId !== transactionId) {
      return errorResponse(req, 400, "Transaction ID mismatch");
    }

    if (payload.originalTransactionId !== originalTransactionId) {
      return errorResponse(req, 400, "Original transaction ID mismatch");
    }

    if (payload.productId !== productId) {
      return errorResponse(req, 400, "Product ID mismatch");
    }

    if (!payload.bundleId || payload.bundleId !== expectedBundleID) {
      return errorResponse(req, 400, "Bundle ID mismatch");
    }

    const accountToken = normalizeUUID(payload.appAccountToken ?? body.appAccountToken);
    if (accountToken && accountToken !== normalizeUUID(userId)) {
      return errorResponse(req, 400, "Account token mismatch");
    }

    if (payload.revocationDate) {
      return errorResponse(req, 400, "Transaction has been revoked");
    }

    const purchaseDate = parseAppleDate(payload.purchaseDate ?? body.purchaseDate);
    if (!purchaseDate) {
      return errorResponse(req, 400, "Invalid purchase date");
    }

    const expiresDate = parseAppleDate(payload.expiresDate ?? body.expiresDate);
    if (expiresDate && new Date(expiresDate).getTime() <= Date.now()) {
      return errorResponse(req, 400, "Transaction has expired");
    }

    const supabaseService = createClient(supabaseURL, serviceRoleKey);

    const cohort = await resolveCohort(supabaseService, cohortId, productId);
    if (!cohort) {
      return errorResponse(req, 400, "Cohort not found for product");
    }

    const { data: existingPurchase, error: existingPurchaseError } = await supabaseService
      .from("purchases")
      .select("id, user_id, cohort_id")
      .eq("original_transaction_id", originalTransactionId)
      .maybeSingle();

    if (existingPurchaseError) {
      logError("purchase lookup error", existingPurchaseError);
      return errorResponse(req, 500, "Failed to check purchase ownership");
    }

    const purchase = existingPurchase as ExistingPurchase | null;

    if (purchase && purchase.user_id !== userId) {
      return errorResponse(req, 409, "Transaction already belongs to another user");
    }

    if (purchase?.cohort_id && purchase.cohort_id !== cohort.id) {
      return errorResponse(req, 409, "Transaction already belongs to another cohort");
    }

    if (!purchase && Date.now() - new Date(purchaseDate).getTime() > MAX_NEW_TRANSACTION_AGE_MS) {
      return errorResponse(req, 400, "Transaction is too old to verify as a new purchase");
    }

    const { error: purchaseError } = await supabaseService
      .from("purchases")
      .upsert(
        {
          user_id: userId,
          cohort_id: cohort.id,
          storekit_product_id: productId,
          original_transaction_id: originalTransactionId,
          transaction_id: transactionId,
          app_account_token: accountToken,
          purchase_date: purchaseDate,
          expiration_date: expiresDate,
          status: "active",
        },
        { onConflict: "original_transaction_id" }
      );

    if (purchaseError) {
      logError("purchase upsert error", purchaseError);
      return errorResponse(req, 500, "Failed to record purchase");
    }

    const { data: enrollment, error: enrollError } = await supabaseService
      .from("enrollments")
      .upsert(
        {
          user_id: userId,
          cohort_id: cohort.id,
          status: "active",
          enrolled_at: new Date().toISOString(),
        },
        { onConflict: "user_id,cohort_id" }
      )
      .select("id")
      .single();

    if (enrollError) {
      logError("enrollment upsert error", enrollError);
      return errorResponse(req, 500, "Failed to create enrollment");
    }

    await ensureEnrollmentNotification(supabaseService, userId, cohort.id);

    return jsonResponse(req, 200, {
      success: true,
      valid: true,
      enrolled: true,
      enrollmentId: enrollment?.id ?? null,
      environment: payload.environment ?? null,
    });
  } catch (err) {
    logError("verify-purchase error", err);
    if (err instanceof MissingEnvError) {
      return errorResponse(req, 503, "Purchase verification is temporarily unavailable");
    }
    return errorResponse(req, 500, "Internal server error");
  }
});

async function verifySignedTransaction(signedTransactionInfo: string): Promise<AppleTransactionPayload> {
  const header = decodeProtectedHeader(signedTransactionInfo) as { alg?: string; x5c?: string[] };
  if (header.alg !== "ES256" || !header.x5c || header.x5c.length < 2) {
    throw new Error("Invalid StoreKit transaction header");
  }

  const leaf = await verifyAppleCertificateChain(header.x5c);
  const key = await importX509(certificateFromX5C(header.x5c[0]), "ES256");
  const { payload } = await jwtVerify(signedTransactionInfo, key, {
    algorithms: ["ES256"],
  });

  if (!leaf.getExtension(APPLE_APP_STORE_RECEIPT_SIGNING_OID)) {
    throw new Error("StoreKit signing extension is missing");
  }

  return payload as AppleTransactionPayload;
}

async function verifyAppleCertificateChain(x5c: string[]): Promise<X509Certificate> {
  const leaf = new X509Certificate(x5c[0]);
  const suppliedIssuers = x5c.slice(1).map((encoded) => new X509Certificate(encoded));
  const pinnedRoot = new X509Certificate(APPLE_ROOT_CA_G3_PEM);
  const builder = new X509ChainBuilder({ certificates: [...suppliedIssuers, pinnedRoot] });
  const chain = await builder.build(leaf);

  if (chain.length < 2) {
    throw new Error("StoreKit certificate chain is incomplete");
  }

  const root = chain[chain.length - 1];
  const rootFingerprint = await sha256Hex(root.rawData);
  if (rootFingerprint !== APPLE_ROOT_CA_G3_SHA256) {
    throw new Error("StoreKit certificate chain does not terminate at Apple Root CA G3");
  }

  for (let index = 0; index < chain.length; index += 1) {
    assertCertificateDate(chain[index]);

    if (index < chain.length - 1) {
      const issuer = chain[index + 1];
      const valid = await chain[index].verify({ publicKey: issuer.publicKey });
      if (!valid) {
        throw new Error("Invalid StoreKit certificate signature");
      }
    }
  }

  const rootValid = await root.verify({ publicKey: pinnedRoot.publicKey });
  if (!rootValid) {
    throw new Error("Pinned Apple root certificate is invalid");
  }

  return leaf;
}

async function resolveCohort(
  supabaseService: any,
  cohortId: string,
  productId: string
): Promise<{ id: string; storekit_product_id: string | null } | null> {
  const { data, error } = await supabaseService
    .from("cohorts")
    .select("id, storekit_product_id")
    .eq("id", cohortId)
    .single();

  if (error || !data) return null;
  const cohort = data as { id: string; storekit_product_id: string | null };
  if (cohort.storekit_product_id && cohort.storekit_product_id !== productId) return null;
  return cohort;
}

async function ensureEnrollmentNotification(
  supabaseService: any,
  userId: string,
  cohortId: string
) {
  const actionTarget = `enrollment:${cohortId}`;
  const { data: existing } = await supabaseService
    .from("notifications")
    .select("id")
    .eq("user_id", userId)
    .eq("action_target", actionTarget)
    .limit(1)
    .maybeSingle();

  if (existing) return;

  const { error } = await supabaseService.from("notifications").insert({
    user_id: userId,
    type: "enrollment",
    title: "Welcome to your cohort!",
    body: "Your enrollment is confirmed. Your journey begins now.",
    action_target: actionTarget,
  });

  if (error) {
    logError("notification insert error", error);
  }
}

function certificateFromX5C(encodedCertificate: string): string {
  const lines = encodedCertificate.match(/.{1,64}/g)?.join("\n") ?? encodedCertificate;
  return `-----BEGIN CERTIFICATE-----\n${lines}\n-----END CERTIFICATE-----`;
}

function assertCertificateDate(certificate: X509Certificate) {
  const now = Date.now();
  if (certificate.notBefore.getTime() > now || certificate.notAfter.getTime() <= now) {
    throw new Error("StoreKit certificate is outside its validity window");
  }
}

async function sha256Hex(data: BufferSource): Promise<string> {
  const digest = await crypto.subtle.digest("SHA-256", data);
  return [...new Uint8Array(digest)]
    .map((byte) => byte.toString(16).padStart(2, "0"))
    .join("");
}

function normalizeUUID(value: string | undefined): string | null {
  return value ? value.toLowerCase() : null;
}

function parseAppleDate(value: number | string | undefined): string | null {
  if (value === undefined || value === null || value === "") return null;
  const date = typeof value === "number" || /^\d+$/.test(String(value))
    ? new Date(Number(value))
    : new Date(value);
  return Number.isNaN(date.getTime()) ? null : date.toISOString();
}

function optionsResponse(req: Request): Response {
  const headers = responseHeaders(req);
  headers.set("Access-Control-Allow-Headers", "authorization, content-type");
  headers.set("Access-Control-Allow-Methods", "POST, OPTIONS");
  return new Response(null, { status: 204, headers });
}

function jsonResponse(req: Request, status: number, body: Record<string, unknown>): Response {
  const headers = responseHeaders(req);
  headers.set("Content-Type", "application/json");
  return new Response(JSON.stringify(body), { status, headers });
}

function errorResponse(req: Request, status: number, message: string): Response {
  return jsonResponse(req, status, { success: false, valid: false, error: message });
}

function responseHeaders(req: Request): Headers {
  const headers = new Headers({ "Vary": "Origin" });
  const origin = req.headers.get("Origin");
  if (origin && ALLOWED_ORIGINS.has(origin)) {
    headers.set("Access-Control-Allow-Origin", origin);
  }
  return headers;
}

function requiredEnv(name: string): string {
  const value = Deno.env.get(name);
  if (!value) throw new MissingEnvError(name);
  return value;
}

function logError(context: string, error: unknown) {
  if (error && typeof error === "object") {
    const record = error as { code?: unknown; message?: unknown; name?: unknown };
    console.error(context, {
      code: record.code ? String(record.code) : undefined,
      message: record.message ? String(record.message) : record.name ? String(record.name) : "Unknown error",
    });
    return;
  }

  console.error(context, { message: String(error) });
}

class MissingEnvError extends Error {
  override name: string;

  constructor(name: string) {
    super(`Missing required environment variable: ${name}`);
    this.name = name;
  }
}
