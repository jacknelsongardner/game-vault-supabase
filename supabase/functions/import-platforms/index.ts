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