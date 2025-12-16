import "jsr:@supabase/functions-js/edge-runtime.d.ts"
import { getLastUpdated, insertLastUpdated } from './Update.js';

export async function ImportData(table, dataFunction, supabase, supabase1) {
  let log = [];
  let errors = [];
  
  const { data: sanity, error: sanityError } = await supabase1
    .from('game')
    .select('id')
    .order('id', { ascending: true })
    .limit(5);

  console.log("SANITY CHECK game:", sanity, sanityError);

  console.log("hello");
  try {
    let { lastid = 0, count = 0 } = await getLastUpdated(table, supabase);
    let importID = lastid;

    console.log(`Starting import for ${table}, next ID: ${importID}, count: ${count}`);
    console.log("USING SUPABASE1 URL:", supabase1.supabaseUrl);

    while (importID <= count) {
      try {
        const { data, error } = await supabase1
          .from(table)
          .select('*')
          .eq('id', importID)
          .single();

        console.log(data);

        if (data) {
          const row = { id: data.id, ...(data.data || {}) };
          await dataFunction(supabase, row);
          await insertLastUpdated(table, importID, supabase);

          log.push(`Imported ID ${importID} from ${table}`);
          console.log(`Imported ID ${importID} from ${table}`);
        } else {
          console.warn(`ID ${importID} not found in ${table}`);
          errors.push(`ID ${importID} not found in ${table}`);
        }
      } catch (err) {
        console.warn(`Error fetching ID ${importID} from ${table}:`, err);
        errors.push(`Error fetching ID ${importID} from ${table}: ${String(err)}`);
      }

      importID++;
    }

    console.log(`Finished importing ${table}`);
    return { log, errors };
  } catch (err) {
    console.error("Unexpected import error:", err);
    errors.push(String(err));
    return { log, errors };
  }
}
