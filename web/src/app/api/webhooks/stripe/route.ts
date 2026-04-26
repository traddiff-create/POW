import { NextResponse } from "next/server";

export async function POST() {
  return NextResponse.json(
    { error: "Stripe checkout is disabled for the iOS-first v1 launch." },
    { status: 410 }
  );
}
