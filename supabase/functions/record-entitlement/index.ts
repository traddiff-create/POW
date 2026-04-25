import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

interface EntitlementRequest {
  userId: string;
  cohortId?: string;
  productId: string;
  transactionId: string;
  originalTransactionId: string;
  appAccountToken?: string;
  purchaseDate: string;
  expiresDate?: string;
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

    // Use service role key to bypass RLS for inserts
    const supabaseService = createClient(
      Deno.env.get("SUPABASE_URL") ?? "",
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? ""
    );

    // Verify the caller is who they claim to be
    const supabaseUser = createClient(
      Deno.env.get("SUPABASE_URL") ?? "",
      Deno.env.get("SUPABASE_ANON_KEY") ?? "",
      { global: { headers: { Authorization: authHeader } } }
    );

    const { data: { user }, error: authError } = await supabaseUser.auth.getUser();
    if (authError || !user) {
      return errorResponse(401, "Unauthorized");
    }

    const body: EntitlementRequest = await req.json();
    const {
      userId,
      cohortId,
      productId,
      transactionId,
      originalTransactionId,
      appAccountToken,
      purchaseDate,
      expiresDate,
    } = body;

    // Only the authenticated user can record their own entitlement
    if (user.id !== userId) {
      return errorResponse(403, "Cannot record entitlement for another user");
    }

    // 1. Insert purchase record
    const { error: purchaseError } = await supabaseService
      .from("purchases")
      .insert({
        user_id: userId,
        cohort_id: cohortId ?? null,
        storekit_product_id: productId,
        original_transaction_id: originalTransactionId,
        transaction_id: transactionId,
        app_account_token: appAccountToken ?? null,
        purchase_date: purchaseDate,
        expiration_date: expiresDate ?? null,
        status: "active",
      });

    if (purchaseError && !purchaseError.message.includes("duplicate")) {
      console.error("purchase insert error:", purchaseError);
      return errorResponse(500, "Failed to record purchase");
    }

    // 2. Upsert enrollment
    let membershipId: string | null = null;

    if (cohortId) {
      const { data: enrollment, error: enrollError } = await supabaseService
        .from("enrollments")
        .upsert(
          {
            user_id: userId,
            cohort_id: cohortId,
            status: "active",
            enrolled_at: new Date().toISOString(),
          },
          { onConflict: "user_id,cohort_id" }
        )
        .select("id")
        .single();

      if (enrollError) {
        console.error("enrollment upsert error:", enrollError);
        return errorResponse(500, "Failed to create enrollment");
      }

      membershipId = enrollment?.id ?? null;

      // 3. Send welcome notification
      await supabaseService.from("notifications").insert({
        user_id: userId,
        type: "enrollment",
        title: "Welcome to your cohort!",
        body: "Your enrollment is confirmed. Your journey begins now.",
      });
    }

    return new Response(
      JSON.stringify({ success: true, membershipId }),
      {
        headers: {
          "Content-Type": "application/json",
          "Access-Control-Allow-Origin": "*",
        },
      }
    );
  } catch (err) {
    console.error("record-entitlement error:", err);
    return errorResponse(500, "Internal server error");
  }
});

function errorResponse(status: number, message: string): Response {
  return new Response(JSON.stringify({ success: false, error: message }), {
    status,
    headers: {
      "Content-Type": "application/json",
      "Access-Control-Allow-Origin": "*",
    },
  });
}
