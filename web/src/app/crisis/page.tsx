import { Footer } from "@/components/Footer";

export default function CrisisPage() {
  return (
    <div className="flex flex-col min-h-screen">
      <main className="flex-1 px-6 py-16 max-w-2xl mx-auto">
        <h1 className="text-3xl mb-6">Crisis Resources</h1>
        <p className="text-foreground/70 mb-10">
          If you or someone you know is in crisis, please reach out to one of these free, confidential services.
        </p>
        <div className="space-y-8">
          <div className="border-l-2 border-sage pl-6">
            <h2 className="font-medium mb-1">988 Suicide and Crisis Lifeline</h2>
            <p className="text-foreground/70">Call or text <strong>988</strong> — available 24/7</p>
          </div>
          <div className="border-l-2 border-sage pl-6">
            <h2 className="font-medium mb-1">Crisis Text Line</h2>
            <p className="text-foreground/70">Text <strong>HOME</strong> to <strong>741741</strong> — available 24/7</p>
          </div>
          <div className="border-l-2 border-sage pl-6">
            <h2 className="font-medium mb-1">NAMI Helpline</h2>
            <p className="text-foreground/70">Call <strong>1-800-950-6264</strong> — Mon–Fri, 10am–10pm ET</p>
          </div>
          <div className="border-l-2 border-sage pl-6">
            <h2 className="font-medium mb-1">Emergency Services</h2>
            <p className="text-foreground/70">Call <strong>911</strong> if you or someone else is in immediate danger.</p>
          </div>
        </div>
      </main>
      <Footer />
    </div>
  );
}
