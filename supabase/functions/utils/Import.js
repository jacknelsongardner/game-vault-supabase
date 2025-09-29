
import "jsr:@supabase/functions-js/edge-runtime.d.ts"

import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { getIGDBToken, sendIGDBRequest } from '../utils/IGDB.js';
import { getLastUpdated, insertLastUpdated } from '../utils/Update.js'
import { cpuStart, cpuStop, wallStart, wallStop } from "../utils/Clock.js";

async function ImportData(query, table, dataFunction, supabase)
{

  try {
    
    var token =  await getIGDBToken();

    var log = []
    var errors = []

    var updated = await getLastUpdated(table, supabase);

    var importID = updated["lastid"]
    var count = updated["count"]

    console.log("next Platform ID to import: ", importID);
    console.log("count: ", count);

    while (true) {
        
        const response =  await sendIGDBRequest(`fields *; where id = ${importID};`, query, token);

        const IGDBdata = response[0]

        if (response.length > 0) {

          const { data, error } = await dataFunction(supabase, IGDBdata);

          log.push(data);
          errors.push(error);

          console.log("Data upserted ")
          insertLastUpdated(table, importID++, supabase);

          if (error) {
            console.log(`Error upserting system: ${error.message}`);
          }
        }

        if (importID!= count)
        {
          importID+= 1;
          console.log(`next up: ${importID}`);
        } 
        else {importID= 0; console.log("finished all"); break; }

    }

    return { log, errors };
  } catch (err) {
    
    console.error("Unexpected import error", err);
    return { log, errors};
  }
}


export {ImportData}