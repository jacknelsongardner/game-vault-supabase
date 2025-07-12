// Follow this setup guide to integrate the Deno language server with your editor:
// https://deno.land/manual/getting_started/setup_your_environment
// This enables autocomplete, go to definition, etc.

// Setup type definitions for built-in Supabase Runtime APIs
import "jsr:@supabase/functions-js/edge-runtime.d.ts"

console.log("Hello from Functions!")


function getIGDBToken() {
  
    const auth_response = await fetch("https://id.twitch.tv/oauth2/token?client_id=eo11l1fe0ka6cbupy2foe8yjqloqv8&client_secret=x9pgfvyp8bo5xw0qh56t02l2pjoena&grant_type=client_credentials", {
      method: "POST",
      headers: {
        "Content-Type": "application/json"
      }
    });

    if (!auth_response.ok) {
      throw new Error(`HTTP error! status: ${auth_response.status}`);
    }

    const auth_data = await auth_response.json();
    console.log("Authentication successful:", auth_data);

    var token = auth_data.access_token;
    return token;
}

function sendIGDBRequest(request, token) {
  
  const response = await fetch("https://api.igdb.com/v4/platforms", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "Client-ID": "eo11l1fe0ka6cbupy2foe8yjqloqv8",
      "Authorization": `Bearer ${token}`
    },
    body: request
  });

  if (!response.ok) {
    throw new Error(`HTTP error! status: ${response.status}`);
  }
  
  return await response;
}




Deno.serve(async (req) => {
  try {
    const supabase = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? '',
      { global: { headers: { Authorization: req.headers.get('Authorization')! } } }
    )

    var token = getIGDBToken();

    // TODO: Change the table_name to your table
    const { data, error } = await supabase.from('table_name').select('*')

    if (error) {
      throw error
    }

    return new Response(JSON.stringify({ data }), {
      headers: { 'Content-Type': 'application/json' },
      status: 200,
    })
  } catch (err) {
    return new Response(JSON.stringify({ message: err?.message ?? err }), {
      headers: { 'Content-Type': 'application/json' },
      status: 500 
    })
  }
})

/* To invoke locally:

  1. Run `supabase start` (see: https://supabase.com/docs/reference/cli/supabase-start)
  2. Make an HTTP request:

  curl -i --location --request POST 'http://127.0.0.1:54321/functions/v1/update-systems' \
    --header 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0' \
    --header 'Content-Type: application/json' \
    --data '{"name":"Functions"}'

*/
