// Follow this setup guide to integrate the Deno language server with your editor:
// https://deno.land/manual/getting_started/setup_your_environment
// This enables autocomplete, go to definition, etc.

// Setup type definitions for built-in Supabase Runtime APIs
import "jsr:@supabase/functions-js/edge-runtime.d.ts"

import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { getIGDBToken, sendIGDBRequest } from '../utils/IGDB.js';


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
      

      var id = platform.id;
      var entity_id = id;
      var description = platform.summary; 
      var name = platform.name;

      
      console.log(`Processing system: ${name} with json: ${JSON.stringify(platform)}`);

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