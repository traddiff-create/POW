import { redirect } from "next/navigation";
import Link from "next/link";
import { createClient } from "@/lib/supabase/server";
import { CrisisBanner } from "@/components/CrisisBanner";

export default async function CivicPage() {
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) redirect("/auth/login");

  const { data: lessons } = await supabase
    .from("civic_lessons")
    .select("id, title, category, estimated_minutes, order_index")
    .order("order_index", { ascending: true });

  const byCategory = (lessons ?? []).reduce<Record<string, typeof lessons>>((acc, lesson) => {
    const cat = lesson!.category ?? "General";
    acc[cat] = acc[cat] ?? [];
    acc[cat]!.push(lesson);
    return acc;
  }, {});

  return (
    <div className="flex flex-col min-h-screen">
      <main className="flex-1 px-6 py-12 max-w-2xl mx-auto w-full space-y-10">
        <div>
          <h1 className="text-2xl mb-2" style={{ fontFamily: "Georgia, serif" }}>Civic engagement</h1>
          <p className="text-[#2C2A28]/60 text-sm">
            Short modules connecting your inner work to civic life.
          </p>
        </div>

        {Object.keys(byCategory).length > 0 ? (
          Object.entries(byCategory).map(([category, items]) => (
            <section key={category}>
              <p className="text-xs text-[#2C2A28]/40 uppercase tracking-wide mb-3">{category}</p>
              <ul className="space-y-3">
                {(items ?? []).map((lesson) => lesson && (
                  <li key={lesson.id}>
                    <Link
                      href={`/civic/${lesson.id}`}
                      className="block border border-[#2C2A28]/10 p-4 hover:border-[#7A9E7E]/40 transition-colors"
                    >
                      <div className="flex items-center justify-between gap-4">
                        <p className="text-sm font-medium">{lesson.title}</p>
                        {lesson.estimated_minutes && (
                          <span className="text-xs text-[#2C2A28]/40 shrink-0">
                            {lesson.estimated_minutes} min
                          </span>
                        )}
                      </div>
                    </Link>
                  </li>
                ))}
              </ul>
            </section>
          ))
        ) : (
          <p className="text-[#2C2A28]/50 text-sm">Civic modules are coming soon.</p>
        )}
      </main>
      <CrisisBanner />
    </div>
  );
}
