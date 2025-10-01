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
import { sleep } from "../utils/Sleep.js";

Deno.serve(async (req) => {
  const supabase = createClient(
    Deno.env.get('SUPABASE_URL') ?? '',
    Deno.env.get('SUPABASE_ANON_KEY') ?? '',
    { global: { headers: { Authorization: req.headers.get('Authorization')! } } }
  )

  try {

    const token = await getIGDBToken();

    const upsertImage = async (supabase, supaTable, igdbTable, id) => {

      if (id) {
        
        var response = await sendIGDBRequest(`fields *; where id = ${id};`, igdbTable, token);
        response = response[0];

        if (response) 
        {

            const { data, error } = await supabase
              .from(supaTable)
              .upsert([
                { id: response.id, url: `https:${response.url}`, data: response }
              ])
              .select();  
        
            console.log(`${supaTable} : `, response, data, error);
            if (error != null) 
            {
              throw new Error(`ERROR UPSERTING ${response} into ${supaTable} ${String(error)} id=${id}`);
            }
        }
        
      }
    }

    const upsertImageList = async (supabase, supaTable, igdbTable, ids) => {
      if (ids && ids.length > 0)
      {
        for (var id of ids)
        {
          await upsertImage(supabase, supaTable, igdbTable, id);
        }
      }
    }

    const getData = async (supabase, game) => {
        
      var game_id = game.id;
      var game_json = game;
      var game_search = `${game?.name} ${game?.slug}`
  
      const { data, error } = await supabase
          .from('game')
          .upsert([
            { id: game_id, search_name: game_search, data: game_json }
          ])
          .select();

      await upsertImage(supabase, "cover", "covers", game.cover);
      await upsertImageList(supabase, "artwork", "artworks", game.artworks);
      await upsertImageList(supabase, "screenshot", "screenshots", game.screenshots);

      return {data, error}
    };
 
    const {log, errors} = await ImportData("games", "game", getData, supabase);

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
      JSON.stringify({ 
        message: String(err), 
        error: err, 
        "success" : true, 
        "log" : log, 
        "errors" : errors }),
      {
        headers: { "Content-Type": "application/json" },
        status: 500
      },
    );
  }
});

