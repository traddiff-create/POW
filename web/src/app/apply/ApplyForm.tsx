"use client";

import { useState } from "react";
import { useForm, useWatch } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { z } from "zod";
import Link from "next/link";

const schema = z.object({
  name: z.string().min(1, "Name is required"),
  email: z.string().email("Enter a valid email"),
  cohort_id: z.string().min(1, "Select a cohort"),
  motivation: z.string().min(100, "Please write at least 100 characters"),
  crisis: z.enum(["yes", "no"], "Please answer this question"),
  age_confirmed: z.boolean().refine((v) => v, "You must confirm you are 18 or older"),
  disclaimer_confirmed: z.boolean().refine((v) => v, "You must confirm this is not therapy"),
  how_heard: z.string().optional(),
});

type FormValues = z.infer<typeof schema>;

interface Cohort {
  id: string;
  name: string;
}

export function ApplyForm({ cohorts, defaultCohortId }: { cohorts: Cohort[]; defaultCohortId?: string }) {
  const [submitted, setSubmitted] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [submitting, setSubmitting] = useState(false);

  const { register, handleSubmit, control, formState: { errors } } = useForm<FormValues>({
    resolver: zodResolver(schema),
    defaultValues: { cohort_id: defaultCohortId ?? "" },
  });

  const crisis = useWatch({ control, name: "crisis" });

  async function onSubmit(values: FormValues) {
    if (values.crisis === "yes") return;
    setSubmitting(true);
    setError(null);
    try {
      const res = await fetch("/api/apply", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          name: values.name,
          email: values.email,
          cohort_id: values.cohort_id,
          motivation: values.motivation,
          how_heard: values.how_heard,
        }),
      });
      if (!res.ok) throw new Error("Submission failed");
      setSubmitted(true);
    } catch {
      setError("Something went wrong. Please try again.");
    } finally {
      setSubmitting(false);
    }
  }

  if (submitted) {
    return (
      <div className="text-center py-12">
        <h2 className="text-2xl mb-4">Thank you.</h2>
        <p className="text-foreground/70 max-w-md mx-auto">
          Your application has been received. A human will review it and you&apos;ll hear from us within 48 hours.
        </p>
      </div>
    );
  }

  if (crisis === "yes") {
    return (
      <div className="text-center py-12 max-w-lg mx-auto">
        <h2 className="text-2xl mb-4">We&apos;re glad you reached out.</h2>
        <p className="text-foreground/70 mb-6">
          Right now, the most important thing is your safety. Please reach out to one of these resources — they are free, confidential, and available now.
        </p>
        <div className="text-left space-y-3 bg-foreground/5 p-6">
          <p><strong>988 Suicide and Crisis Lifeline:</strong> Call or text 988</p>
          <p><strong>Crisis Text Line:</strong> Text HOME to 741741</p>
          <p><strong>NAMI Helpline:</strong> 1-800-950-6264</p>
        </div>
        <p className="text-sm text-foreground/60 mt-6">
          <Link href="/crisis" className="underline">See all crisis resources →</Link>
        </p>
        <p className="text-sm text-foreground/60 mt-4">
          We hope you&apos;ll apply to a future cohort when you&apos;re in a more stable place.
        </p>
      </div>
    );
  }

  return (
    <form onSubmit={handleSubmit(onSubmit)} className="space-y-8 max-w-xl mx-auto">
      <div>
        <label className="block text-sm font-medium mb-1" htmlFor="name">Full name</label>
        <input
          id="name"
          type="text"
          className="w-full border border-foreground/20 px-4 py-3 bg-white focus:outline-none focus:border-sage"
          {...register("name")}
        />
        {errors.name && <p className="text-error text-sm mt-1">{errors.name.message}</p>}
      </div>

      <div>
        <label className="block text-sm font-medium mb-1" htmlFor="email">Email</label>
        <input
          id="email"
          type="email"
          className="w-full border border-foreground/20 px-4 py-3 bg-white focus:outline-none focus:border-sage"
          {...register("email")}
        />
        {errors.email && <p className="text-error text-sm mt-1">{errors.email.message}</p>}
      </div>

      <div>
        <label className="block text-sm font-medium mb-1" htmlFor="cohort_id">Which cohort?</label>
        <select
          id="cohort_id"
          className="w-full border border-foreground/20 px-4 py-3 bg-white focus:outline-none focus:border-sage"
          {...register("cohort_id")}
        >
          <option value="">Select a cohort</option>
          {cohorts.map((c) => (
            <option key={c.id} value={c.id}>{c.name}</option>
          ))}
        </select>
        {errors.cohort_id && <p className="text-error text-sm mt-1">{errors.cohort_id.message}</p>}
      </div>

      <div>
        <label className="block text-sm font-medium mb-1" htmlFor="motivation">
          Why are you applying? <span className="text-foreground/50 font-normal">(at least 100 characters — a human will read this)</span>
        </label>
        <textarea
          id="motivation"
          rows={6}
          className="w-full border border-foreground/20 px-4 py-3 bg-white focus:outline-none focus:border-sage resize-none"
          {...register("motivation")}
        />
        {errors.motivation && <p className="text-error text-sm mt-1">{errors.motivation.message}</p>}
      </div>

      <div>
        <fieldset>
          <legend className="block text-sm font-medium mb-3">
            Are you currently in active mental health crisis?
          </legend>
          <div className="space-y-2">
            <label className="flex items-center gap-3 cursor-pointer">
              <input type="radio" value="no" {...register("crisis")} className="accent-sage" />
              No
            </label>
            <label className="flex items-center gap-3 cursor-pointer">
              <input type="radio" value="yes" {...register("crisis")} className="accent-sage" />
              Yes
            </label>
          </div>
          {errors.crisis && <p className="text-error text-sm mt-1">{errors.crisis.message}</p>}
        </fieldset>
      </div>

      <div className="space-y-3">
        <label className="flex items-start gap-3 cursor-pointer">
          <input type="checkbox" {...register("age_confirmed")} className="mt-0.5 accent-sage" />
          <span className="text-sm">I confirm I am 18 years of age or older</span>
        </label>
        {errors.age_confirmed && <p className="text-error text-sm">{errors.age_confirmed.message}</p>}

        <label className="flex items-start gap-3 cursor-pointer">
          <input type="checkbox" {...register("disclaimer_confirmed")} className="mt-0.5 accent-sage" />
          <span className="text-sm">
            I understand that A Piece of Whole is not therapy, not medical advice, and not a substitute for professional mental health treatment.{" "}
            <Link href="/disclaimer" className="underline" target="_blank">Learn more</Link>
          </span>
        </label>
        {errors.disclaimer_confirmed && <p className="text-error text-sm">{errors.disclaimer_confirmed.message}</p>}
      </div>

      <div>
        <label className="block text-sm font-medium mb-1" htmlFor="how_heard">
          How did you hear about us? <span className="text-foreground/50 font-normal">(optional)</span>
        </label>
        <input
          id="how_heard"
          type="text"
          className="w-full border border-foreground/20 px-4 py-3 bg-white focus:outline-none focus:border-sage"
          {...register("how_heard")}
        />
      </div>

      {error && <p className="text-error text-sm">{error}</p>}

      <button
        type="submit"
        disabled={submitting}
        className="w-full bg-sage text-white py-4 text-base hover:opacity-90 transition-opacity disabled:opacity-50"
      >
        {submitting ? "Submitting…" : "Submit Application"}
      </button>
    </form>
  );
}
