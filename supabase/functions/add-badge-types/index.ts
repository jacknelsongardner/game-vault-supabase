// supabase/functions/add-badges/index.ts
import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.3";

const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
const supabaseServiceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const supabase = createClient(supabaseUrl, supabaseServiceRoleKey);

serve(async (req) => {
  try {
    if (req.method !== "POST") {
      return new Response(
        JSON.stringify({ error: "Only POST requests are allowed." }),
        { status: 405, headers: { "Content-Type": "application/json" } }
      );
    }

    const body = await req.json();
    const badges = body.badges;

    if (!Array.isArray(badges) || badges.length === 0) {
      return new Response(
        JSON.stringify({ error: "No badges provided." }),
        { status: 400, headers: { "Content-Type": "application/json" } }
      );
    }

    // Validate badge objects
    const validBadges = badges.filter(
      (b) =>
        b.id &&
        typeof b.id === "number" &&
        typeof b.name === "string" &&
        typeof b.code === "string"
    );

    if (validBadges.length === 0) {
      return new Response(
        JSON.stringify({ error: "No valid badge objects provided. Each badge must have 'id', 'name', and 'code'." }),
        { status: 400, headers: { "Content-Type": "application/json" } }
      );
    }

    // Check for existing badge IDs or codes to avoid duplicates
    const { data: existingBadges, error: fetchError } = await supabase
      .from("badge")
      .select("id, code")
      .or(`id.in.(${validBadges.map((b) => b.id).join(",")}),code.in.(${validBadges.map((b) => `'${b.code}'`).join(",")})`);

    if (fetchError) {
      return new Response(JSON.stringify({ error: fetchError }), {
        status: 500,
        headers: { "Content-Type": "application/json" },
      });
    }

    const existingIds = (existingBadges || []).map((b) => b.id);
    const existingCodes = (existingBadges || []).map((b) => b.code);

    const newBadges = validBadges.filter(
      (b) => !existingIds.includes(b.id) && !existingCodes.includes(b.code)
    );

    if (newBadges.length === 0) {
      return new Response(
        JSON.stringify({ success: false, message: "All badges already exist (by id or code)." }),
        { status: 409, headers: { "Content-Type": "application/json" } }
      );
    }

    // Insert the new badges
    const { data: insertData, error: insertError } = await supabase
      .from("badge")
      .insert(
        newBadges.map((b) => ({
          id: b.id,
          name: b.name,
          code: b.code,
          icon_url: b.icon_url || null,
          description: b.description || null,
        }))
      )
      .select();

    if (insertError) {
      return new Response(JSON.stringify({ error: insertError }), {
        status: 500,
        headers: { "Content-Type": "application/json" },
      });
    }

    return new Response(
      JSON.stringify({
        success: true,
        inserted: insertData.length,
        data: insertData,
      }),
      { status: 200, headers: { "Content-Type": "application/json" } }
    );

  } catch (err) {
    console.error("Unexpected error:", err);
    return new Response(
      JSON.stringify({ error: "Unexpected error", details: String(err) }),
      { status: 500, headers: { "Content-Type": "application/json" } }
    );
  }
});
