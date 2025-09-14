
async function getLastUpdated(table) {
    // Fetch the row(s) from Supabase
    var { data, error } = await supabase
      .from('last_imported')
      .select('data')
      .limit(1)

    if (error) {
      console.error("Supabase error:", error);
      return 0;
    }
  
    const importedJSON = data?.[0]?.json || {};
  
    // Ensure platform.type exists and is a number
    if (!importedJSON.hasOwnProperty(table) || typeof importedJSON.platform.type !== "number") {
      importedJSON[table] = {lastid: 0, count: 5000};
      var { data, error } = await supabase
        .from('last_imported')
        .insert({data: importedJSON})
        .limit(1)
    }

    return importedJSON[table].lastid, importedJSON[table].lastcount;
  };

  async function insertLastUpdated(table, id) {
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