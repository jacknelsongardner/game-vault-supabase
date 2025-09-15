async function getLastUpdated(table, supabase) {
  // Fetch the single row
  const { data, error } = await supabase
    .from('last_imported')
    .select('data')
    .limit(1);

  if (error) {
    console.error("Supabase error:", error);
    return { lastid: 0, count: 0 };
  }

  let importedJSON = data?.[0]?.data || {};

  // Ensure entry for this table exists
  if (!importedJSON.hasOwnProperty(table)) {
    importedJSON[table] = { lastid: 0, count: 5000 };
    console.log("UPDATE INFO: ", importedJSON)
    const { error: updateError } = await supabase
      .from('last_imported')
      .update({ data: importedJSON })

    if (updateError) console.error("Supabase update error:", updateError);
  }
  
  return { lastid: importedJSON[table].lastid, count: importedJSON[table].count };
}


async function insertLastUpdated(table, id, supabase) {
  // Fetch the row(s) from Supabase
  const { data, error } = await supabase
    .from('last_imported')
    .select('json')
    .limit(1)

  if (error) {
    console.error("Supabase error:", error);
    return 0;
  }

  const importedJSON = data?.[0]?.json || {};

  // Ensure platform.type exists and is a number
  if (!importedJSON.hasOwnProperty(table) || typeof importedJSON.platform.type !== "number") {
    importedJSON[table]["lastid"] = id;
  }
};

export {insertLastUpdated, getLastUpdated}