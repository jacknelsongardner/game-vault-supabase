async function getLastUpdated(table, supabase) {
  // Fetch the single row
  var { data, error } = await supabase
    .from('last_imported')
    .select('next, count')
    .eq('kind', table);

  console.log("import result->", {data, error});
  
  if (data === null || data.length === 0) { 
    console.error("Supabase error:", error);
    
    // Insert a new row for the table
    var {data, error} = await supabase
      .from('last_imported')
      .insert({ kind: table, next: 0, count: 1000 });


    return { lastid: 0, count : 1000};
  }
  

  return { lastid: data[0].next, count: data[0].count };
}

async function insertLastUpdated(table, id, supabase) {
  
  // Upsert the next ID for this table
  console.log("inserting last updated")
  var {error} = await supabase
    .from('last_imported')
    .upsert({ kind: table, next: id }, { onConflict: ['kind'] }); // update if exists


  if (error) console.error("Supabase upsert error:", error);
}

export {insertLastUpdated, getLastUpdated}