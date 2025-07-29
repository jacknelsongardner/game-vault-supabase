// Follow this setup guide to integrate the Deno language server with your editor:
// https://deno.land/manual/getting_started/setup_your_environment
// This enables autocomplete, go to definition, etc.

// Setup type definitions for built-in Supabase Runtime APIs
import "jsr:@supabase/functions-js/edge-runtime.d.ts"

import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

console.log("Hello from Functions!")


async function getIGDBToken() {
  
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

async function sendIGDBRequest(request, endpoint, token) {
  
  const response = await fetch(`https://api.igdb.com/v4/${endpoint}`, {
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

  let jsonResponse = await response.json();
  console.log("Response from IGDB:", jsonResponse);
  
  return jsonResponse;
}




Deno.serve(async (req) => {
  try {
    const supabase = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? '',
      { global: { headers: { Authorization: req.headers.get('Authorization')! } } }
    )

    var token =  await getIGDBToken();
    const response =  await sendIGDBRequest("fields *; limit 260; ", "platforms", token);


    for (var platform of response) {
      

      var platform_id = platform.id;
      var id = `S${platform_id}`;  // No need to stringify a number for this use case
      var entity_id = id;
      var description = platform.summary; 
      var name = platform.name;

      console.log(`Processing entity: ${platform.name} with json: ${JSON.stringify(platform)}`);

      // Adding to supabase
      const { data: entityData, error: entityError } = await supabase
          .from('entity')
          .upsert({ id, name, description })
          .select();
      

      console.log(`Processing system: ${name} with json: ${JSON.stringify(platform)}`);

      id = platform.id; 
      const { data: systemData, error: systemError } = await supabase
          .from('system')
          .upsert({ id, entity_id })
          .select();

      if (entityError) {
        console.log(`Error upserting entity: ${entityError.message}`);
      }

      if (systemError) {
        console.log(`Error upserting system: ${systemError.message}`);
      }

      if (systemError || entityError) {
        break;
      }

      var data = { entityData, systemData };
      console.log(`Upserted platform: ${name} with ID: ${id}`);
    }

    return new Response(JSON.stringify({ response }), {
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