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

    var updated = await getLastUpdated("game", supabase);
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
        
        const response =  await sendIGDBRequest(`fields *; where id = ${nextID};`, "games", token);
        
        cpuStart(); 

        const game = response[0]

        if (response.length > 0) {

        
          var id = game.id;

          var name = game.name;
          var json = game;

          var platforms = game["platforms"]

          console.log(`Processing game: ${name} with json: ${JSON.stringify(game)}`);
          done.push(game);

          if (checkClock()) {break; }
          
          cpuStop();

          const { data: gameData, error: gameError } = await supabase
              .from('game')
              .upsert([
                { id: nextID, data: game }
              ])
              .select();
          
          if (platforms)
          {
            for (var plat_id of platforms)
            {

              const { data: playedData, error: playedError } = await supabase
                  .from('played_on')
                  .upsert([
                    { game_id: id, platform_id: plat_id }
                  ])
                  .select();
              
            }
          }

          insertLastUpdated("game", nextID, supabase);
          
          

          cpuStart();

          if (gameError) {
            console.log(`Error upserting system: ${gameError.message}`);
          }
        }

        console.log(`Upserted game: ${name} with ID: ${id} to platforms: ${platforms}`);
        
        if (nextID != count)
        {
          nextID += 1;
          console.log(`next up: ${nextID}`);
        } 
        else {nextID = 0; break; }

        if (checkClock()) {break; }
        cpuStop();
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