// Follow this setup guide to integrate the Deno language server with your editor:
// https://deno.land/manual/getting_started/setup_your_environment
// This enables autocomplete, go to definition, etc.

// Setup type definitions for built-in Supabase Runtime APIs
import "jsr:@supabase/functions-js/edge-runtime.d.ts"

import { createClient, SupabaseClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { ImportData } from "../utils/Import.js";

Deno.serve(async (req: Request) => {
  const supabase = createClient(
    Deno.env.get('SUPABASE_URL') ?? '',
    Deno.env.get('SUPABASE_ANON_KEY') ?? '',
    { global: { headers: { Authorization: req.headers.get('Authorization')! } } }
  )

  const supabaseIGDB = createClient(
    Deno.env.get('SUPABASE_IGDB_URL') ?? 'http://host.docker.internal:18923',
    Deno.env.get('SUPABASE_IGDB_ANON_KEY') ?? 'sb_publishable_ACJWlzQHlZjBrEguHvfOxg_3BJgxAaH'
  );

  let log: string[] = [];
  let errors: string[] = [];

  try {

    

    const upsertImage = async (supabase: SupabaseClient, supaTable: string, igdbTable: string, id: number) => {

      if (id) {
        
        const { data, error } = await supabaseIGDB
          .from(igdbTable)
          .select('*')
          .eq('id', id)
          .single(); // get single row

        if (error) {
          console.error(`Error fetching ID ${id} from ${table}:`, error);
          return null;
        }

        if (!data) {
          console.warn(`ID ${id} not found in ${table}`);
          return null;
        }

        // The actual photo info is inside the JSONB column "data"
        const imageData = data.data; 
        console.log(`Fetched image from ${table} ID ${id}:`, imageData);

        if (imageData) 
        {
            // IGDB returns URLs in format "//images.igdb.com/..." (protocol-relative)
            // We need to prepend "https:" once to make it "https://images.igdb.com/..."
            const rawUrl = imageData.url ? imageData.url.replace(/t_thumb|t_cover_small|t_cover_big/g, "t_1080p") : "";
            const url = rawUrl.startsWith("//") ? `https:${rawUrl}` : rawUrl;

            const { data, error } = await supabase
              .from(supaTable)
              .upsert([
                { id: imageData.id, url: url}
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
          

          const { data, error } = await supabaseIGDB
            .from("alternative_names")
            .select('*')
            .eq('id', alt)
            .single(); // get single row

          if (error) {
            console.error(`Error fetching ID ${id} from ${table}:`, error);
            return null;
          }

          if (!data) {
            console.warn(`ID ${id} not found in ${table}`);
            return null;
          }

          if (data.data.name)
          {
            alts.push(data.data.name);
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
              name: game?.name 
            }
          ])
          .select();

      await upsertImage(supabase, "cover", "cover", game.cover);
      await upsertImageList(supabase, "artwork", "artwork", game.artworks);
      await upsertImageList(supabase, "screenshot", "screenshot", game.screenshots);
      await upsertImageList(supabase, "game_video", "game_video", game.videos);
      await upsertImageList(supabase, "website", "website", game.videos);

      if (game.themes)
      {
        for (const theme of game.themes)
        {

          const { data, error } = await supabaseIGDB
            .from("theme")
            .select('*')
            .eq('id', theme)
            .single(); // get single row

          if (error) {
            console.error(`Error fetching ID ${id} from ${table}:`, error);
            return null;
          }

          if (!data) {
            console.warn(`ID ${id} not found in ${table}`);
            return null;
          }

          let themeData = data.data;

          if (themeData) 
          {

              const { data, error } = await supabase
                .from("theme")
                .upsert([
                  { id: themeData.id, name: themeData.name}
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

          const { data, error } = await supabaseIGDB
            .from("genre")
            .select('*')
            .eq('id', genre)
            .single(); // get single row

          if (error) {
            console.error(`Error fetching ID ${id} from ${table}:`, error);
            return null;
          }

          if (!data) {
            console.warn(`ID ${id} not found in ${table}`);
            return null;
          }

          let genreData = data.data;

          if (genreData) 
          {

              const { data, error } = await supabase
                .from("genre")
                .upsert([
                  { id: genreData.id, name: genreData.name}
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
          

          const { data, error } = await supabaseIGDB
            .from("company")
            .select('*')
            .eq('id', company)
            .single(); // get single row

          if (error) {
            console.error(`Error fetching ID ${id} from ${table}:`, error);
            return null;
          }

          if (!data) {
            console.warn(`ID ${id} not found in ${table}`);
            return null;
          }

          let companyData = data.data;
  
          if (companyData) 
          {
              
              const search_name = `${companyData.name} ${companyData.slug}`;
  
              const { data, error } = await supabase
                .from("company")
                .upsert([
                  { id: companyData.id, search_name: companyData.name}
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
    
          const { data, error } = await supabaseIGDB
            .from("collection")
            .select('*')
            .eq('id', collectionID)
            .single(); // get single row

          if (error) {
            console.error(`Error fetching ID ${id} from ${table}:`, error);
            return null;
          }

          if (!data) {
            console.warn(`ID ${id} not found in ${table}`);
            return null;
          }

          let collectionData = data.data;
    
            if (collectionData) 
            {
                
                const { data, error } = await supabase
                  .from("collection")
                  .upsert([
                    { id: collectionData.id, name: collectionData.name}
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

          const { data, error } = await supabaseIGDB
            .from("platform")
            .select('*')
            .eq('id', platformID)
            .single(); // get single row

          if (error) {
            console.error(`Error fetching ID ${id} from ${table}:`, error);
            return null;
          }

          if (!data) {
            console.warn(`ID ${id} not found in ${table}`);
            return null;
          }

          const platform = data.data;

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
                  name: platform?.name
                }
              ])
              .select();
          }
        }
      }
      
      return {data, error};
    };
 

  console.log("hello4");
    const result = await ImportData("game", getData, supabase, supabaseIGDB);
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

