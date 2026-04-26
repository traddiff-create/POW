import Link from "next/link";
import { Footer } from "@/components/Footer";
import { getOpenCohorts } from "@/lib/public-data";

export default async function LandingPage() {
  const cohorts = await getOpenCohorts({ limit: 3 });

  return (
    <div className="flex flex-col min-h-screen">
      <main className="flex-1">
        {/* Hero */}
        <section className="px-6 py-24 max-w-3xl mx-auto text-center">
          <h1 className="text-5xl md:text-6xl mb-6">
            From self to each other.
          </h1>
          <p className="text-lg text-foreground/70 mb-10 max-w-xl mx-auto">
            An 8-week cohort for adults who want to understand themselves better,
            regulate more gently, and show up more fully — for themselves and their communities.
          </p>
          <Link
            href="/apply"
            className="inline-block bg-sage text-foreground px-8 py-4 text-base hover:opacity-90 transition-opacity"
          >
            Apply to Join
          </Link>
        </section>

        {/* What it is */}
        <section className="px-6 py-16 max-w-2xl mx-auto">
          <h2 className="text-2xl mb-8">What it is</h2>
          <p className="text-foreground/80 mb-5 leading-relaxed">
            A Piece of Whole is an 8-week guided cohort experience for adults who want to understand their nervous system, build capacity for co-regulation, and connect their inner work to the communities they live in.
          </p>
          <p className="text-foreground/80 mb-5 leading-relaxed">
            Each week brings a theme, a practice, a private journal prompt, and a circle prompt — something to reflect on and share with your cohort if you choose. The practices are somatic and psychological. The community is intentional.
          </p>
          <p className="text-foreground/80 leading-relaxed">
            The civic piece is optional — a gentle invitation to consider how the inner work connects to the world outside. Not political. Not prescribed. Just an opening.
          </p>
          <p className="mt-6">
            <Link href="/learn" className="text-sm text-sage underline">
              Browse the Learn library →
            </Link>
          </p>
        </section>

        {/* How it works */}
        <section className="px-6 py-16 bg-foreground/5">
          <div className="max-w-2xl mx-auto">
            <h2 className="text-2xl mb-10">How it works</h2>
            <div className="space-y-8">
              {[
                { n: "1", title: "Apply", body: "Fill out a short application. A human reviews it within 48 hours." },
                { n: "2", title: "Get approved", body: "If approved, you'll receive a payment link to secure your spot." },
                { n: "3", title: "Join your cohort", body: "Sign in, complete a brief onboarding, and meet your circle." },
              ].map(({ n, title, body }) => (
                <div key={n} className="flex gap-6">
                  <div className="text-3xl text-stone font-serif">{n}</div>
                  <div>
                    <h3 className="font-medium mb-1">{title}</h3>
                    <p className="text-foreground/70">{body}</p>
                  </div>
                </div>
              ))}
            </div>
          </div>
        </section>

        {/* Who it's for */}
        <section className="px-6 py-16 max-w-2xl mx-auto">
          <h2 className="text-2xl mb-6">Who it&apos;s for</h2>
          <p className="text-foreground/80 leading-relaxed">
            Adults 18 and older who are curious about their inner life, stable enough to engage with it, and ready to be in a small, intentional community. This is not for people currently in active mental health crisis — we ask directly in the application, and we take that seriously. This is also not therapy or a substitute for professional mental health treatment.
          </p>
        </section>

        {/* Current cohorts */}
        {cohorts.length > 0 && (
          <section className="px-6 py-16 bg-foreground/5">
            <div className="max-w-4xl mx-auto">
              <h2 className="text-2xl mb-8">Open cohorts</h2>
              <div className="grid md:grid-cols-3 gap-6">
                {cohorts.map((cohort) => (
                  <div key={cohort.id} className="bg-background border border-foreground/10 p-6">
                    <h3 className="font-medium mb-2">{cohort.name}</h3>
                    {cohort.start_date && (
                      <p className="text-sm text-foreground/60 mb-4">
                        Starts {new Date(cohort.start_date).toLocaleDateString("en-US", {
                          month: "long", day: "numeric", year: "numeric",
                        })}
                      </p>
                    )}
                    {cohort.max_participants && (
                      <p className="text-sm text-foreground/60 mb-4">
                        Up to {cohort.max_participants} participants
                      </p>
                    )}
                    <Link href={`/cohorts/${cohort.slug ?? cohort.id}`} className="text-sm text-sage underline">
                      Learn more →
                    </Link>
                  </div>
                ))}
              </div>
              <p className="mt-8 text-center">
                <Link href="/cohorts" className="text-sm text-sage underline">
                  See all cohorts →
                </Link>
              </p>
            </div>
          </section>
        )}
      </main>
      <Footer />
    </div>
  );
}
