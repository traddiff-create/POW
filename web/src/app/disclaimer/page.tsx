import { Footer } from "@/components/Footer";

export default function DisclaimerPage() {
  return (
    <div className="flex flex-col min-h-screen">
      <main className="flex-1 px-6 py-16 max-w-2xl mx-auto">
        <p className="text-sm text-[#C0392B] mb-8 border border-[#C0392B] px-4 py-3">
          DRAFT — FOR ATTORNEY REVIEW BEFORE LAUNCH
        </p>
        <h1 className="text-3xl mb-6" style={{ fontFamily: "Georgia, serif" }}>Not Therapy Disclaimer</h1>
        <div className="space-y-4 text-[#2C2A28]/80 leading-relaxed">
          <p>
            A Piece of Whole is a community-based practice and educational program. It is <strong>not therapy</strong>, not mental health treatment, not medical advice, and not a substitute for professional mental health care.
          </p>
          <p>
            Participation in A Piece of Whole does not create a therapist-client relationship, a doctor-patient relationship, or any other professional relationship that implies duty of care.
          </p>
          <p>
            If you are experiencing a mental health crisis, please contact the 988 Suicide and Crisis Lifeline (call or text 988), the Crisis Text Line (text HOME to 741741), or emergency services.
          </p>
          <p>
            The practices, prompts, and community circles offered through A Piece of Whole are intended as self-guided educational experiences. They are designed for individuals who are not currently in active mental health crisis.
          </p>
          <p>
            We encourage all participants to maintain relationships with licensed mental health professionals as appropriate for their individual circumstances.
          </p>
        </div>
      </main>
      <Footer />
    </div>
  );
}
