-- Fix vector_zero and vector_one functions to handle size 0
-- When size is 0, return NULL instead of trying to create an invalid vector

create extension if not exists vector;

-- Function to create a vector filled with zeros
-- Returns NULL if size is 0
create or replace function vector_zero(size int)
returns vector
language plpgsql
immutable
as $$
declare
  result vector;
  zero_array float[];
begin
  -- Return NULL for zero size to avoid issues
  if size = 0 then
    return null;
  end if;
  
  -- Create an array of zeros with the specified size
  select array_agg(0.0::float)
  into zero_array
  from generate_series(1, size);
  
  -- Cast the array to a vector
  result := zero_array::vector;
  
  return result;
end;
$$;

-- Function to create a vector filled with ones
-- Returns NULL if size is 0
create or replace function vector_one(size int)
returns vector
language plpgsql
immutable
as $$
declare
  result vector;
  one_array float[];
begin
  -- Return NULL for zero size to avoid issues
  if size = 0 then
    return null;
  end if;
  
  -- Create an array of ones with the specified size
  select array_agg(1.0::float)
  into one_array
  from generate_series(1, size);
  
  -- Cast the array to a vector
  result := one_array::vector;
  
  return result;
end;
$$;
