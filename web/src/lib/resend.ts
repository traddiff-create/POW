import { Resend } from "resend";

let _resend: Resend | null = null;
function getResend() {
  if (!_resend) _resend = new Resend(process.env.RESEND_API_KEY!);
  return _resend;
}

const FROM = process.env.RESEND_FROM_EMAIL ?? "hello@apieceofwhole.com";
const APP_URL = process.env.NEXT_PUBLIC_APP_URL ?? "http://localhost:3000";

export async function sendApplicationReceived(opts: {
  adminEmail: string;
  applicantName: string;
  applicantEmail: string;
  cohortName: string;
  motivationExcerpt: string;
  applicationId: string;
}) {
  return getResend().emails.send({
    from: FROM,
    to: opts.adminEmail,
    subject: `New Application — ${opts.applicantName}`,
    html: `
      <p><strong>${opts.applicantName}</strong> (${opts.applicantEmail}) applied to <strong>${opts.cohortName}</strong>.</p>
      <blockquote>${opts.motivationExcerpt}</blockquote>
      <p><a href="${APP_URL}/admin/applications/${opts.applicationId}">Review application →</a></p>
    `,
  });
}

export async function sendApplicantConfirmation(opts: {
  to: string;
  name: string;
}) {
  return getResend().emails.send({
    from: FROM,
    to: opts.to,
    subject: "Your application has been received",
    html: `
      <p>Hi ${opts.name},</p>
      <p>Your application has been received. A human will review it and you'll hear from us within 48 hours.</p>
      <p>With care,<br/>A Piece of Whole</p>
    `,
  });
}

export async function sendApprovalEmail(opts: {
  to: string;
  name: string;
  cohortName: string;
  nextStep: string;
}) {
  return getResend().emails.send({
    from: FROM,
    to: opts.to,
    subject: "You're in — here's your next step",
    html: `
      <p>Hi ${opts.name},</p>
      <p>We've reviewed your application to <strong>${opts.cohortName}</strong> and we're glad to welcome you.</p>
      <p>${opts.nextStep}</p>
      <p>If you have questions, reply to this email.</p>
      <p>With care,<br/>A Piece of Whole</p>
    `,
  });
}

export async function sendRejectionEmail(opts: {
  to: string;
  name: string;
  cohortName: string;
  adminNote?: string;
}) {
  return getResend().emails.send({
    from: FROM,
    to: opts.to,
    subject: "Your application to A Piece of Whole",
    html: `
      <p>Hi ${opts.name},</p>
      <p>Thank you for applying to <strong>${opts.cohortName}</strong>. After careful review, we aren't able to offer you a spot in this cohort.</p>
      ${opts.adminNote ? `<p>${opts.adminNote}</p>` : ""}
      <p>We hope you'll consider applying to a future cohort when the timing feels right.</p>
      <p>With care,<br/>A Piece of Whole</p>
    `,
  });
}

export async function sendWaitlistEmail(opts: {
  to: string;
  name: string;
  cohortName: string;
}) {
  return getResend().emails.send({
    from: FROM,
    to: opts.to,
    subject: "You're on the waitlist",
    html: `
      <p>Hi ${opts.name},</p>
      <p>Thank you for applying to <strong>${opts.cohortName}</strong>. This cohort is currently full, but we've added you to the waitlist. If a spot opens, you'll hear from us before the cohort begins.</p>
      <p>We'll also let you know when new cohorts are scheduled.</p>
      <p>With care,<br/>A Piece of Whole</p>
    `,
  });
}

export async function sendPaymentConfirmation(opts: {
  to: string;
  name: string;
  cohortName: string;
}) {
  return getResend().emails.send({
    from: FROM,
    to: opts.to,
    subject: `Welcome — you're enrolled in ${opts.cohortName}`,
    html: `
      <p>Hi ${opts.name},</p>
      <p>Your payment is confirmed. You're enrolled in <strong>${opts.cohortName}</strong>.</p>
      <p>You'll receive a separate email with your sign-in link shortly. Use it to access your cohort.</p>
      <p>With care,<br/>A Piece of Whole</p>
    `,
  });
}

export async function sendSignInLink(opts: {
  to: string;
  name: string;
  link: string;
}) {
  return getResend().emails.send({
    from: FROM,
    to: opts.to,
    subject: "Your sign-in link for A Piece of Whole",
    html: `
      <p>Hi ${opts.name},</p>
      <p>Here's your sign-in link. It's valid for 24 hours.</p>
      <p><a href="${opts.link}">Sign in to your cohort →</a></p>
      <p>If you didn't expect this email, you can ignore it.</p>
      <p>With care,<br/>A Piece of Whole</p>
    `,
  });
}
