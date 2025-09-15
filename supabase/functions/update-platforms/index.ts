// Follow this setup guide to integrate the Deno language server with your editor:
// https://deno.land/manual/getting_started/setup_your_environment
// This enables autocomplete, go to definition, etc.

// Setup type definitions for built-in Supabase Runtime APIs
import "jsr:@supabase/functions-js/edge-runtime.d.ts"

import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { getIGDBToken, sendIGDBRequest } from '../utils/IGDB.js';
import { getLastUpdated, insertLastUpdated } from '../utils/Update.js'
import { cpuStart, cpuStop, wallStart, wallStop } from "../utils/Clock.js";

Deno.serve(async (req) => {
  const supabase = createClient(
    Deno.env.get('SUPABASE_URL') ?? '',
    Deno.env.get('SUPABASE_ANON_KEY') ?? '',
    { global: { headers: { Authorization: req.headers.get('Authorization')! } } }
  )

  try {
    
    cpuStart();

    var token =  await getIGDBToken();

    var done = []

    var updated = await getLastUpdated("platform", supabase);
    var nextID = updated["lastid"]
    var count = updated["count"]

    console.log("nextID: ", nextID);

    function checkClock() {
      if (cpuStop() || wallStop())
      {
        return true;
      }
    }
    
    cpuStop();

    while (true) {
        
        

        const response =  await sendIGDBRequest(`fields *; where id = ${nextID};`, "platforms", token);
        
        cpuStart(); 

        if (response.length > 0) {

          const platform = response[0]
        
          var id = platform.id;
          var entity_id = id;
          //var description = platform.summary; 
          var name = platform.name;
          var json = platform;

          console.log(`Processing system: ${name} with json: ${JSON.stringify(platform)}`);
          done.push(platform);

          if (checkClock()) {break; }

          const { data: platformData, error: platformError } = await supabase
              .from('platform')
              .insert([
                { id: nextID, data: platform }
              ])
              .select();

          cpuStart();

          if (platformError) {
            console.log(`Error upserting system: ${platformError.message}`);
          }
        }

        console.log(`Upserted platform: ${name} with ID: ${id}`);
        
        if (nextID != count)
        {
          nextID += 1;
        } 
        else {nextID = 0}

        if (checkClock()) {break; }

        insertLastUpdated("platform", nextID, supabase);
    }

    return new Response(JSON.stringify({ "response" : done }), {
      headers: { 'Content-Type': 'application/json' },
      status: 200,
    })
  } catch (err) {
    console.error("Unexpected error:", err);
    return new Response(
      JSON.stringify({ message: String(err), error: err }),
      {
        headers: { "Content-Type": "application/json" },
        status: 500,
      },
    );
  }
})