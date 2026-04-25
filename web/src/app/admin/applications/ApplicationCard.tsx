"use client";

import { useState } from "react";

interface Application {
  id: string;
  applicant_name: string;
  applicant_email: string;
  motivation: string | null;
  status: string;
  created_at: string;
  cohorts: { name: string } | null;
}

const STATUS_CLASSES: Record<string, string> = {
  pending: "text-stone border-stone/40",
  approved: "text-sage border-sage/40",
  rejected: "text-error border-error/40",
  waitlisted: "text-foreground/60 border-foreground/20",
};

export function ApplicationCard({ application }: { application: Application }) {
  const [status, setStatus] = useState(application.status);
  const [expanded, setExpanded] = useState(false);
  const [loading, setLoading] = useState<string | null>(null);

  async function take(action: "approve" | "reject" | "waitlist") {
    setLoading(action);
    const res = await fetch(`/api/admin/applications/${application.id}`, {
      method: "PATCH",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ action }),
    });
    if (res.ok) {
      setStatus(action === "approve" ? "approved" : action === "reject" ? "rejected" : "waitlisted");
    }
    setLoading(null);
  }

  return (
    <li className="border border-foreground/10 p-5">
      <div className="flex items-start justify-between gap-4 mb-2">
        <div>
          <p className="text-sm font-medium">{application.applicant_name}</p>
          <p className="text-xs text-foreground/50">{application.applicant_email}</p>
          {application.cohorts && (
            <p className="text-xs text-sage mt-0.5">{application.cohorts.name}</p>
          )}
        </div>
        <span
          className={`text-xs px-2 py-0.5 border shrink-0 ${STATUS_CLASSES[status] ?? "text-foreground/60 border-foreground/20"}`}
        >
          {status}
        </span>
      </div>

      <p className="text-xs text-foreground/40 mb-3">
        {new Date(application.created_at).toLocaleDateString("en-US", {
          month: "short", day: "numeric", year: "numeric",
        })}
      </p>

      {application.motivation && (
        <div className="mb-3">
          <button
            onClick={() => setExpanded((e) => !e)}
            className="text-xs text-foreground/50 underline"
          >
            {expanded ? "Hide" : "Read"} motivation
          </button>
          {expanded && (
            <p className="mt-2 text-sm text-foreground/70 leading-relaxed whitespace-pre-wrap">
              {application.motivation}
            </p>
          )}
        </div>
      )}

      {status === "pending" && (
        <div className="flex gap-3 mt-3">
          <button
            onClick={() => take("approve")}
            disabled={!!loading}
            className="text-xs bg-sage text-white px-3 py-1.5 hover:opacity-80 transition-opacity disabled:opacity-50"
          >
            {loading === "approve" ? "…" : "Approve"}
          </button>
          <button
            onClick={() => take("waitlist")}
            disabled={!!loading}
            className="text-xs border border-foreground/20 px-3 py-1.5 hover:opacity-80 transition-opacity disabled:opacity-50"
          >
            {loading === "waitlist" ? "…" : "Waitlist"}
          </button>
          <button
            onClick={() => take("reject")}
            disabled={!!loading}
            className="text-xs text-error underline hover:opacity-70 transition-opacity disabled:opacity-50"
          >
            {loading === "reject" ? "…" : "Reject"}
          </button>
        </div>
      )}
    </li>
  );
}
