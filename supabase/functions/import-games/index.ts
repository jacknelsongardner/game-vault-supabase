// Follow this setup guide to integrate the Deno language server with your editor:
// https://deno.land/manual/getting_started/setup_your_environment
// This enables autocomplete, go to definition, etc.

// Setup type definitions for built-in Supabase Runtime APIs
import "jsr:@supabase/functions-js/edge-runtime.d.ts"

import { createClient, SupabaseClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { getIGDBToken, sendIGDBRequest } from '../utils/IGDB.js';
import { ImportData } from "../utils/Import.js";

Deno.serve(async (req: Request) => {
  const supabase = createClient(
    Deno.env.get('SUPABASE_URL') ?? '',
    Deno.env.get('SUPABASE_ANON_KEY') ?? '',
    { global: { headers: { Authorization: req.headers.get('Authorization')! } } }
  )

  let log: string[] = [];
  let errors: string[] = [];

  try {

    const token = await getIGDBToken();

    const upsertImage = async (supabase: SupabaseClient, supaTable: string, igdbTable: string, id: number) => {

      if (id) {
        
        let response = await sendIGDBRequest(`fields *; where id = ${id};`, igdbTable, token);
        const imageData = response[0];

        if (imageData) 
        {
            // IGDB returns URLs in format "//images.igdb.com/..." (protocol-relative)
            // We need to prepend "https:" once to make it "https://images.igdb.com/..."
            const rawUrl = imageData.url ? imageData.url.replace(/t_thumb|t_cover_small|t_cover_big/g, "t_1080p") : "";
            const url = rawUrl.startsWith("//") ? `https:${rawUrl}` : rawUrl;

            const { data, error } = await supabase
              .from(supaTable)
              .upsert([
                { id: imageData.id, url: url, data: imageData }
              ])
              .select();

            
        
            console.log(`${supaTable} : `, imageData, data, error);
            if (error != null) 
            {
              throw new Error(`ERROR UPSERTING ${imageData} into ${supaTable} ${String(error)} id=${id}`);
            }
        }
        
      }
    }

    const upsertImageList = async (supabase: SupabaseClient, supaTable: string, igdbTable: string, ids: number[]) => {
      if (ids && ids.length > 0)
      {
        for (const id of ids)
        {
          await upsertImage(supabase, supaTable, igdbTable, id);
        }
      }
    }

    const getData = async (supabase: SupabaseClient, game: any) => {
        
      const game_id = game.id;
      
      const alts: string[] = [];

      if (game.alternative_names)
      {
        for (const alt of game.alternative_names)
        {
          const response = await sendIGDBRequest(`fields *; where id = ${alt};`, "alternative_names", token);
          if (response && response[0] && response[0].name)
          {
            alts.push(response[0].name);
          }
        }
      }

      game.alternative_names = alts;

      const game_search = `${game?.name} ${game?.slug} ${alts.join(" ")}`;

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
        for (const theme of game.themes)
        {

          let response = await sendIGDBRequest(`fields *; where id = ${theme};`, "themes", token);
          const themeData = response[0];

          if (themeData) 
          {

              const { data, error } = await supabase
                .from("theme")
                .upsert([
                  { id: themeData.id, name: themeData.name, data: themeData }
                ])
                .select();  
          
              console.log(`Theme : `, themeData, data, error);
              if (error != null) 
              {
                throw new Error(`ERROR UPSERTING ${themeData} into theme ${String(error)} id=${theme}`);
              }
          }
        }
      }

      if (game.genres)
      {  
        for (const genre of game.genres)
        {

          let response = await sendIGDBRequest(`fields *; where id = ${genre};`, "genres", token);
          const genreData = response[0];

          if (genreData) 
          {

              const { data, error } = await supabase
                .from("genre")
                .upsert([
                  { id: genreData.id, name: genreData.name, data: genreData }
                ])
                .select();  
          
              console.log(`Genre : `, genreData, data, error);
              if (error != null) 
              {
                throw new Error(`ERROR UPSERTING ${genreData} into genre ${String(error)} id=${genre}`);
              }
          }
        }
      }

      if (game.involved_companies)
      {  
        for (const company of game.involved_companies)
        {
          let response = await sendIGDBRequest(`fields *; where id = ${company};`, "involved_companies", token);
          const companyData = response[0];
  
          if (companyData) 
          {
              
              const search_name = `${companyData.name} ${companyData.slug}`;
  
              const { data, error } = await supabase
                .from("company")
                .upsert([
                  { id: companyData.id, search_name: companyData.name, data: companyData }
                ])
                .select();  
          
              console.log(`Involved Company : `, companyData, data, error);
              if (error != null) 
              {
                throw new Error(`ERROR UPSERTING ${companyData} into involved company ${String(error)} id=${company}`);
              }


          }
        }
  
      }
      if (game.collections)
      {

        for (const collectionID of game.collections)
          {
    
            let response = await sendIGDBRequest(`fields *; where id = ${collectionID};`, "collections", token);
            const collectionData = response[0];     
    
            if (collectionData) 
            {
                
                const { data, error } = await supabase
                  .from("collection")
                  .upsert([
                    { id: collectionData.id, name: collectionData.name, data: collectionData }
                  ])
                  .select();  
            
                console.log(`Collection : `, collectionData, data, error);
                if (error != null) 
                {
                  throw new Error(`ERROR UPSERTING ${collectionData} into collection ${String(error)} id=${collectionID}`);
                }
            }
          }
      }

      if (game.platforms){
        for (const platformID of game.platforms)
        {
          const response = await sendIGDBRequest(`fields *; where id = ${platformID};`, "platforms", token);
          const platform = response[0];

          console.log("platform->", platform);

          if (platform?.id) 
          {
            const platform_search = `${platform?.name} ${platform?.slug}`
        
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
 
    const result = await ImportData("games", "game", getData, supabase);
    log = result.log || [];
    errors = result.errors || [];

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
        error: err instanceof Error ? err.message : String(err), 
        "success" : false, 
        "log" : log, 
        "errors" : errors }),
      {
        headers: { "Content-Type": "application/json" },
        status: 500
      },
    );
  }
});

