// Sends a WhatsApp reminder (Meta WhatsApp Cloud API template) the day before each CONFIRMED appointment.
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.45.4";

Deno.serve(async (req) => {
  if (req.headers.get("x-cron-secret") !== Deno.env.get("CRON_SECRET")) return new Response("forbidden", { status: 403 });
  const sb = createClient(Deno.env.get("SUPABASE_URL")!, Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!);
  const tomorrow = new Date(Date.now() + 5.5 * 3600e3 + 24 * 3600e3).toISOString().slice(0, 10); // IST
  const { data, error } = await sb.from("appointments").select("*")
    .eq("status", "Confirmed").eq("reminder_sent", false).eq("date", tomorrow);
  if (error) return new Response(error.message, { status: 500 });

  let sent = 0;
  for (const a of data ?? []) {
    const r = await fetch(`https://graph.facebook.com/v20.0/${Deno.env.get("WA_PHONE_ID")}/messages`, {
      method: "POST",
      headers: { Authorization: `Bearer ${Deno.env.get("WA_TOKEN")}`, "Content-Type": "application/json" },
      body: JSON.stringify({
        messaging_product: "whatsapp", to: "91" + a.phone, type: "template",
        template: { name: "appointment_reminder", language: { code: "en" },
          components: [{ type: "body", parameters: [a.name, a.date, a.time].map((text) => ({ type: "text", text })) }] },
      }),
    });
    if (r.ok) { await sb.from("appointments").update({ reminder_sent: true }).eq("id", a.id); sent++; }
  }
  return new Response(JSON.stringify({ sent }), { headers: { "Content-Type": "application/json" } });
});
