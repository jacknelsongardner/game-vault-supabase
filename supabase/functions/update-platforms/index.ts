// Follow this setup guide to integrate the Deno language server with your editor:
// https://deno.land/manual/getting_started/setup_your_environment
// This enables autocomplete, go to definition, etc.

// Setup type definitions for built-in Supabase Runtime APIs
import "jsr:@supabase/functions-js/edge-runtime.d.ts"

import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { getIGDBToken, sendIGDBRequest } from '../utils/IGDB.js';
import { getLastUpdated, insertLastUpdated } from '../utils/Update.js'

Deno.serve(async (req) => {
  try {
    const supabase = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? '',
      { global: { headers: { Authorization: req.headers.get('Authorization')! } } }
    )

    var token =  await getIGDBToken();

    const MAX_WALL_TIME = 360000;
    const MAX_CPU_TIME = 1000;

    const startWallTime = Date.now();


    var startCpuTime = 0;
    var current_cpu_time = 0;

    function cpuStart() {
        startCpuTime = Date.now()
    }

    function cpuStop() {
        var cpu_time = Date.now() - startCpuTime; 
        current_cpu_time = current_cpu_time + cpu_time;
        if (current_cpu_time > MAX_CPU_TIME) {
          return true;
        } else {return false; }
    }

    var [nextID, count] = await getLastUpdated("platform");

    while (true) {


        const response =  await sendIGDBRequest(`fields *; where id = ${nextID};`, "platforms", token);
        
        
        cpuStart(); 

        const platform = response[0]
      
        var id = platform.id;
        var entity_id = id;
        //var description = platform.summary; 
        var name = platform.name;
        var json = platform;

        console.log(`Processing system: ${name} with json: ${JSON.stringify(platform)}`);
        
        cpuStop();

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

        console.log(`Upserted platform: ${name} with ID: ${id}`);
        
        if (nextID != count)
        {
          nextID += 1;
        } 
        else {nextID = 0}

        cpuStop(); 

        insertLastUpdated("platform", nextID);

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