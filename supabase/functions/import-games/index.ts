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
      
      var alts = [];

      if (game.alternative_names)
      {
        for (var alt of game.alternative_names)
        {
          var response = await sendIGDBRequest(`fields *; where id = ${alt};`, "alternative_names", token);
          if (response && response[0] && response[0].name)
          {
            alts.push(response[0].name);
          }
        }
      }

      game.alternative_names = alts;

      var game_search = `${game?.name} ${game?.slug} ${alts.join(" ")}`;

      const { data, error } = await supabase
          .from('game')
          .upsert([
            { id: game_id, 
              search_name: game_search, 
              data: game, 
              name: game?.name 
            }
          ])
          .select();

      await upsertImage(supabase, "cover", "covers", game.cover);
      await upsertImageList(supabase, "artwork", "artworks", game.artworks);
      await upsertImageList(supabase, "screenshot", "screenshots", game.screenshots);
      await upsertImageList(supabase, "game_video", "game_videos", game.videos);
      await upsertImageList(supabase, "website", "websites", game.videos);

      if (game.themes)
      {
        for (var theme of game.themes)
        {

          var response = await sendIGDBRequest(`fields *; where id = ${theme};`, "themes", token);
          response = response[0];

          if (response) 
          {

              const { data, error } = await supabase
                .from("theme")
                .upsert([
                  { id: response.id, name: response.name, data: response }
                ])
                .select();  
          
              console.log(`Theme : `, response, data, error);
              if (error != null) 
              {
                throw new Error(`ERROR UPSERTING ${response} into theme ${String(error)} id=${id}`);
              }
          }
        }
      }

      if (game.genres)
      {  
        for (var genre of game.genres)
        {

          var response = await sendIGDBRequest(`fields *; where id = ${genre};`, "genres", token);
          response = response[0];

          if (response) 
          {

              const { data, error } = await supabase
                .from("genre")
                .upsert([
                  { id: response.id, name: response.name, data: response }
                ])
                .select();  
          
              console.log(`Genre : `, response, data, error);
              if (error != null) 
              {
                throw new Error(`ERROR UPSERTING ${response} into genre ${String(error)} id=${id}`);
              }
          }
        }
      }

      if (game.involved_companies)
      {  
        for (var company of game.involved_companies)
        {
          var response = await sendIGDBRequest(`fields *; where id = ${company};`, "involved_companies", token);
          response = response[0];
  
          if (response) 
          {
              
              var search_name = `${response.name} ${response.slug}`;
  
              const { data, error } = await supabase
                .from("company")
                .upsert([
                  { id: response.id, search_name: response.name, data: response }
                ])
                .select();  
          
              console.log(`Involved Company : `, response, data, error);
              if (error != null) 
              {
                throw new Error(`ERROR UPSERTING ${response} into involved company ${String(error)} id=${id}`);
              }
          }
        }
  
      }
      if (game.collections)
      {

        for (var collectionID of game.collections)
          {
    
            var response = await sendIGDBRequest(`fields *; where id = ${collectionID};`, "collections", token);
            response = response[0];     
    
            if (response) 
            {
                
                const { data, error } = await supabase
                  .from("collection")
                  .upsert([
                    { id: response.id, name: response.name, data: response }
                  ])
                  .select();  
            
                console.log(`Collection : `, response, data, error);
                if (error != null) 
                {
                  throw new Error(`ERROR UPSERTING ${response} into ${supaTable} ${String(error)} id=${id}`);
                }
            }
          }
      }

      if (game.platforms){
        for (var platformID of game.platforms)
        {
          var response = await sendIGDBRequest(`fields *; where id = ${platformID};`, "platforms", token);
          const platform = response[0];

          console.log("platform->", platform);

          if (platform.id) 
          {
            var platform_search = `${platform?.name} ${platform?.slug}`
        
            const { data, error } = await supabase
              .from('platform')
              .insert([
                {
                  id: platformID, 
                  search_name: platform_search, 
                  data: platform, 
                  name: platform?.name
                }
              ])
              .select();
          }
        }
      }
      
      return {data, error};
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

