const WEEK_MS = 7 * 24 * 60 * 60 * 1000;

export function currentProgramWeek(startDate: string | null | undefined): number {
  if (!startDate) return 1;
  const elapsed = Date.now() - new Date(startDate).getTime();
  return Math.min(8, Math.max(1, Math.ceil(elapsed / WEEK_MS)));
}

export function currentGreeting(): string {
  const hour = new Date().getHours();
  if (hour < 12) return "Good morning";
  if (hour < 17) return "Good afternoon";
  return "Good evening";
}

export function currentDateLabel(): string {
  return new Date().toLocaleDateString("en-US", {
    weekday: "long",
    month: "long",
    day: "numeric",
  });
}
