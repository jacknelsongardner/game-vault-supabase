-- Add the missing vector_from_array function
-- This function is needed by the update_profile_vector_on_game_owned trigger

create or replace function vector_from_array(arr integer[])
returns vector
language plpgsql
immutable
as $$
declare
  float_array float[];
begin
  -- Convert integer array to float array
  select array_agg(val::float)
  into float_array
  from unnest(arr) as val;
  
  -- Cast the float array to a vector
  return float_array::vector;
end;
$$;
