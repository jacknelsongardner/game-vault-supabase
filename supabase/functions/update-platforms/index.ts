// Follow this setup guide to integrate the Deno language server with your editor:
// https://deno.land/manual/getting_started/setup_your_environment
// This enables autocomplete, go to definition, etc.

// Setup type definitions for built-in Supabase Runtime APIs


import "jsr:@supabase/functions-js/edge-runtime.d.ts"

import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { getIGDBToken, sendIGDBRequest } from '../utils/IGDB.js';
import { getLastUpdated, insertLastUpdated } from '../utils/Update.js'
import { cpuStart, cpuStop, wallStart, wallStop } from "../utils/Clock.js";
import { ImportData } from "../utils/Import.js";

Deno.serve(async (req) => {
  const supabase = createClient(
    Deno.env.get('SUPABASE_URL') ?? '',
    Deno.env.get('SUPABASE_ANON_KEY') ?? '',
    { global: { headers: { Authorization: req.headers.get('Authorization')! } } }
  )

  try {
 
    const getData = async (supabase, platform) => {
        
      var platform_id = platform.id;
      var platform_json = JSON.stringify(platform);
      var platform_search = `${platform?.name} ${platform?.slug}`
  
      const { data, error } = await supabase
          .from('platform')
          .upsert([
            { id: platform_id, search_name: platform_search, data: platform_json }
          ])
          .select();
      

      return {data, error}
    };
 
    var log, errors = await ImportData("platforms", "platform", getData, supabase);

    return new Response(JSON.stringify({  "success" : true, 
                                          "log" : log, 
                                          "errors" : errors }), {
      headers: { 'Content-Type': 'application/json' },
      status: 200,
    })
  } catch (err) 
  {
    console.error("Unexpected error:", err);

    return new Response(
      JSON.stringify({ message: String(err), error: err }),
      {
        headers: { "Content-Type": "application/json" },
        status: 500,
        "success" : true, 
        "log" : log, 
        "errors" : errors 
      },
    );
  }
});







/*
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
    var platform_id = updated["lastid"]
    var count = updated["count"]

    
    console.log("next Platform ID to import: ", platform_id);
    console.log("count: ", count);

    while (true) {
        
        const response =  await sendIGDBRequest(`fields *; where id = ${platform_id};`, "platforms", token);

        const platform = response[0]

        if (response.length > 0) {

        
          var id = platform.id;
          var entity_id = id;
          //var description = platform.summary; 
          var name = platform.name;
          var platform_json = JSON.stringify(platform);
          var platform_search = `${platform?.name} ${platform?.slug}`
          console.log(`Processing system: ${name} with json: ${JSON.stringify(platform)}`);
          done.push(platform);

          const { data: platformData, error: platformError } = await supabase
              .from('platform')
              .upsert([
                { id: platform_id, search_name: platform_search, data: platform_json }
              ])
              .select();

          console.log("Data upserted ")
          insertLastUpdated("platform", platform_id++, supabase);

          if (platformError) {
            console.log(`Error upserting system: ${platformError.message}`);
          }
        }

        console.log(`Upserted platform: ${name} with ID: ${id}`);
        
        if (platform_id!= count)
        {
          platform_id+= 1;
          console.log(`next up: ${platform_id}`);
        } 
        else {platform_id= 0; console.log("finished all"); break; }

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
  */